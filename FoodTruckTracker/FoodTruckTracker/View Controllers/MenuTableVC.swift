//
//  MenuTableVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit

class MenuTableVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var truck: TruckListing? {
        didSet {
            guard let truck = truck,
                  let identifier = truck.identifier else { return }
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
    
    lazy var menu = truck?.menu {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMenuDetailVC" {
            if let detailVC = segue.destination as? MenuDetailVC,
               let menu = menu,
               let index = tableView.indexPathForSelectedRow {
                detailVC.item = menu[index.row]
            }
        }
    }

}//

extension MenuTableVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.reuseIdentifier, for: indexPath) as? MenuTableViewCell else { fatalError("Can't dequeue of type \(MenuTableViewCell.reuseIdentifier)") }
        if let menu = menu {
            cell.item = menu[indexPath.row]
        }
        return cell
    }
    
}
