//
//  PuzzleTimeTests.m
//  PuzzleTimeTests
//
//  Created by Wei Shan on 1/11/16.
//  Copyright © 2016 Wei Shan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GameViewController.h"

@interface GameViewController ()

- (void) swapTwoItems: (NSIndexPath *) firstIndexPath secondIndexPath: (NSIndexPath *) secondeIndexPath curArray: (NSMutableArray *) curArray;

@end

@interface PuzzleTimeTests : XCTestCase

@end

@implementation PuzzleTimeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    GameViewController *gvc = [GameViewController new];
    NSIndexPath *firstPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *secondPath = [NSIndexPath indexPathForItem:1 inSection:0];
    NSMutableArray *curArray = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", nil];
    [gvc swapTwoItems:firstPath secondIndexPath:secondPath curArray:curArray];
    XCTAssertTrue([[curArray objectAtIndex:0] isEqualToString:@"2"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
