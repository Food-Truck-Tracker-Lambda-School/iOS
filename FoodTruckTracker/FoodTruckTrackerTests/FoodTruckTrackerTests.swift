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
        
        let controller = APIController(dataLoader: mock)
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
        
        let controller = APIController(dataLoader: mock)
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
        
        let controller = APIController(dataLoader: mock)
        let resultsExpectation = expectation(description: "Wait for results")
        
        let user = ReturningUser(username: "bilbo", password: "baggins")
                
        controller.signIn(existingAccount: user, newAccount: nil) { result in
            resultsExpectation.fulfill()
            XCTAssertEqual(result, .success(true))
        }
        
        wait(for: [resultsExpectation], timeout: 2)
        XCTAssertEqual(controller.userRole, .diner)
    }
    
    func testFetchAllTrucksWithoutTokenShouldReturnNoResults() {
        let mock = MockLoader()
        mock.data = validTrucksJSON
        
        var truckArray: [TruckListing] = []
        var errorCode: NetworkError?
        
        let controller = APIController(dataLoader: mock)
        let resultsExpectation = expectation(description: "Wait for truck results")
        
        controller.fetchAllTrucks { result in
            switch result {
            case .success(let trucks):
                truckArray = trucks
            case .failure(let error):
                errorCode = error
            }
            resultsExpectation.fulfill()
        }
        
        wait(for: [resultsExpectation], timeout: 2)
        XCTAssertEqual(errorCode, .noToken)
        XCTAssertEqual(truckArray.count, 0)
    }
    
    func testFetchAllTrucksWithTokenShouldReturnResults() {
        let mock = MockLoader()
        mock.data = validTrucksJSON
        
        var truckArray: [TruckListing] = []
        var errorCode: NetworkError?
        
        let controller = APIController(dataLoader: mock)
        
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJqZWN0IjoxLCJ1c2VybmFtZSI6ImJpbGJvIiwiaWF0IjoxNjAyOTY2MDEwLCJleHAiOjE2MDMwNTI0MTB9.eYb4_8K2RS0I8QMMSfVcIJemPLtt5CiY05_8B1nl9p4"
        controller.bearer = Bearer(id: 1, token: token)
        
        let resultsExpectation = expectation(description: "Wait for truck results")
        
        controller.fetchAllTrucks { result in
            switch result {
            case .success(let trucks):
                truckArray = trucks
            case .failure(let error):
                errorCode = error
            }
            resultsExpectation.fulfill()
        }
        
        wait(for: [resultsExpectation], timeout: 2)
        XCTAssertNil(errorCode)
        XCTAssertNotEqual(truckArray.count, 0)
        XCTAssertEqual(truckArray[1].cuisine, "Cuban")
    }
    
    func testfetchRatingsForTruck() {
        let mock = MockLoader()
        mock.data = validTruckRatings
        
        var ratingsArray: [Int] = []
        var errorCode: NetworkError?
        
        let controller = APIController(dataLoader: mock)
        
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJqZWN0IjoxLCJ1c2VybmFtZSI6ImJpbGJvIiwiaWF0IjoxNjAyOTY2MDEwLCJleHAiOjE2MDMwNTI0MTB9.eYb4_8K2RS0I8QMMSfVcIJemPLtt5CiY05_8B1nl9p4"
        controller.bearer = Bearer(id: 1, token: token)
        
        let resultsExpectation = expectation(description: "Wait for ratings results")
        
        controller.fetchTruckRatings(truckId: 1) { result in
            switch result {
            case .success(let ratings):
                ratingsArray = ratings
            case .failure(let error):
                errorCode = error
            }
            resultsExpectation.fulfill()
        }
        
        wait(for: [resultsExpectation], timeout: 2)
        XCTAssertNil(errorCode)
        XCTAssertEqual(ratingsArray.count, 5)
    }
    
}
