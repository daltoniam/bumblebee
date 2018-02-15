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
    
    func testEmojiExample() {
		let breakingString = " *hello* .  *hello*  cncnc cncnc  *hello*  hmm\n  *hello*  🦌🐎🦌🐎\n  *hello*  Screen Shot 2017-10-12 at 11.04.58 AM.png  *hello*  vVe2keakU8.gif  *hello*   *hello* "


		let parser = Parser()

		let parseExpectation = expectation(description: "parsing expectation")

		parser.add(pattern: MDEmphasisPattern()) { (str, attributes) in
			return MatchedResponse(string: str, attributes: [:])
		}

		parser.process(text: breakingString) { (attrString) in
			guard let _ = attrString else {
				return
			}
			parseExpectation.fulfill()
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
