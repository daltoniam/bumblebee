//
//  bumblebee.swift
//
//  Created by Dalton Cherry on 10/3/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

//The support support class that keeps a track of the patterns while processing
class Pattern {
    var matched:((String,String,Int) -> (text: String,attrs: [NSObject : AnyObject]?))?
    var start = 0
    var length = -1
    var attrs: [String : AnyObject]?
    var text: String
    var recursive: Bool
    var current: Character
    var mustFullfill = true
    var index = 0
    var rewindIndex = 0
    init(_ text: String, _ start: Int, _ recursive: Bool, _ matched: ((String,String,Int) -> (String,[NSObject : AnyObject]?))?) {
        self.mustFullfill = true
        self.recursive = recursive
        self.start = start
        self.text = text
        self.matched = matched
        self.current = text[text.startIndex]
        next()
    }
    func next() -> Bool {
        index++
        if index >= text.characters.count {
            return true
        }
        current = text[text.startIndex.advancedBy(index)]
        if current == "?" {
            next()
            mustFullfill = false
            rewindIndex = index
        }
        return false
    }
    func rewind() -> Bool {
        if index > rewindIndex && rewindIndex > 0 {
            index = rewindIndex
            current = text[text.startIndex.advancedBy(rewindIndex)]
            return true
        }
        return false
    }
}
class Matcher {
    var src: String
    var recursive: Bool
    var matched:((String,String,Int) -> (String,[NSObject : AnyObject]?))?
    init(src: String,recursive: Bool ,matched:((String,String,Int) -> (String,[NSObject : AnyObject]?))?) {
        self.src = src
        self.matched = matched
        self.recursive = recursive
    }
}
///This makes the == work for Pattern objects
extension Pattern: Equatable {}

func ==(lhs: Pattern, rhs: Pattern) -> Bool {
    return lhs.text == rhs.text && lhs.start == rhs.start
}

///This class is where the magic happens.
public class BumbleBee {
    
    ///The patterns array holds all the variables that make up a pattern
    var patterns = Array<Matcher>()
    //returns the character used for attachments
    public var attachmentString: String {
        return "\(Character(UnicodeScalar(NSAttachmentCharacter)))"
    }
    
    //standard init method that does nothing.
    public init() {
        
    }
    
    //standard init method that does nothing.
    public init(attrString: NSAttributedString) {
        
    }
    
    ///add a new pattern for processing. The closure is called when a match is found and allows the replacement text and attributes to be applied.
    public func add(pattern: String, recursive: Bool, matched: ((String,String,Int) -> (String,[NSObject : AnyObject]?))?) {
        patterns.append(Matcher(src: pattern, recursive: recursive, matched: matched))
    }
    
    //The srcText is the raw text to search matches for. A NSAttributedString is return stylized according to the matches.
    public func process(srcText: String, attributes: [String: AnyObject]? = nil) -> NSAttributedString {
        var pending = Array<Pattern>()
        var collect = Array<Pattern>()
        var index = 0
        var text = srcText
        for char in text.characters {
            var consumed = false
            var lastChar: Character?
            for pattern in Array(pending.reverse()) {
                if char != pattern.current && pattern.mustFullfill {
                    pending = pending.filter{$0 != pattern}
                } else if char == pattern.current {
                    if lastChar == char {
                        lastChar = nil
                        continue //it is matching on the same pattern, so skip it
                    }
                    if pattern.next() {
                        let range = text.startIndex.advancedBy(pattern.start)...text.startIndex.advancedBy(index)
                        //println("text range: \(text[range])")
                        if let match = pattern.matched {
                            let src = text[range]
                            let srcLen = src.characters.count
                            let replace = match(src,text,pattern.start)
                            if replace.attrs != nil {
                                text.replaceRange(range, with: replace.text)
                                let replaceLen = replace.text.characters.count
                                index -= (srcLen-replaceLen)
                                lastChar = char
                                pattern.length = replaceLen
                                pattern.attrs = replace.attrs as? [String:AnyObject]
                            }
                        }
                        pending = pending.filter{$0 != pattern}
                        consumed = true
                        if pattern.length > -1 {
                            collect.append(pattern)
                        }
                    }
                } else {
                    if pattern.rewind() && !pattern.recursive {
                        pending = pending.filter{$0 != pattern}
                    }
                }
            }
            //process to see if a new pattern is matched
            if !consumed {
                for matchable in patterns {
                    if char == matchable.src[matchable.src.startIndex] {
                        pending.append(Pattern(matchable.src,index, matchable.recursive,matchable.matched))
                    }
                }
            }
            index++
        }
        //we have our patterns, let's build a stylized string
        let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
        for pattern in collect {
            let range = NSMakeRange(pattern.start, pattern.length)
            var attrs = attributedText.attributesAtIndex(pattern.start, longestEffectiveRange: nil, inRange: range)
            if let newAttrs = pattern.attrs {
                for (key, value) in newAttrs {
                    attrs[key] = value
                }
            }
            attributedText.setAttributes(attrs, range: range)
        }
        return attributedText
    }
}
