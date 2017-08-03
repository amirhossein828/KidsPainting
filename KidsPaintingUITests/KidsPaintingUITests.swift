//
//  KidsPaintingUITests.swift
//  KidsPaintingUITests
//
//  Created by seyedamirhossein hashemi on 2017-07-11.
//  Copyright © 2017 seyedamirhossein hashemi. All rights reserved.
//

import XCTest

class KidsPaintingUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testGoFromTableViewToAddItem() {
        
        let app = XCUIApplication()
        app.toolbars.buttons["Add"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 1).children(matching: .other).element.tap()
        app.navigationBars["KidsPainting.GalleryCollectionCollectionView"].buttons["Next"].tap()
        let nameOfArticle = app.textFields["nameOfArticle"]
        nameOfArticle.tap()
        nameOfArticle.typeText("waterfall2")
        let price = app.textFields["price"]
        price.tap()
        price.typeText("123")
        app.buttons["Share"].tap()
        let itemText = app.navigationBars["Items"]
        sleep(2)
        XCTAssert(itemText.exists)
    }
    
    
    
    func testAddAndComeBack() {
        
        let app = XCUIApplication()
        app.toolbars.buttons["Add"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 4).children(matching: .other).element.tap()
        app.navigationBars["KidsPainting.GalleryCollectionCollectionView"].buttons["Next"].tap()
        app.navigationBars["KidsPainting.UploadItemView"].buttons["Cancel"].tap()
        let itemText = app.navigationBars["Items"]
        sleep(2)
        XCTAssert(itemText.exists)
        
    
    }
    
    func testMainToDetail() {
        let app = XCUIApplication()
        app.tables.element(boundBy: 0).tap()
        let buyBtn = app.buttons["Buy"]
        sleep(2)
        XCTAssert(buyBtn.exists)
    }
    func testLoginWithUserAndPassword() {
        
    }
    
}
