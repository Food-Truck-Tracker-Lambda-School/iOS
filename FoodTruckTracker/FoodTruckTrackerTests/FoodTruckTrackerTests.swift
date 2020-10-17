//
//  FoodTruckTrackerTests.swift
//  FoodTruckTrackerTests
//
//  Created by Cora Jacobson on 10/14/20.
//

import XCTest
@testable import FoodTruckTracker

class FoodTruckTrackerTests: XCTestCase {

    func testRegisterNewAccount() {
        let mock = MockLoader()
        mock.data = validUserJSON
        
        let controller = UserController(dataLoader: mock)
        let resultsExpectation = expectation(description: "Wait for registration results")
        
        let user = User(username: "bilbo", password: "baggins", roleId: 1, email: "bagend@shire.me")
        
        
        controller.signIn(existingAccount: nil, newAccount: user) { result in
            resultsExpectation.fulfill()
            XCTAssertEqual(result, .success(true))
        }
        
        wait(for: [resultsExpectation], timeout: 2)
        
        XCTAssertNotNil(controller.currentUser)
        XCTAssertNotNil(controller.bearer)
    }
    
    func testLoginExistingAccount() {
        let mock = MockLoader()
        mock.data = validUserJSON
        
        let controller = UserController(dataLoader: mock)
        let resultsExpectation = expectation(description: "Wait for login results")
        
        let user = ReturningUser(username: "bilbo", password: "baggins")
                
        controller.signIn(existingAccount: user, newAccount: nil) { result in
            resultsExpectation.fulfill()
            XCTAssertEqual(result, .success(true))
        }
        
        wait(for: [resultsExpectation], timeout: 2)
        XCTAssertNotNil(controller.currentUser)
        XCTAssertNotNil(controller.bearer)
    }
    
    func testSetUserRoleUponLogin() {
        let mock = MockLoader()
        mock.data = validUserJSON
        
        let controller = UserController(dataLoader: mock)
        let resultsExpectation = expectation(description: "Wait for login results")
        
        let user = ReturningUser(username: "bilbo", password: "baggins")
                
        controller.signIn(existingAccount: user, newAccount: nil) { result in
            resultsExpectation.fulfill()
            XCTAssertEqual(result, .success(true))
        }
        
        wait(for: [resultsExpectation], timeout: 2)
        XCTAssertEqual(controller.userRole, .diner)
    }
    
}
