//
//  MenuTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/15/20.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemDescriptionLabel: UILabel!
    @IBOutlet private weak var itemPriceLabel: UILabel!
    @IBOutlet private weak var itemRatingLabel: UILabel!
    
    // MARK: - Properties
    
    static let reuseIdentifier = "MenuListCell"
    var item: MenuItem? {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        guard let item = item else { return }
        itemNameLabel.text = item.name
        itemDescriptionLabel.text = item.description
        let priceString = String(format: "%.2f", item.price)
        itemPriceLabel.text = "$\(priceString)"
        updateImageView()
        averageRating()
    }
    
    private func updateImageView() {
        guard let item = item,
              !item.photos.isEmpty else {
            itemImageView.image = UIImage(named: "plateFood")
            return
        }
        let imageString = item.photos[0].url
        APIController.shared.fetchImage(at: imageString) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.itemImageView.image = image
                }
            default:
                self.itemImageView.image = UIImage(named: "plateFood")
            }
        }
    }
    
    private func averageRating() {
        guard let item = item,
              !item.ratings.isEmpty else {
            itemRatingLabel.text = "No ratings yet"
            return
        }
        let ratingSum = item.ratings.reduce(0, +)
        let average = Int(ratingSum / item.ratings.count)
        switch average {
        case 1:
            itemRatingLabel.text = "⭐️"
        case 2:
            itemRatingLabel.text = "⭐️⭐️"
        case 3:
            itemRatingLabel.text = "⭐️⭐️⭐️"
        case 4:
            itemRatingLabel.text = "⭐️⭐️⭐️⭐️"
        case 5:
            itemRatingLabel.text = "⭐️⭐️⭐️⭐️⭐️"
        default:
            itemRatingLabel.text = "No Ratings"
        }
    }

}
