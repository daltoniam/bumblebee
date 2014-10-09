//
//  bumblebee.swift
//
//  Created by Dalton Cherry on 10/3/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

import Foundation

class Pattern {
    var matched:((String) -> (text: String,offset: Int))?
    var start = 0
    var end = -1
    var text: String
    var current: Character
    var mustFullfill = true
    var index = 0
    init(_ text: String, _ start: Int, _ matched: ((String) -> (String,Int))?) {
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
        } else {
            mustFullfill = true
        }
        return false
    }
}
class Matcher {
    var src: String
    var matched:((String) -> (String,Int))?
    init(src: String,matched:((String) -> (String,Int))?) {
        self.src = src
        self.matched = matched
    }
}
///This makes the == work for Pattern objects
extension Pattern: Equatable {}

func ==(lhs: Pattern, rhs: Pattern) -> Bool {
    return lhs.text == rhs.text
}

public class BumbleBee {
    
    var patterns = Array<Matcher>()
    
    public func add(pattern: String, matched: ((String) -> (String,Int))?) {
        patterns.append(Matcher(src: pattern, matched: matched))
    }
    
    public func process(srcText: String) {
        var pending = Array<Pattern>()
        var index = 0
        var text = srcText
        for char in text {
            var consumed = false
            for pattern in pending {
                if char != pattern.current && pattern.mustFullfill {
                    println("remove this pattern")
                    //pending.removeLast()
                    pending = pending.filter{$0 != pattern}
                } else if char == pattern.current {
                    if pattern.next() {
                        pattern.end = index
                        println("finished a pattern: \(pattern.text)")
                        let range = advance(text.startIndex, pattern.start)...advance(text.startIndex, pattern.end)
                        println("text range: \(text[range])")
                        if let match = pattern.matched {
                            let src = text[range]
                            let srcLen = countElements(src)
                            var replace = match(src)
                            text.replaceRange(range, with: replace.text)
                            index -= srcLen-countElements(replace.text)
                        }
                        //pending.removeLast()
                        pending = pending.filter{$0 != pattern}
                        consumed = true
                        break
                    }
                }
            }
            //process to see if a new pattern is matched
            if !consumed {
                for matchable in patterns {
                    if char == matchable.src[matchable.src.startIndex] {
                        println("possible pattern: \(matchable.src)")
                        pending.append(Pattern(matchable.src,index,matchable.matched))
                    }
                }
            }
            index++
        }
        println("text is: \(text)")
    }
}
