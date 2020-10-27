//
//  FoodTruckTrackerUITests.swift
//  FoodTruckTrackerUITests
//
//  Created by Cora Jacobson on 10/14/20.
//

import XCTest

class FoodTruckTrackerUITests: XCTestCase {
    
    var app = XCUIApplication()
    
    private let exists = NSPredicate(format: "exists == true")
    
    private var newAccountButton: XCUIElement { app.buttons["LoginVC.createNewAccount"] }
    private var newUsernameTF: XCUIElement { app.textFields["SignUpVC.usernameTextField"] }
    private var emailTF: XCUIElement { app.textFields["SignUpVC.emailTextField"] }
    private var newPasswordTF: XCUIElement { app.secureTextFields["SignUpVC.passwordTextField"] }
    private var signUpButton: XCUIElement { app.buttons["SignUpVC.signUpButton"] }
    private var usernameTF: XCUIElement { app.textFields["LoginVC.usernameTextField"] }
    private var passwordTF: XCUIElement { app.secureTextFields["LoginVC.passwordTextField"] }
    private var loginButton: XCUIElement { app.buttons["LoginVC.loginButton"] }
    
    override func setUpWithError() throws {
        super.setUp()
        app.launch()
        continueAfterFailure = false
    }
    
    func testCreateAccountFailsAndPresentsAlertIfUsernameAlreadyExists() {
        let alert = app.staticTexts["Error"]
        XCTAssertFalse(alert.exists)
        expectation(for: exists, evaluatedWith: alert, handler: nil)
        
        newAccountButton.tap()
        newUsernameTF.tap()
        newUsernameTF.typeText("user17")
        emailTF.tap()
        emailTF.typeText("user17@gmail.com")
        newPasswordTF.tap()
        newPasswordTF.typeText("123456")
        signUpButton.tap()
        
        waitForExpectations(timeout: 1)
        XCTAssert(alert.exists)
    }
    
    func testLoginAsDiner() {
        let button = app.buttons["View as List"]
        XCTAssertFalse(button.exists)
        expectation(for: exists, evaluatedWith: button, handler: nil)
        
        usernameTF.tap()
        usernameTF.typeText("user17")
        passwordTF.tap()
        passwordTF.typeText("123456")
        loginButton.tap()
        
        waitForExpectations(timeout: 2)
        XCTAssert(button.exists)
    }
    
    func testViewTruckOnListView() {
        let button = app.buttons["View as List"]
        XCTAssertFalse(button.exists)
        expectation(for: exists, evaluatedWith: button, handler: nil)
        
        usernameTF.tap()
        usernameTF.typeText("user17")
        passwordTF.tap()
        passwordTF.typeText("123456")
        loginButton.tap()
        
        waitForExpectations(timeout: 2)
        XCTAssert(button.exists)
        button.tap()
        
        let menuButton = app.buttons["Menu"]
        XCTAssertFalse(menuButton.exists)
        expectation(for: exists, evaluatedWith: menuButton, handler: nil)
        
        app.tables.staticTexts["Taqueria Sinaloa"].tap()
        
        waitForExpectations(timeout: 2)
        XCTAssert(menuButton.exists)
    }
    
    func testLoginAsOwnerAndViewTrucksOnFavorites() {
        let title = app.staticTexts["My Trucks"]
        XCTAssertFalse(title.exists)
        expectation(for: exists, evaluatedWith: title, handler: nil)
        
        usernameTF.tap()
        usernameTF.typeText("user7")
        passwordTF.tap()
        passwordTF.typeText("123456")
        loginButton.tap()
        app.tabBars["Tab Bar"].buttons["person.badge.minus"].tap()

        waitForExpectations(timeout: 2)
        XCTAssert(title.exists)
    }
    
    func testLoginAsDinerAndViewTrucksOnFavorites() {
        let title = app.staticTexts["My Favorite Trucks"]
        XCTAssertFalse(title.exists)
        expectation(for: exists, evaluatedWith: title, handler: nil)
        
        usernameTF.tap()
        usernameTF.typeText("user17")
        passwordTF.tap()
        passwordTF.typeText("123456")
        loginButton.tap()
        app.tabBars["Tab Bar"].buttons["person.badge.minus"].tap()

        waitForExpectations(timeout: 2)
        XCTAssert(title.exists)
    }
    
    func testFilterTrucksByCuisine() {
        var firstCount: Int = 0
        expectation(for: NSPredicate(format: "%@ != 0"), evaluatedWith: firstCount, handler: nil)
        
        usernameTF.tap()
        usernameTF.typeText("user17")
        passwordTF.tap()
        passwordTF.typeText("123456")
        loginButton.tap()
        
        let searchNavigationBar = app.navigationBars["Search"]
        let viewAsListButton = searchNavigationBar.buttons["View as List"]
        viewAsListButton.tap()
        
        firstCount = app.tables.cells.count
        waitForExpectations(timeout: 2)
        XCTAssertNotEqual(firstCount, 0)
        
        var secondCount: Int = 0
        expectation(for: NSPredicate(format: "%@ != 0"), evaluatedWith: secondCount, handler: nil)
        
        app.navigationBars["Truck List"].buttons["Search"].tap()
        searchNavigationBar.buttons["Filter Trucks"].tap()
        app.pickerWheels["All Cuisines"].adjust(toPickerWheelValue: "Mexican")
        app.buttons["Apply Filters"].tap()
        viewAsListButton.tap()
        
        secondCount = app.tables.cells.count
        waitForExpectations(timeout: 2)
        XCTAssertNotEqual(firstCount, 0)
        
        XCTAssertNotEqual(firstCount, secondCount)
    }

}
