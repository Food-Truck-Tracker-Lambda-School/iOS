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
    let defaultImage = UIImage(named: "plateFood")
    var itemId: Int?
    var indexPath: Int? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Private Functions
    
    private func updateView() {
        if let itemId = itemId,
           let indexPath = indexPath {
            switch indexPath {
            case 1:
                let imageKey = itemId * 100
                if let imageString = ImageController.shared.secondStrings[imageKey],
                   !imageString.isEmpty {
                    fetchImage(imageString)
                }
            default:
                if let imageString = ImageController.shared.itemImageStrings[itemId],
                   !imageString.isEmpty {
                    fetchImage(imageString)
                }
            }
        }
        guard let photo = photo  else {
            itemImageView.image = defaultImage
            return
        }
        let imageString = photo.url
        fetchImage(imageString)
    }
    
    private func fetchImage(_ imageString: String) {
        APIController.shared.fetchImage(at: imageString) { result in
            switch result {
            case .success(let fetchedImage):
                DispatchQueue.main.async {
                    self.itemImageView.image = fetchedImage
                }
            default:
                self.itemImageView.image = self.defaultImage
            }
        }
    }
    
}
