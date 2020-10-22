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
        itemPriceLabel.text = "&\(item.price)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
