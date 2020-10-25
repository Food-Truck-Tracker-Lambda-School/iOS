//
//  RatingController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/24/20.
//

import UIKit

class RatingController {
    
    static let shared = RatingController()
    
    init() { }
    
    func averageRating(ratings: [Int]) -> Int {
        guard !ratings.isEmpty else { return 0 }
        let ratingSum = ratings.reduce(0, +)
        return Int(ratingSum / ratings.count)
    }
    
    func averageRatingReturnsStars(ratings: [Int]) -> String {
        guard !ratings.isEmpty else { return "" }
        let ratingSum = ratings.reduce(0, +)
        let average = Int(ratingSum / ratings.count)
        switch average {
        case 1:
            return "⭐️"
        case 2:
            return "⭐️⭐️"
        case 3:
            return "⭐️⭐️⭐️"
        case 4:
            return "⭐️⭐️⭐️⭐️"
        case 5:
            return "⭐️⭐️⭐️⭐️⭐️"
        default:
            return ""
        }
    }
    
}
