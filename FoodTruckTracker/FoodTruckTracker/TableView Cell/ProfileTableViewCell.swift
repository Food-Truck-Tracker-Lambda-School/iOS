//
//  ProfileTableViewCell.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit

protocol ProfileCellDelegate: AnyObject {
    func didTapButton(cell: ProfileTableViewCell)
}

class ProfileTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var truckImageView: UIImageView!
    @IBOutlet private weak var truckNameLabel: UILabel!
    @IBOutlet private weak var cuisineTypeLabel: UILabel!
    
    @IBOutlet private weak var editTruckBtn: UIButton!
    @IBOutlet private weak var editMenuBtn: UIButton!
    
    // MARK: - Properties
    
    static let resuseIdentifier = "ProfileTableCell"
    weak var delegate: ProfileCellDelegate?
    var truck: Truck? {
        didSet {
            updateViews()
        }
    }
    
    @IBAction func editTruckButton(_ sender: UIButton) {
        delegate?.didTapButton(cell: self)
    }
    
    @IBAction func editMenuButton(_ sender: UIButton) {
        delegate?.didTapButton(cell: self)
    }
    
    // MARK: - Private Functions
    
    private func updateViews() {
        truckNameLabel.text = truck?.name
        cuisineTypeLabel.text = truck?.cuisine
        updateImageView()
        guard let userRole = APIController.shared.userRole else { return }
        if userRole != .owner {
            editTruckBtn.isHidden = true
            editMenuBtn.isHidden = true
        }
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
