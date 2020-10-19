//
//  MenuItem.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

struct MenuItem: Codable {
    
    enum Keys: String, CodingKey {
        case name
        case price
        case description
    }
    
    var id: Int?
    var name: String
    var price: Double
    var description: String
    var photos: [Photo] = []
    var ratings: [Int] = []
    
    init(name: String,
         price: Double,
         description: String,
         id: Int? = nil,
         photos: [Photo] = [],
         ratings: [Int] = []) {
        self.name = name
        self.price = price
        self.description = description
        self.photos = photos
        self.ratings = ratings
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(description, forKey: .description)
    }
}
