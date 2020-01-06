//
//  UITestSafari.m
//  Branch-TestBed-UITests
//
//  Created by Parth Kalavadia on 8/2/17.
//  Copyright © 2017 Branch Metrics. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface UITestDeeplinkFromSafari : XCTestCase

@end

@interface XCUIApplication (Private)
- (id)initPrivateWithPath:(NSString *)path bundleID:(NSString *)bundleID;
@end

/**
 This is an integration test that depends on the production server!
 */
@implementation UITestDeeplinkFromSafari

- (void)setUp {
    self.continueAfterFailure = NO;
    [self denyPushNotifications];
}

- (void)tearDown {

}

- (void)denyPushNotifications {
    
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
}

- (XCUIApplication *)openSafariWithUrl:(NSString*) url {
    XCUIApplication *app = [[XCUIApplication alloc] initPrivateWithPath:nil bundleID:@"com.apple.mobilesafari"];
    [app launch];
    if ([app.otherElements[@"URL"] waitForExistenceWithTimeout:5.0]) {
        [app.otherElements[@"URL"] tap];
        if ([app.textFields[@"Search or enter website name"] waitForExistenceWithTimeout:5.0]) {
            [app.textFields[@"Search or enter website name"] tap];
            [app typeText:url];
            [app.buttons[@"Go"] tap];
        }
    }
    return app;
}

- (void)testDeepLinking {
    // open webpage and click deeplink to test app
    NSString *webpage = @"https://github.com/BranchMetrics/ios-branch-deep-linking/wiki/UITest-for-Testbed-App-for-Universal-links";
    XCUIApplication *safariApp = [self openSafariWithUrl:webpage];
    if ([safariApp.links[@"Universal Link TestBed Obj-c"] waitForExistenceWithTimeout:5.0]) {
        [safariApp.links[@"Universal Link TestBed Obj-c"] tap];
    }
        
    // if safari requests permission to open the test app, grant it
    if ([safariApp.buttons[@"Open"] waitForExistenceWithTimeout:5.0]) {
        [safariApp.buttons[@"Open"] tap];
    }
    
    // check if app opened with deeplink
    XCUIApplication *currentApp = [[XCUIApplication alloc] init];
    if ([currentApp.textViews[@"DeepLinkData"] waitForExistenceWithTimeout:5.0]) {
        XCUIElement* element = currentApp.textViews[@"DeepLinkData"];
        XCTAssertTrue([element.value containsString:@"Successfully Deeplinked"]);
    } else {
        XCTFail(@"Did not find successful deeplink screen");
    }
}

@end
