//
//  bumblebee.swift
//
//  Created by Dalton Cherry on 10/3/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

import Foundation

class Pattern {
    var matched:((String,String,Int) -> (text: String,offset: Int))?
    var start = 0
    var end = -1
    var text: String
    var recursive: Bool
    var current: Character
    var mustFullfill = true
    var index = 0
    var rewindIndex = 0
    init(_ text: String, _ start: Int, _ recursive: Bool, _ matched: ((String,String,Int) -> (String,Int))?) {
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
        if index >= countElements(text) {
            return true
        }
        current = text[advance(text.startIndex, index)]
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
            current = text[advance(text.startIndex, rewindIndex)]
            return true
        }
        return false
    }
}
class Matcher {
    var src: String
    var recursive: Bool
    var matched:((String,String,Int) -> (String,Int))?
    init(src: String,recursive: Bool ,matched:((String,String,Int) -> (String,Int))?) {
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

public class BumbleBee {
    
    var patterns = Array<Matcher>()
    
    public func add(pattern: String, recursive: Bool, matched: ((String,String,Int) -> (String,Int))?) {
        patterns.append(Matcher(src: pattern, recursive: recursive, matched: matched))
    }
    
    public func process(srcText: String) -> String {
        var pending = Array<Pattern>()
        var index = 0
        var text = srcText
        for char in text {
            var consumed = false
            for pattern in pending.reverse() {
                if char != pattern.current && pattern.mustFullfill {
                    pending = pending.filter{$0 != pattern}
                } else if char == pattern.current {
                    if pattern.next() {
                        pattern.end = index
                        let range = advance(text.startIndex, pattern.start)...advance(text.startIndex, pattern.end)
                        //println("text range: \(text[range])")
                        if let match = pattern.matched {
                            let src = text[range]
                            let srcLen = countElements(src)
                            var replace = match(src,text,pattern.start)
                            text.replaceRange(range, with: replace.text)
                            index -= (srcLen-countElements(replace.text))
                        }
                        pending = pending.filter{$0 != pattern}
                        consumed = true
                        //break
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
        return text
    }
}
