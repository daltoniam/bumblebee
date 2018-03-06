//
//  EmojiTests.swift
//  BumblebeeTests
//
//  Created by Robin Malhotra on 15/02/18.
//  Copyright © 2018 vluxe. All rights reserved.
//

import XCTest
import Bumblebee

class EmojiTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	let parser = Parser()
    
    func testEmojiExample() {
		let breakingString = "🐎 *hello* "
   
		let parseExpectation = expectation(description: "parsing expectation")

		parser.add(pattern: MDEmphasisPattern()) { (str, attributes) in
			return MatchedResponse(string: str, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10.0)])
		}

		parser.process(text: breakingString) { (attrString) in
			guard let attrString = attrString else {
				return
			}
			let rangeToCompare = NSRange.init(location: 3, length: 5)
			attrString.enumerateAttributes(in: NSRange(location: 0, length: attrString.string.count), options: [.longestEffectiveRangeNotRequired], using: { (value, range, isStop) in
				if range == rangeToCompare {
					parseExpectation.fulfill()
				}
			})
		}

		wait(for: [parseExpectation], timeout: 10.0)


        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
