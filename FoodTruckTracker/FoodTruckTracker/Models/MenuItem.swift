//
//  MenuItem.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

struct MenuItem: Codable {
    var id: Int
    var name: String
    var price: Double
    var description: String
    var photos: [Photo] = []
    var ratings: [Int] = []
}
