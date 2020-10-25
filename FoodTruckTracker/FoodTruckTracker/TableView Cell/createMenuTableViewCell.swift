//
//  createMenuTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/17/20.
//

import UIKit

class CreateMenuTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var menuItemImageView: UIImageView!
    @IBOutlet private weak var menuItemName: UILabel!
  
    @IBOutlet private weak var menuDescriptionLabel: UILabel!
    @IBOutlet private weak var menuItemPriceLabel: UILabel!
    
    // MARK: - Properties
    
    static let reuseIdentifier = "CreateMenuCell"
    
    var menuItem: MenuItem? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Private Functions
    
    private func updateView() {
        guard let menuItem = menuItem else { return }
        menuItemName.text = menuItem.name
        menuDescriptionLabel.text = menuItem.description
        let priceString = String(format: "%.2f", menuItem.price)
        menuItemPriceLabel.text = "$\(priceString)"
        updateImageView()
    }
    
    private func updateImageView() {
        if let imageArray = ImageController.shared.getUIImage(nil, nil, menuItem) {
            menuItemImageView.image = imageArray[0]
        } else {
            guard let menuItem = menuItem,
                  !menuItem.photos.isEmpty else {
                self.menuItemImageView.image = UIImage(named: "plateFood")
                return
            }
            let photo = menuItem.photos[0]
            let imageString = photo.url
            APIController.shared.fetchImage(at: imageString) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.menuItemImageView.image = image
                    }
                default:
                    DispatchQueue.main.async {
                        self.menuItemImageView.image = UIImage(named: "plateFood")
                    }
                }
            }
        }
    }

}
