//
//  Truck+Convenience.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/14/20.
//

import Foundation
import CoreData

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
                                        cuisine: String,
                                        imageString: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = Int16(identifier)
        self.name = name
        self.cuisine = cuisine
        self.imageString = imageString
    }
    
    @discardableResult convenience init?(truckRepresentation: TruckRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(identifier: truckRepresentation.identifier,
                  name: truckRepresentation.name,
                  cuisine: truckRepresentation.cuisine,
                  imageString: truckRepresentation.imageString,
                  context: context)
    }
    
}
