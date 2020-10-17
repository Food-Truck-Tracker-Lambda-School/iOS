//
//  Constants.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/17/20.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case noData
    case failedLogin
    case noToken
    case tryAgain
    case failedDecoding
    case failedEncoding
    case failedResponse
    case noIdentifier
    case noRep
    case otherError
}

enum UserType {
    case diner
    case owner
}

enum Cuisine: String, CaseIterable {
    case other = "Other"
    case african = "African"
    case american = "American"
    case asian = "Asian"
    case cuban = "Cuban"
    case european = "European"
    case mexican = "Mexican"
    case middleEastern = "Middle Eastern"
    case southAmerican = "South American"
    case bakery = "Bakery"
    case breakfast = "Breakfast"
    case treats = "Treats"
}
