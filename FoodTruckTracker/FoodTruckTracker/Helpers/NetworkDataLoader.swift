//
//  NetworkDataLoader.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

protocol NetworkDataLoader {
    
    func dataRequest(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void)

}
