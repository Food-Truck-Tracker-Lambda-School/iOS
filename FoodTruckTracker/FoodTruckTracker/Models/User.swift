//
//  User.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

struct User: Codable {
    let username: String
    let password: String?
    let roleId: Int?
    let email: String
}

struct ReturningUser: Codable {
    let username: String
    let password: String
}
