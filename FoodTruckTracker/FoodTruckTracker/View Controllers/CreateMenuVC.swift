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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemImageSegue" {
            if let imageVC = segue.destination as? AddImageViewController,
               let indexPath = tableView.indexPathForSelectedRow,
               let truckInfo = truckListing,
               let menu = menu {
                let item = menu[indexPath.row]
                imageVC.truckListing = truckInfo
                imageVC.item = item
            }
        }
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
                self.itemNameTextField.text?.removeAll()
                self.priceTextField.text?.removeAll()
                self.descriptionTextField.text = "Description"
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
    }
    
    // MARK: - Private Functions
    
    private func setUpView() {
        truckImageView.image = UIImage(named: "plateFood")
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
    
    func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let menu = menu,
                  let truckListing = truckListing,
                  let truckId = truckListing.identifier else { return }
            let item = menu[indexPath.row]
            APIController.shared.deleteMenuItem(item: item, truckId: truckId) { result in
                switch result {
                case .success(let newMenu):
                    DispatchQueue.main.async {
                        self.menu = newMenu
                    }
                default:
                    self.presentFTAlertOnMainThread(title: "Error", message: "Failed to deleted menu item.", buttonTitle: "OK")
                }
            }
        }
    }
    
}
