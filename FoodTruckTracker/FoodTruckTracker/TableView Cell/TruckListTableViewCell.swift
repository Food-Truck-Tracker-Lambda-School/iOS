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
    
    // MARK: - Private Functions
    
    private func updateViews() {
        truckNameLabel.text = truck?.name
        cuisineTypeLabel.text = truck?.cuisine
        updateImageView()
    }
    
    private func updateImageView() {
        guard let truck = truck,
              let imageString = truck.imageString,
              !imageString.isEmpty else { return }
        APIController.shared.fetchImage(at: imageString) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.truckImageView.image = image
                }
            default:
                return
            }
        }
    }

}
