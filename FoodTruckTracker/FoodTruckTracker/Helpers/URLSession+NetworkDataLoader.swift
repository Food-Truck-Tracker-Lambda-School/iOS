//
//  URLSession+NetworkDataLoader.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

extension URLSession: NetworkDataLoader {
    
    func dataRequest(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = self.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
    }
    
}
