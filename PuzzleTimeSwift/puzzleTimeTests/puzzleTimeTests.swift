//
//  puzzleTimeTests.swift
//  puzzleTimeTests
//
//  Created by Wei Shan on 1/8/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

import XCTest

@testable import puzzleTime

class puzzleTimeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let vg = ViewController()
        let myView = UIView()
        myView.center = CGPointMake(0, 0);
        let emptySpot = CGPointMake(10, 10);
        vg.moveViewToEmptySpot(myView, emptySpot: emptySpot)
        XCTAssertTrue(myView.center == emptySpot)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
