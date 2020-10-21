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
    
    @IBOutlet weak var editTruckBtn: UIButton!
    @IBOutlet weak var editMenuBtn: UIButton!
    
    // MARK: - Properties
    static let resuseIdentifier = "ProfileTableCell"
    var truck: Truck? {
        didSet {
            updateViews()
        }
    }
    
    
    private func updateViews() {
        truckNameLabel.text = truck?.name
        cuisineTypeLabel.text = truck?.cuisine
        truckImageView.image = UIImage(named: "FoodTruckPhoto")
    }//
    
    
    @IBAction func editTruckButton(_ sender: UIButton) {
    }
    
    @IBAction func editMenuButton(_ sender: UIButton) {
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
