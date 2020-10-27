//
//  TrucksTableViewController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/20/20.
//

import UIKit

class TrucksTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var filteredTrucks: [TruckListing]? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - TableView Datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTrucks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TruckListCell", for: indexPath) as? TruckListTableViewCell else { fatalError("Error") }
        if let filteredTrucks = filteredTrucks,
           !filteredTrucks.isEmpty {
            cell.truck = filteredTrucks[indexPath.row]
        }
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailVC" {
            if let detailVC = segue.destination as? TruckDetailVC,
               let filteredTrucks = filteredTrucks,
               let index = tableView.indexPathForSelectedRow {
                detailVC.truck = filteredTrucks[index.row]
            }
        }
    }

}
