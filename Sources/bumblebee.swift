//
//  bumblebee.swift
//
//  Created by Dalton Cherry on 10/3/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

import Foundation
#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

//using this instead of a NSAttributed String just to be very clear on what is happening
public struct MatchedResponse {
    let string: String
    let attributes: [NSAttributedStringKey: Any]?
    //only needed to allow public initialization
    public init(string: String, attributes: [NSAttributedStringKey: Any]?) {
        self.string = string
        self.attributes = attributes
    }
}

public typealias MatchClosure = (String, [String: String]?) -> MatchedResponse

//This is a protocol to allow custom regex patterns to be create outside of the ones provided below
public protocol Pattern {
    func regex() throws -> NSRegularExpression
    func transform(text: String) -> (text: String, attributes: [String: String]?)
}

//The transform method allows a pattern to do pre processing on the text before it shows up in the matched closure.
//This is a default implementation to not force protocols that don't need this power to implement the method.
extension Pattern {
    public func transform(text: String) -> (text: String, attributes: [String: String]?) {
        return (text: text, attributes: nil)
    }
}

//private class that holds the matches
class Matcher {
    let pattern: Pattern
    let matched: MatchClosure
    init(pattern: Pattern, match: @escaping MatchClosure) {
        self.pattern = pattern
        self.matched = match
    }
}

//Where the actual magic starts
open class Parser {
    var matchOpts = [Matcher]()
    
    //so it can be init'ed publicly
    public init() {
    }
    
    //add a Pattern and map it to a closure that is called for text and attribute modification when a pattern matches
    public func add(pattern: Pattern, matched: @escaping MatchClosure) {
        matchOpts.append(Matcher(pattern: pattern, match: matched))
    }
    
    public func remove(pattern: Pattern) {
        //matchOpts.remove
    }
    
    //This is where the magic happens. This methods creates a attributed string
    //with all the pattern operations off the text provided
    public func process(text: String, attributes: [NSAttributedStringKey: Any]? = nil, observedOn: DispatchQueue = .global(qos: .background), subscribedOn: DispatchQueue = .main, completion: @escaping ((NSAttributedString?) -> Void)) {
        //background operation to deal with possible long term parsing
        let opts = matchOpts //avoid race condition in the rare case that the add method is called with text is being processed
        observedOn.async {
            let mutStr = NSMutableAttributedString(string: text, attributes: attributes)
            for opt in opts {
                do {
                    let regex = try opt.pattern.regex()
                    var diff = 0
                    let mutText = mutStr.string
                    let matches = regex.matches(in: mutText, range: NSMakeRange(0, mutStr.string.utf16.count))
                    for result in matches {
                        if result.numberOfRanges > 0 {
                            let range = result.range(at: 0)
                            let location = range.location
                            if location == NSNotFound {
                                continue
                            }
                            let start = mutText.index(mutText.startIndex, offsetBy: range.location)
                            let end = mutText.index(mutText.startIndex, offsetBy: range.location + range.length)
                            
                            if let str = String(mutText.utf16[start..<end]) {
                                let transform = opt.pattern.transform(text: str)
                                let response = opt.matched(transform.text, transform.attributes)
                                
                                //diff range accounts for any char changes (string is now a different length)
                                let diffRange = NSMakeRange(location + diff, range.length)
                                //merge and apply attributes
                                var attrs = mutStr.attributes(at: diffRange.location, longestEffectiveRange: nil, in: diffRange)
                                if let newAttrs = response.attributes {
                                    for (key, value) in newAttrs {
                                        attrs[key] = value
                                    }
                                }
                                //create an attributed string with the attributes of the orignial string with any new additions for the matched response
                                let replaceStr = NSAttributedString(string: response.string, attributes: attrs)
                                diff += response.string.utf16.count - str.utf16.count
                                mutStr.replaceCharacters(in: diffRange, with: replaceStr)
                            }
                        }
                    }
                } catch {
                    subscribedOn.async {
                        completion(nil) //the regex failed, you get nothing! (or I guess an error if we wanted, very unlikely this will happen)
                    }
                    return
                }
            }
            subscribedOn.async {
                completion(mutStr)
            }
        }
    }
}

//Built in patterns to make using bumblebee much easier

//Matches URLs. e.g. (http://domain.com/url/etc)
public struct LinkPattern : Pattern {
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        return try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }
}

//Matches Phone numbers. e.g. (867-5309)
public struct PhoneNumberPattern : Pattern {
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        return try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
    }
}

//Matches typical user name patterns from social platforms like twitter. (@daltoniam, etc)
public struct UserNamePattern : Pattern {
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        //twitter requires between 4 and 15 char for a user name, but hightlights the user name at one char...
        //so I'm using {1,15} instead of {4,15}, but could be easily changed depending on requirements
        return try NSRegularExpression(pattern: "(?<=\\s|^)@[a-zA-Z0-9_]{1,15}\\b", options: .caseInsensitive)
    }
}

//Matches hex strings to convert them to their proper unicode version.
public struct UnicodePattern : Pattern {
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: "(?<=\\s|^)U\\+[a-zA-Z0-9]{2,6}\\b", options: .caseInsensitive)
    }
    
    //convert the hex to its proper Unicode scalar. e.g. (U+1F602 to 😂)
    public func transform(text: String) -> (text: String, attributes: [String: String]?) {
        let offset = text.index(text.startIndex, offsetBy: 2)
        let hex = String(text[offset..<text.endIndex])
        if let i = Int(hex, radix: 16) {
            let scalar = UnicodeScalar(i)
            if let scalar = scalar {
                return (text: String(Character(scalar)), attributes: nil)
            }
        }
        return (text: text, attributes: nil)
    }
}

//Matches The markdown link pattern. (e.g. [link name](link-here) )
public struct MDLinkPattern : Pattern {
    public static let linkAttribute = "md-link"
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: "(?<=[^!])\\[([^\\[]+)\\]\\(([^\\)]+)\\)", options: .caseInsensitive)
    }
    
    //get the link out and just return the link's text
    public func transform(text: String) -> (text: String, attributes: [String: String]?) {
        guard let endBrac = text.range(of: "]") else {return (text, nil)}
        let linkText = String(text[text.index(text.startIndex, offsetBy: 1)..<endBrac.lowerBound])
        let link = String(text[text.index(endBrac.upperBound, offsetBy: 1)..<text.index(text.endIndex, offsetBy: -1)])
        return (linkText, [MDLinkPattern.linkAttribute: link])
    }
}

//Matches The markdown image pattern. (e.g. ![meta info here](image-link-here) )
public struct MDImagePattern : Pattern {
    public static let linkAttribute = "md-link"
    public static let altTextAttribute = "md-alt"
    public static var attachmentString: String {
        return "\(Character(UnicodeScalar(NSAttachmentCharacter)!))"
    }
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: "!\\[([^\\[]*)\\]\\(([^\\)]+)\\)", options: .caseInsensitive)
    }
    
    public func transform(text: String) -> (text: String, attributes: [String: String]?) {
        guard let endBrac = text.range(of: "]") else {return (text, nil)}
        let altText = String(text[text.index(text.startIndex, offsetBy: 2)..<endBrac.lowerBound])
        let link = String(text[text.index(endBrac.upperBound, offsetBy: 1)..<text.index(text.endIndex, offsetBy: -1)])
        return (MDImagePattern.attachmentString, [MDImagePattern.linkAttribute: link, MDImagePattern.altTextAttribute: altText])
    }
}

//Matches The markdown bold pattern. (e.g. **bold text** or __bold text__)
public struct MDBoldPattern : Pattern {
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: "(\\*\\*|__)(.+?)(\\*\\*|__)", options: .caseInsensitive)
    }
    
    public func transform(text: String) -> (text: String, attributes: [String: String]?) {
        let newText = String(text[text.index(text.startIndex, offsetBy: 2)..<text.index(text.endIndex, offsetBy: -2)])

        return (newText, nil)
    }
}

//Matches The markdown emphasis pattern. (e.g. _emphasis text_ or *emphasis text* )
public struct MDEmphasisPattern : Pattern {
    public init() {} //only need to allow public initialization
    public func regex() throws -> NSRegularExpression {
        return try NSRegularExpression(pattern: "(?<!(\\*|_))(\\*|_)(.+?)(\\*|_)(?!(\\*|_))", options: .caseInsensitive)
    }
    
    public func transform(text: String) -> (text: String, attributes: [String: String]?) {
        let newText = String(text[text.index(text.startIndex, offsetBy: 1)..<text.index(text.endIndex, offsetBy: -1)])
        return (newText, nil)
    }
}
