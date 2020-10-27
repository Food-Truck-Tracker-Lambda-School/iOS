//
//  ImageController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/25/20.
//

import UIKit

// The purpose of this class is to provide image functionality while waiting for the web dev back end
// to finish the server side of image uploads
// Two phases of temporary image functionality are present
// The first uses "dummy data" saved in the Assets file
// The second uses photos uploaded through the app to a different Cloudinary account, and
// hard coded urlStrings from those uploads.

// There are seven ViewControllers/Views that include modified code to account for this:
// ProfileVC (custom cell), CreateMenuVC (custom cell), AddImageViewController, TrucksListTableView Controller (custom cell), TruckDetailVC, MenuTableVC (custom cell), MenuDetailVC (custom cell)

class ImageController {
    
    static let shared = ImageController()
    
    init() { }
    
    var itemImageCounts: [Int: Int] = [4: 1, 5: 1, 6: 2, 7: 1, 8: 1, 9: 1, 10: 2, 11: 1, 13: 1, 15: 1]
    
    var truckImageStrings: [Int: String] = [
        3: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603687005/eowwn2slpmfvca4vukaa.jpg",
        4: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603749236/e5xl5qtsbeobqva50jsj.jpg",
        5: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603749030/yfzappeop8osqdemskbn.jpg",
        6: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603745796/seezxt60irjerbuo107w.jpg"
    ]
    
    var itemImageStrings: [Int: String] = [
        4: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603754052/d705cyxjw3vmpv8ajnvi.jpg",
        5: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603754167/ave0fpnc2bha1ttrll8l.jpg",
        6: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603754216/sfawihcs9vnvpjkk7oww.jpg",
        7: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603754312/gchxqehxr1mgvwgganca.jpg",
        8: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603753670/dx3dbq383fs3fjbqfwrs.jpg",
        9: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603753742/tnz8d3yenbios6yq3yeq.jpg",
        10: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603753798/ini1ylpfbxu6ycd6trnh.jpg",
        11: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603752061/zflgnoqchpqiu68oipy4.jpg",
        13: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603753284/lh7vffwmtaifc6klluip.jpg",
        15: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603752728/r1vmttqy2lm0rcvdko33.jpg"
    ]
    
    var secondStrings: [Int: String] = [
        600: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603754254/bhlrv5lbxggxs78sp4d3.jpg",
        1000: "https://res.cloudinary.com/communitycalendar1/image/upload/v1603754005/nprcbud0vgg4bovq3jkq.jpg"
    ]
    
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
