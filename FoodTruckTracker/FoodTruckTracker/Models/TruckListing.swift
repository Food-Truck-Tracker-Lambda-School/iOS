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
    var departureTime: Date = Date() + (4 * 60 * 60)
    var cuisine: String
    var imageString: String
    var menu: [MenuItem] = []
    var ratings: [Int] = []
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        identifier = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(String.self, forKey: .location)
//        departureTime = try container.decode(Date.self, forKey: .departureTime)
        let cuisineId = try container.decode(Int.self, forKey: .cuisineId)
        cuisine = Cuisine.allCases[cuisineId].rawValue
        imageString = try container.decode(String.self, forKey: .photoUrl)
    }
}
