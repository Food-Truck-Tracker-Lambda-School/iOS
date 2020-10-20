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
        case photoId
        case photoUrl
        case ratings
    }
    
    var identifier: Int?
    var name: String
    var location: String
    var departureTime: Date?
    var cuisineId: Int
    var cuisine: String?
    var photoId: Int
    var imageString: String?
    var menu: [MenuItem] = []
    var ratings: [Int] = []
    
    init(name: String,
         location: String,
         cuisineId: Int,
         cuisine: String? = nil,
         identifier: Int? = nil,
         departureTime: Date? = nil,
         photoId: Int = 1,
         imageString: String? = nil,
         menu: [MenuItem] = [],
         ratings: [Int] = []) {
        self.identifier = identifier
        self.name = name
        self.location = location
        self.departureTime = departureTime
        self.cuisineId = cuisineId
        self.cuisine = Cuisine.allCases[cuisineId].rawValue
        self.photoId = photoId
        self.imageString = imageString
        self.menu = menu
        self.ratings = ratings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        identifier = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(String.self, forKey: .location)
        cuisineId = try container.decode(Int.self, forKey: .cuisineId)
        cuisine = Cuisine.allCases[cuisineId].rawValue
        photoId = try container.decode(Int.self, forKey: .photoId)
        imageString = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        ratings = try container.decodeIfPresent([Int].self, forKey: .ratings) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(location, forKey: .location)
        try container.encode(cuisineId, forKey: .cuisineId)
        try container.encode(photoId, forKey: .photoId)
    }
}
