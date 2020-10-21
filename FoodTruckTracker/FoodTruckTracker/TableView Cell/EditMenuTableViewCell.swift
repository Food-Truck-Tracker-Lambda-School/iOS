//
//  EditMenuTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/20/20.
//

import UIKit

class EditMenuTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemNameLabel: UILabel!
    @IBOutlet weak var menuDescriptionLabel: UILabel!
    @IBOutlet weak var menuItemPriceLabel: UILabel!
    
    
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
