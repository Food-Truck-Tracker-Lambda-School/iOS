//
//  ImageController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/25/20.
//

import UIKit

class ImageController {
    
    static let shared = ImageController()
    
    init() { }
    
    var itemImageCounts: [Int: Int] = [4: 1, 5: 1, 6: 2, 7: 1, 8: 1, 9: 1, 10: 2, 11: 1, 12: 1, 13: 1]
    
    func getUIImage(_ truck: Truck?, _ truckListing: TruckListing?, _ item: MenuItem?) -> [UIImage]? {
        var imageName: String
        var imageArray: [UIImage] = []
        if let truck = truck {
            imageName = "truck\(Int(truck.identifier))"
            if let image = UIImage(named: imageName) {
                imageArray.append(image)
            } else {
                imageArray.append(UIImage(named: "FoodTruckPhoto")!)
            }
        } else if let truckListing = truckListing,
                  let identifier = truckListing.identifier {
            imageName = "truck\(identifier)"
            if let image = UIImage(named: imageName) {
                imageArray.append(image)
            } else {
                imageArray.append(UIImage(named: "FoodTruckPhoto")!)
            }
        } else if let item = item,
                  let identifier = item.id {
            let imageCount = itemImageCounts[identifier] ?? 0
            if imageCount == 0 {
                imageArray.append(UIImage(named: "plateFood")!)
            } else {
                for index in 1...imageCount {
                    let imageName = "item\(identifier)-\(index)"
                    if let image = UIImage(named: imageName) {
                        imageArray.append(image)
                    } else {
                        imageArray.append(UIImage(named: "plateFood")!)
                    }
                }
            }
        }
        return imageArray
    }
    
}
