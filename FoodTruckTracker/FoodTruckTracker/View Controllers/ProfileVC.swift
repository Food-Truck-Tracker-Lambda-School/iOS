//
//  ProfileVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit
import CoreData

class ProfileVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    lazy var fetchedResultsController: NSFetchedResultsController<Truck> = {
        let fetchRequest: NSFetchRequest<Truck> = Truck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cuisine", ascending: true)]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "cuisine", cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            NSLog("Unable to fetch trucks from main context: \(error)")
        }
        return frc
    }()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        APIController.shared.getFavorites { _ in }
        updateView()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTruckSegue" {
            if let editTruckVC = segue.destination as? CreateTruckVC,
               let indexPath = tableView.indexPathForSelectedRow {
                let truck = fetchedResultsController.object(at: indexPath)
                editTruckVC.truck = truck
            }
        } else if segue.identifier == "editMenuSegue" {
            if let editMenuVC = segue.destination as? CreateMenuVC,
               let indexPath = tableView.indexPathForSelectedRow {
                let truck = fetchedResultsController.object(at: indexPath)
                editMenuVC.truck = truck
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func updateView() {
        guard let userRole = APIController.shared.userRole else { return }
        if userRole == .owner {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = .systemGray
            title = "My Trucks"
        } else {
            title = "My Favorite Trucks"
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .clear
        }
    }
    

} // ProfileVC

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.resuseIdentifier, for: indexPath) as? ProfileTableViewCell else { fatalError("Error") }
        cell.truck = fetchedResultsController.object(at: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "AddImageViewController") as? AddImageViewController {
                let truck = fetchedResultsController.object(at: indexPath)
                vc.truck = truck
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        fetchedResultsController.fetchedObjects?[section].cuisine
    }
    
    func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let truck = fetchedResultsController.object(at: indexPath)
            let truckId = Int(truck.identifier)
            APIController.shared.removeTruck(truckId: truckId) { _ in
                let moc = CoreDataStack.shared.mainContext
                moc.delete(truck)
                do {
                    try moc.save()
                } catch {
                    moc.reset()
                    NSLog("Error saving managed object context: \(error)")
                }
            }
        }
    }
    
}//

extension ProfileVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                  let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
    
}

extension ProfileVC: ProfileCellDelegate {
    func didTapButton(cell: ProfileTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
    }
}
