//
//  MenuItem.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

struct MenuItem: Codable {
    var identifier: Int
    var name: String
    var price: Double
    var description: String
}
