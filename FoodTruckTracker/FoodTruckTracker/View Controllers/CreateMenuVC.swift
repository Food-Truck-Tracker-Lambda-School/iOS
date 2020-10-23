//
//  CreateMenuVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/17/20.
//

import UIKit

class CreateMenuVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var truckImageView: UIImageView!
    @IBOutlet private weak var itemNameTextField: UITextField!
    @IBOutlet private weak var priceTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextView!
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var truck: Truck?
    var truckListing: TruckListing? {
        didSet {
            guard let truckListing = truckListing,
                  let identifier = truckListing.identifier else { return }
            APIController.shared.fetchTruckMenu(truckId: identifier) { result in
                switch result {
                case .success(let truckMenu):
                    DispatchQueue.main.async {
                        self.menu = truckMenu
                    }
                default:
                    NSLog("Failed to get menu")
                }
            }
        }
    }
    var menu: [MenuItem]? {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUpView()
    }
    
    // MARK: - Actions
    
    @IBAction func addMenuButton(_ sender: UIButton) {
        guard let name = itemNameTextField.text, !name.isEmpty else { return }
        guard let description = descriptionTextField.text, !description.isEmpty else { return }
        guard let priceString = priceTextField.text, !priceString.isEmpty,
              let price = Double(priceString) else { return }
        guard let truckListing = truckListing,
              let identifier = truckListing.identifier else { return }
                
        let item = MenuItem(name: name, price: price, description: description)
        
        APIController.shared.createMenuItem(item: item, truckId: identifier) { _ in
            self.presentFTAlertOnMainThread(title: "Success", message: "Your menu item was created.", buttonTitle: "OK")
            DispatchQueue.main.async {
                self.setUpView()
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func setUpView() {
        if let truck = truck {
            APIController.shared.fetchSingleTruck(truck: truck) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let truckData):
                        self.truckListing = truckData
                        self.title = "Menu for \(truckData.name)"
                    default:
                        self.title = "Error - do not edit this menu"
                    }
                }
            }
        } else {
            title = "Error - no truck selected"
        }
    }

} // CreateMenuVC


extension CreateMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateMenuTableViewCell.reuseIdentifier, for: indexPath) as? CreateMenuTableViewCell else { fatalError("Error") }
        if let menu = menu,
           !menu.isEmpty {
            cell.menuItem = menu[indexPath.row]
        }
        return cell
    }
    
}
