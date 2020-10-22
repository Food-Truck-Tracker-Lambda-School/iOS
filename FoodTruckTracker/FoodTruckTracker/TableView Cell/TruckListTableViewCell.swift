//
//  TruckListTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/22/20.
//

import UIKit

class TruckListTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var truckImageView: UIImageView!
    @IBOutlet private weak var truckNameLabel: UILabel!
    @IBOutlet private weak var cuisineTypeLabel: UILabel!
    
    // MARK: - Properties
    
    static let reuseIdentifier = "TruckListCell"
    var truck: TruckListing? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Actions
    
    private func updateViews() {
        truckNameLabel.text = truck?.name
        cuisineTypeLabel.text = truck?.cuisine
        truckImageView.image = UIImage(named: "FoodTruckPhoto")
    }

}
