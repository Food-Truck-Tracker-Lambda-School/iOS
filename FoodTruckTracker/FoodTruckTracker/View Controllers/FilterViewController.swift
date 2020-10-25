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
    func setFilters(filters: Filters)
}

class FilterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var ratingControl: UISegmentedControl!
    @IBOutlet private weak var distanceSlider: UISlider!
    @IBOutlet private weak var locationLabel: UILabel!
    
    // MARK: - Properties
    
    var trucks: [TruckListing]?
    var filteredTrucks: [TruckListing]?
    var location: CLLocationCoordinate2D?
    var filters: Filters?
    weak var delegate: FilterVCDelegate?
    private var cuisineTypes = Cuisine.allCases.map { $0.rawValue }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cuisineTypes.insert("All Cuisines", at: 0)
        pickerView.delegate = self
        pickerView.dataSource = self
        setFilters()
    }
    
    // MARK: - Actions - Public
    
    @IBAction func applyFilters(_ sender: UIButton) {
        guard var filteredTrucks = filteredTrucks else { return }
        let trucksByCuisine = filterByCuisine(filteredTrucks)
        let trucksByRating = filterByRating(trucksByCuisine)
        
        getLocalTruckIds { idArray in
            var newArray: [TruckListing] = []
            if !idArray.isEmpty {
                for truck in trucksByRating {
                    if let truckId = truck.identifier {
                        if idArray.contains(truckId) {
                            newArray.append(truck)
                        }
                    }
                }
            } else {
                newArray = trucksByRating
            }
            if newArray.isEmpty {
                DispatchQueue.main.async {
                    self.clearFilters()
                    self.presentFTAlertOnMainThread(title: "No search results", message: "Please make a different selection.", buttonTitle: "Ok")
                }
                return
            }
            DispatchQueue.main.async {
                filteredTrucks = newArray
                self.delegate?.filterTrucks(filteredTrucks: filteredTrucks)
                if let filters = self.filters {
                    self.delegate?.setFilters(filters: filters)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func clearFilters() {
        filteredTrucks = trucks
        filters?.cuisineId = 0
        filters?.ratingSelection = 0
        filters?.radius = nil
        setFilters()
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        let radius = Int(sender.value)
        switch radius {
        case 1:
            locationLabel.text = "Filter by Location - within 1 mile"
        default:
            locationLabel.text = "Filter by Location - within \(radius) miles"
        }
    }
    
    // MARK: - Actions - Private
    
    private func filterByCuisine(_ trucks: [TruckListing]) -> [TruckListing] {
        let cuisineId = (pickerView.selectedRow(inComponent: 0)) - 1
        filters?.cuisineId = cuisineId + 1
        var newArray: [TruckListing] = []
        if cuisineId != -1 {
            for truck in trucks where truck.cuisineId == cuisineId {
                newArray.append(truck)
            }
        } else {
            newArray = trucks
        }
        return newArray
    }
    
    private func filterByRating(_ trucks: [TruckListing]) -> [TruckListing] {
        let ratingSelection = ratingControl.selectedSegmentIndex
        filters?.ratingSelection = ratingSelection
        var newArray: [TruckListing] = []
        if ratingSelection != 0 {
            for truck in trucks {
                let average = RatingController.shared.averageRating(ratings: truck.ratings)
                if average >= ratingSelection {
                    newArray.append(truck)
                }
            }
        } else {
            newArray = trucks
        }
        return newArray
    }
        
    private func getLocalTruckIds(completion: @escaping ([Int]) -> Void) {
        var idArray: [Int] = []
        guard let location = location else {
            completion(idArray)
            return
        }
        let latitude = String(location.latitude)
        let longitude = String(location.longitude)
        let radius = Int(distanceSlider.value)
        filters?.radius = radius
        APIController.shared.fetchLocalTrucks(latitude: latitude, longitude: longitude, radius: radius) { result in
            switch result {
            case .success(let trucks):
                idArray = trucks.map { ($0.identifier ?? 0) }
            case .failure(let error):
                print(error)
            }
            completion(idArray)
        }
    }
    
    private func setFilters() {
        if let filters = filters {
            if let cuisineId = filters.cuisineId {
                pickerView.selectRow(cuisineId, inComponent: 0, animated: true)
            }
            if let ratingSelection = filters.ratingSelection {
                ratingControl.selectedSegmentIndex = ratingSelection
            }
            if let radius = filters.radius {
                distanceSlider.value = Float(radius)
                switch radius {
                case 1:
                    locationLabel.text = "Filter by Location - within 1 mile"
                default:
                    locationLabel.text = "Filter by Location - within \(radius) miles"
                }
            } else {
                distanceSlider.value = 25
                locationLabel.text = "Filter by Location - within 25 miles"
            }
        }
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = cuisineTypes[row]
        let myTitle = NSAttributedString(string: titleData,
                                         attributes: [NSAttributedString.Key.font: UIFont(name: "Noteworthy-Bold", size: 20.0)!,
                                                      NSAttributedString.Key.foregroundColor: UIColor.black])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .center
        let color = UIColor(red: 215 / 255, green: 127 / 255, blue: 255 / 255, alpha: 0.7)
        pickerLabel.backgroundColor = color
        return pickerLabel
    }
}
