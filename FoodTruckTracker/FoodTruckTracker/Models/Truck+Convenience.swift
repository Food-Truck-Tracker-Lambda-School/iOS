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
        // add guard let statement
        TruckRepresentation( // add attributes
            identifier: identifier?.uuidString ?? "")
    }
    
    @discardableResult convenience init( // add attributes
                                        identifier: UUID = UUID(),
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        // add attributes
    }
    
    @discardableResult convenience init?(truckRepresentation: TruckRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: truckRepresentation.identifier) else { return nil }
        self.init( // add attributes
                  identifier: identifier,
                  context: context)
    }
    
}
