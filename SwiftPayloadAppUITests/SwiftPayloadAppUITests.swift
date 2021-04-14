//
//  SwiftPayloadAppUITests.swift
//  SwiftPayloadAppUITests
//
//  Created by HungNV on 4/14/21.
//  Copyright © 2021 NIFCLOUD mobile backend. All rights reserved.
//

import XCTest
@testable import NCMB

class SwiftPayloadAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    var pushId: String!
    var richURL = "https://mbaas.nifcloud.com/"
    var pushTitle = "title"
    var pushMsg = "message"
    
    //********** APIキーの設定 **********
    let applicationkey = "YOUR_NCMB_APPLICATIONKEY"
    let clientkey      = "YOUR_NCMB_CLIENTKEY"
    
    // MARK: - Setup for UI Test
    override func setUp() {
        continueAfterFailure = false
        NCMB.initialize(applicationKey: applicationkey, clientKey: clientkey)
        app = XCUIApplication()
    }
    
    func testReceivedPush() throws {
        app.launch()
        allowPushNotificationsIfNeeded()
        sendPush()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.activate()
        let notification = springboard.otherElements["Notification"].descendants(matching: .any)["NotificationShortLookView"]
        XCTAssertEqual(waiterResultWithExpectation(notification), XCTWaiter.Result.completed)
        notification.tap()
        XCTAssertTrue(app.staticTexts["SwiftPayloadApp"].waitForExistence(timeout: 10))
        let pushId = app.filterCells(containing: self.pushId).element
        XCTAssert(pushId.exists)
        let richURL = app.filterCells(containing: self.richURL).element
        XCTAssert(richURL.exists)
        let aps = app.filterCells(containing: "\"alert\":{\"title\":\"\(self.pushTitle)\",\"body\":\"\(self.pushMsg)\"}").element
        XCTAssert(aps.exists)
    }
}

// MARK: - XCUIApplication
extension XCUIApplication {
    // Filter cells in TableView
    func filterCells(containing values: String...) -> XCUIElementQuery {
        var cells = self.cells
        for value in values {
            cells = cells.containing(NSPredicate(format: "value CONTAINS %@", value))
        }
        return cells
    }
}

extension SwiftPayloadAppUITests {
    // Allow privacy push notification
    private func allowPushNotificationsIfNeeded() {
        addUIInterruptionMonitor(withDescription: "Remote Authorization") { alerts -> Bool in
            if alerts.buttons["Allow"].exists {
                alerts.buttons["Allow"].tap()
                return true
            }
            return false
        }
        app.tap()
    }
    
    // Send a rich push
    private func sendPush() {
        let push: NCMBPush = NCMBPush()
        push.title = pushTitle
        push.message = pushMsg
        push.richUrl = richURL
        push.isSendToIOS = true
        push.setImmediateDelivery()
        push.sendInBackground(callback: { result in
            switch result {
            case .success:
                self.pushId = push.objectId
                print("登録に成功しました。プッシュID: \(push.objectId!)")
            case let .failure(error):
                print("登録に失敗しました: \(error)")
            }
        })
    }
    
    // Waiting XCUIElement
    private func waiterResultWithExpectation(_ element: XCUIElement) -> XCTWaiter.Result {
        let myPredicate = NSPredicate(format: "exists == true")
        let myExpectation = XCTNSPredicateExpectation(predicate: myPredicate, object: element)
        let result = XCTWaiter().wait(for: [myExpectation], timeout: 180)
        return result
    }
}
