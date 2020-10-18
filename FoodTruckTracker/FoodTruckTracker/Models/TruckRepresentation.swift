//
//  TruckRepresentation.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/14/20.
//

import Foundation

struct TruckRepresentation: Codable {
    var identifier: Int
    var name: String
    var cuisine: String
    var imageString: String
}
