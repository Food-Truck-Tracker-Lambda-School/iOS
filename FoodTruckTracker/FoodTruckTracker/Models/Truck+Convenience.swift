//
//  Truck+Convenience.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/14/20.
//

import Foundation
import CoreData

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

extension Truck {
    
    var truckRepresentation: TruckRepresentation? {
        guard let name = name,
              let cuisine = cuisine,
              let imageString = imageString else { return nil }
        return TruckRepresentation(identifier: Int(identifier),
                                   name: name,
                                   cuisine: cuisine,
                                   imageString: imageString)
    }
    
    @discardableResult convenience init(identifier: Int,
                                        name: String,
                                        cuisine: Cuisine,
                                        imageString: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = Int16(identifier)
        self.name = name
        self.cuisine = cuisine.rawValue
        self.imageString = imageString
    }
    
    @discardableResult convenience init?(truckRepresentation: TruckRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let cuisine = Cuisine(rawValue: truckRepresentation.cuisine) else { return nil }
        self.init(identifier: truckRepresentation.identifier,
                  name: truckRepresentation.name,
                  cuisine: cuisine,
                  imageString: truckRepresentation.imageString,
                  context: context)
    }
    
}
