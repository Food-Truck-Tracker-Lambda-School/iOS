//
//  FilterViewController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/21/20.
//

import UIKit
import MapKit

protocol FilterVCDelegate: AnyObject {
    func filterTrucks(filteredTrucks: [TruckListing])
}

class FilterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var ratingControl: UISegmentedControl!
    @IBOutlet private weak var distanceSlider: UISlider!
    
    // MARK: - Properties
    
    var trucks: [TruckListing]?
    var filteredTrucks: [TruckListing]?
    var location: CLLocationCoordinate2D?
    weak var delegate: FilterVCDelegate?
    private var cuisineTypes = Cuisine.allCases.map { $0.rawValue }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cuisineTypes.insert("All Cuisines", at: 0)
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    // MARK: - Actions - Public
    
    @IBAction func applyFilters(_ sender: UIButton) {
        guard let trucks = trucks,
              var filteredTrucks = filteredTrucks else { return }
        if filteredTrucks.isEmpty {
            filteredTrucks = trucks
        }
        let cuisineFilter = BlockOperation {
            filteredTrucks = self.filterByCuisine(filteredTrucks)
        }
        let ratingFilter = BlockOperation {
            filteredTrucks = self.filterByRating(filteredTrucks)
        }
        var localTruckIds: [Int] = []
        let getLocalIds = BlockOperation {
            localTruckIds = self.localTruckIds()
        }
        let locationFilter = BlockOperation {
            if !localTruckIds.isEmpty {
                for index in 0..<filteredTrucks.count {
                    if let truckId = filteredTrucks[index].identifier {
                        if !localTruckIds.contains(truckId) {
                            filteredTrucks.remove(at: index)
                        }
                    }
                }
            }
        }
        let applyFilter = BlockOperation {
            self.delegate?.filterTrucks(filteredTrucks: filteredTrucks)
        }
        ratingFilter.addDependency(cuisineFilter)
        locationFilter.addDependency(ratingFilter)
        locationFilter.addDependency(getLocalIds)
        applyFilter.addDependency(locationFilter)
        let queue = OperationQueue()
        queue.addOperations([cuisineFilter, ratingFilter, getLocalIds, locationFilter, applyFilter], waitUntilFinished: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearFilters() {
        filteredTrucks = trucks
    }
    
    // MARK: - Actions - Private
    
    private func filterByCuisine(_ trucks: [TruckListing]) -> [TruckListing] {
        // pickerView - index 0 = All Cuisines, others match cuisine types (subtract 1 for correct index)
        let cuisineId = (pickerView.selectedRow(inComponent: 0)) - 1
        var newArray = trucks
        if cuisineId != -1 {
            for index in 0..<trucks.count where trucks[index].cuisineId != cuisineId {
                newArray.remove(at: index)
            }
        }
        return newArray
    }
    
    private func averageRating(_ truck: TruckListing) -> Int {
        let ratingSum = truck.ratings.reduce(0, +)
        return ratingSum / truck.ratings.count
    }
    
    private func filterByRating(_ trucks: [TruckListing]) -> [TruckListing] {
        // ratingControl Segments:
        // 0 - Any - includes trucks with no ratings
        // 1 - 1 star and up
        // 2 - 2 stars and up
        // etc.
        let ratingSelection = ratingControl.selectedSegmentIndex
        var newArray = trucks
        if ratingSelection != 0 {
            for index in 0..<trucks.count {
                let average = averageRating(trucks[index])
                if average < ratingSelection {
                    newArray.remove(at: index)
                }
            }
        }
        return newArray
    }
        
    private func localTruckIds() -> [Int] {
        guard var localTrucks = trucks,
              let location = location else { return [] }
        // distanceSlider - default value 25, 5 mile increments
        let latitude = String(location.latitude)
        let longitude = String(location.longitude)
        let radius = Int(distanceSlider.value)
        var idArray: [Int] = []
        let group = DispatchGroup()
        group.enter()
        if radius != 25 {
            APIController.shared.fetchLocalTrucks(latitude: latitude, longitude: longitude, radius: radius) { result in
                switch result {
                case .success(let trucks):
                    DispatchQueue.main.async {
                        localTrucks = trucks
                        for index in 0..<localTrucks.count {
                            if let identifier = localTrucks[index].identifier {
                                idArray.append(identifier)
                            }
                        }
                        group.leave()
                    }
                default:
                    group.leave()
                }
            }
        }
        group.wait()
        return idArray
    }

}

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        cuisineTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        cuisineTypes[row]
    }
}
