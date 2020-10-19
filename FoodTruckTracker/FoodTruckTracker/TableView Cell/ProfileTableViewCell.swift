//
//  ProfileTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet private weak var truckImageView: UIImageView!
    @IBOutlet private weak var truckNameLabel: UILabel!
    @IBOutlet private weak var cuisineTypeLabel: UILabel!
    
    // MARK: - Properties
    static let resuseIdentifier = "ProfileTableCell"
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
