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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    

} // CreateMenuVC


extension CreateMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateMenuTableViewCell.reuseIdentifier, for: indexPath) as? CreateMenuTableViewCell else { fatalError("Error") }
        
        // Configure Cell
        
        return cell
    }
    
    
}
