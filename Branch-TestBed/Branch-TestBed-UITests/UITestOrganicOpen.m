//
//  UITestOrganicOpen.m
//  Branch-TestBed-UITests
//
//  Created by Ernest Cho on 12/31/19.
//  Copyright © 2019 Branch, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface UITestOrganicOpen : XCTestCase

@end

@interface XCUIApplication (Private)
- (id)initPrivateWithPath:(NSString *)path bundleID:(NSString *)bundleID;
@end

@implementation UITestOrganicOpen

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)tearDown {

}

- (void)testExample {
    
    // if the OS launches the push notification permission request, deny it
    // this only triggers if a test attempts to tap an element and a system dialog gets in the way
    [self addUIInterruptionMonitorWithDescription:@"Allow push" handler:^BOOL(XCUIElement * _Nonnull interruptingElement) {
        if (interruptingElement.buttons[@"Don’t Allow"].exists) {
            [interruptingElement.buttons[@"Don’t Allow"] tap];
        }
        return YES;
    }];
    
    // install and open test app, attempt to tap anywhere on the screen
    XCUIApplication *currentApp = [[XCUIApplication alloc] init];
    [currentApp launch];
    [currentApp tap];
    
    // navigate to the referring params
    if ([currentApp.buttons[@"View LatestReferringParams"] waitForExistenceWithTimeout:5.0]) {
        [currentApp.buttons[@"View LatestReferringParams"] tap];
        XCUIElement* element = currentApp.textViews[@"DeepLinkData"];
        XCTAssertTrue([element.value containsString:@"is_first_session"]);
    }
    
    // background test app by opening another app
    XCUIApplication *app = [[XCUIApplication alloc] initPrivateWithPath:nil bundleID:@"com.apple.mobilesafari"];
    [app launch];
    if ([app.buttons[@"URL"] waitForExistenceWithTimeout:5.0]) {
        
        // reopen the test app
        [currentApp launch];
        
        // navigate to the referring params
        if ([currentApp.buttons[@"View LatestReferringParams"] waitForExistenceWithTimeout:5.0]) {
            [currentApp.buttons[@"View LatestReferringParams"] tap];
            XCUIElement* element = currentApp.textViews[@"DeepLinkData"];
            XCTAssertTrue([element.value containsString:@"is_first_session"]);
        }
    }
}

@end
