//
//  CreateMenuVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/17/20.
//

import UIKit

class CreateMenuVC: UIViewController {
    
    // Outlets
    @IBOutlet private weak var truckImageView: UIImageView!
    @IBOutlet private weak var itemNameTextField: UITextField!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextView!
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var truck: TruckListing?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    @IBAction func addMenuButton(_ sender: UIButton) {
        guard let name = itemNameTextField.text, !name.isEmpty else { return }
        guard let description = descriptionTextField.text, !description.isEmpty else { return }
        guard let priceString = priceTextField.text, !priceString.isEmpty,
              let price = Double(priceString) else { return }
        guard let truck = truck,
              let identifier = truck.identifier else { return }
        
        truckImageView.image = UIImage(named: "FoodTruckPhoto")
        
        let item = MenuItem(name: name, price: price, description: description)
        
        APIController.shared.createMenuItem(item: item, truckId: identifier) { result in
            
        }
    }
    

} // CreateMenuVC


extension CreateMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateMenuTableViewCell.reuseIdentifier, for: indexPath) as? CreateMenuTableViewCell else { fatalError("Error") }
        
        
        
        return cell
    }
    
    
}
