//
//  MockLoader.swift
//  FoodTruckTrackerTests
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation
@testable import FoodTruckTracker

class MockLoader: NetworkDataLoader {

    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func dataRequest(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(self.data, self.response, self.error)
        }
    }
    
}
