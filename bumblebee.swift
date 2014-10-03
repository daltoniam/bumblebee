//
//  bumblebee.swift
//
//  Created by Dalton Cherry on 10/3/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

import Foundation

class Pattern {
    var start = 0
    var end = -1
    var text: String
    var current: Character
    var mustFullfill = true
    var index = 0
    init(_ text: String, _ start: Int) {
        self.start = start
        self.text = text
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
///This makes the == work for Pattern objects
extension Pattern: Equatable {}

func ==(lhs: Pattern, rhs: Pattern) -> Bool {
    return lhs.text == rhs.text
}

public class BumbleBee {
    
    var patterns = Array<String>()
    
    public func add(pattern: String) {
        patterns.append(pattern)
    }
    
    public func process(text: String) {
        var pending = Array<Pattern>()
        var index = 0
        for char in text {
            check(text, char: char, index: index, pending: &pending)
            index++
        }
    }
    
    private func check(text: String,char: Character, index: Int, inout pending: Array<Pattern>) {
        var consumed = false
        for pattern in pending {
            if char != pattern.current && pattern.mustFullfill {
                println("remove this pattern")
                pending.removeLast()
                //pending = pending.filter{$0 != pattern}
            } else if char == pattern.current {
                if pattern.next() {
                    pattern.end = index
                    println("finished a pattern: \(pattern.text)")
                    println("text range: \(text[advance(text.startIndex, pattern.start)...advance(text.startIndex, pattern.end)])")
                    pending.removeLast()
                    //pending = pending.filter{$0 != pattern}
                    consumed = true
                }
            }
        }
        //process to see if a new pattern is matched
        if !consumed {
            for str in patterns {
                if char == str[str.startIndex] {
                    println("possible pattern: \(str)")
                    pending.append(Pattern(str,index))
                }
            }
        }
    }
}
