//
//  TruckListing.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/16/20.
//

import Foundation

struct TruckListing: Codable {
    
    enum Keys: String, CodingKey {
        case id
        case name
        case location
        case departureTime
        case cuisineId
        case photoUrl
    }
    
    var identifier: Int
    var name: String
    var location: String
    var departureTime: Date
    var cuisine: Cuisine.RawValue
    var imageString: String
    var menu: [MenuItem]
}
