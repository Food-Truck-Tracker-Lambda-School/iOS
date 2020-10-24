//
//  MenuCollectionViewCell.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/17/20.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var itemImageView: UIImageView!
    
    // MARK: - Properties
    
    static let reuseIdentifier = "MenuItemCell"
    var photo: Photo? {
        didSet {
            updateView()
        }
    }
    var image = UIImage(named: "plateFood") {
        didSet {
            itemImageView.image = image
        }
    }
    
    // MARK: - Private Functions
    
    private func updateView() {
        guard let photo = photo  else {
            return
        }
        let imageString = photo.url
        APIController.shared.fetchImage(at: imageString) { result in
            switch result {
            case .success(let fetchedImage):
                DispatchQueue.main.async {
                    self.itemImageView.image = fetchedImage
                }
            default:
                self.itemImageView.image = self.image
            }
        }
    }
    
}
