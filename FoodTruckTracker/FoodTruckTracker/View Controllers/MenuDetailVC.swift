//
//  MenuDetailVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/17/20.
//

import UIKit

class MenuDetailVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var itemNameLabel: UILabel!
    @IBOutlet private weak var itemPriceLabel: UILabel!
    @IBOutlet private weak var itemDescriptionTextView: UITextView!
    @IBOutlet private weak var avgLabel: UILabel!
    @IBOutlet private weak var star1: UIButton!
    @IBOutlet private weak var star2: UIButton!
    @IBOutlet private weak var star3: UIButton!
    @IBOutlet private weak var star4: UIButton!
    @IBOutlet private weak var star5: UIButton!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var item: MenuItem?
    var truck: TruckListing?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        updateView()
    }
    
    @IBAction func rateItemButton(_ sender: UIButton) {
        guard APIController.shared.userRole == .diner else {
            self.presentFTAlertOnMainThread(title: "Error", message: "Only diners can post ratings.", buttonTitle: "Ok")
            return
        }
        setUpRating()
    }
    
    private func updateView() {
        guard let item = item,
              let truck = truck else { return }
        title = "\(item.name) at \(truck.name)"
        itemNameLabel.text = item.name
        let priceString = String(format: "%.2f", item.price)
        itemPriceLabel.text = "$\(priceString)"
        itemDescriptionTextView.text = item.description
        ratingView()
    }
    
    private func ratingView() {
        guard let item = item else { return }
        let average = averageRating(item)
        showAllStars()
        switch average {
        case 1:
            avgLabel.text = "Average Rating: 1"
            star2.isHidden = true
            star3.isHidden = true
            star4.isHidden = true
            star5.isHidden = true
        case 2:
            avgLabel.text = "Average Rating: 2"
            star3.isHidden = true
            star4.isHidden = true
            star5.isHidden = true
        case 3:
            avgLabel.text = "Average Rating: 3"
            star4.isHidden = true
            star5.isHidden = true
        case 4:
            avgLabel.text = "Average Rating: 4"
            star5.isHidden = true
        case 5:
            avgLabel.text = "Average Rating: 5"
        default:
            avgLabel.text = "Average Rating: N/A"
            star1.isHidden = true
            star2.isHidden = true
            star3.isHidden = true
            star4.isHidden = true
            star5.isHidden = true
        }
    }
    
    private func showAllStars() {
        star1.isHidden = false
        star2.isHidden = false
        star3.isHidden = false
        star4.isHidden = false
        star5.isHidden = false
    }
    
    private func averageRating(_ item: MenuItem) -> Int {
        if !item.ratings.isEmpty {
            let ratingSum = item.ratings.reduce(0, +)
            return Int(ratingSum / item.ratings.count)
        } else {
            return 0
        }
    }
    
    private func setUpRating() {
        let alert = UIAlertController(title: "Item Rating", message: "Please choose a rating.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "⭐️", style: .default, handler: { _ in
            let rating = 1
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️", style: .default, handler: { _ in
            let rating = 2
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️", style: .default, handler: { _ in
            let rating = 3
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️", style: .default, handler: { _ in
            let rating = 4
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️⭐️", style: .default, handler: { _ in
            let rating = 5
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func sendRating(_ rating: Int) {
        guard let item = self.item,
              let itemId = item.id,
              let truck = self.truck,
              let identifer = truck.identifier else {
            self.presentFTAlertOnMainThread(title: "Sorry!", message: "Unable to rate this item.", buttonTitle: "Ok")
            return
        }
        APIController.shared.postRating(ratingInt: rating, truckId: identifer, itemId: itemId) { result in
            switch result {
            case .success(true):
                self.presentFTAlertOnMainThread(title: "Thank you!", message: "We appreciate you taking the time to rate this item.", buttonTitle: "Ok")
            default:
                self.presentFTAlertOnMainThread(title: "Sorry!", message: "Unable to rate this item.", buttonTitle: "Ok")
            }
        }
    }
    
} // MenuDetailVC

extension MenuDetailVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.resuseIdentifier, for: indexPath) as? MenuCollectionViewCell else { fatalError("Failed \(MenuCollectionViewCell.self)") }
    
        
        return cell
    }
    
    
}
