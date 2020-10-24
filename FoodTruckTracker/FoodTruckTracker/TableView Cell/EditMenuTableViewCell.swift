//
//  EditMenuTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/20/20.
//

import UIKit

class EditMenuTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet private weak var menuItemImageView: UIImageView!
    @IBOutlet private weak var menuItemNameLabel: UILabel!
    @IBOutlet private weak var menuDescriptionLabel: UILabel!
    @IBOutlet private weak var menuItemPriceLabel: UILabel!
    
    
    // MARK: - Properties
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
