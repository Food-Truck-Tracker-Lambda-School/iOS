//
//  CreateTruckVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/17/20.
//

import UIKit
import MapKit

class CreateTruckVC: UIViewController {
    
    // Outlets
    @IBOutlet private weak var truckNameTextField: UITextField!
    @IBOutlet private weak var cuisineTypePickerView: UIPickerView!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var latitudeTextField: UITextField!
    @IBOutlet private weak var longitudeTextField: UITextField!
    @IBOutlet private weak var mapView: MKMapView!
    
    // MARK: - Properties
    
    var truck: Truck?
    var truckListing: TruckListing?
    var truckPin = MKPointAnnotation()
    var editMode: Bool = false
    
    fileprivate let locationManager = CLLocationManager()
    var span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    var userLocation: CLLocationCoordinate2D?
    
    private let cuisineTypes = Cuisine.allCases.map { $0.rawValue }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cuisineTypePickerView.delegate = self
        cuisineTypePickerView.dataSource = self
        setUpMap()
        setUpView()
    }
    
    // MARK: - Actions
    
    @IBAction func useAddressButton(_ sender: UIButton) {
        guard let address = addressTextField.text else { return }
        reverseGeocode(address: address) { placemark in
            if let latitude = placemark.location?.coordinate.latitude,
               let longitude = placemark.location?.coordinate.longitude {
                self.truckPin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self.mapView.showAnnotations([self.truckPin], animated: true)
                self.latitudeTextField.text = String(latitude)
                self.longitudeTextField.text = String(longitude)
            } else {
                self.presentFTAlertOnMainThread(title: "Error", message: "Please enter a valid address", buttonTitle: "OK")
            }
        }
    }
    
    @IBAction func useCoordinatesButton(_ sender: UIButton) {
        if let latText = latitudeTextField.text,
           let longText = longitudeTextField.text {
            if let latitude = Double(latText),
               let longitude = Double(longText) {
                addressTextField.text?.removeAll()
                truckPin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapView.showAnnotations([truckPin], animated: true)
            }
        }
    }
    
    @IBAction func useMyLocationButton(_ sender: UIButton) {
        if let userLocation = userLocation {
            truckPin.coordinate = userLocation
            mapView.showAnnotations([truckPin], animated: true)
            latitudeTextField.text = String(userLocation.latitude)
            longitudeTextField.text = String(userLocation.longitude)
        }
    }
    
    @IBAction func clearPinsButton(_ sender: UIButton) {
        let pins = [truckPin]
        mapView.removeAnnotations(pins)
        latitudeTextField.text?.removeAll()
        longitudeTextField.text?.removeAll()
        addressTextField.text?.removeAll()
        if let userLocation = userLocation {
            let coordinateRegion = MKCoordinateRegion(center: userLocation, span: self.span)
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let name = truckNameTextField.text, !name.isEmpty else { return }
        let latitude = String(truckPin.coordinate.latitude)
        let longitude = String(truckPin.coordinate.longitude)
        let location = "\(latitude) \(longitude)"
        let cuisineId = cuisineTypePickerView.selectedRow(inComponent: 0)
        let truck = TruckListing(name: name, location: location, cuisineId: cuisineId)
        switch editMode {
        case true:
            guard var newTruckInfo = truckListing,
                  let truckId = newTruckInfo.identifier else {
                presentFTAlertOnMainThread(title: "Error", message: "Problem finding truck to edit.", buttonTitle: "OK")
                return
            }
            newTruckInfo.name = name
            newTruckInfo.location = location
            newTruckInfo.cuisineId = cuisineId
            APIController.shared.editTruck(truckId: truckId, newTruckInfo: newTruckInfo) { result in
                switch result {
                case .success(true):
                    self.presentFTAlertOnMainThread(title: "Success", message: "Your truck has been edited.", buttonTitle: "OK")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        APIController.shared.getFavorites { _ in }
                    }
                case .failure(let error):
                    self.presentFTAlertOnMainThread(title: "Error", message: "Failed editing truck", buttonTitle: "OK")
                    print("Failed editing truck: \(error)")
                default:
                    return
                }
            }
        case false:
            APIController.shared.createTruck(truck: truck) { result in
                switch result {
                case .success(true):
                    self.presentFTAlertOnMainThread(title: "Success", message: "Your truck has been created.", buttonTitle: "OK")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        APIController.shared.getFavorites { _ in }
                    }
                case .failure(let error):
                    self.presentFTAlertOnMainThread(title: "Error", message: "Failed to create truck.", buttonTitle: "OK")
                    print("Failed Creating Truck \(error)")
                default:
                    return
                }
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func setUpMap() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    private func setUpView() {
        if let truck = truck {
            let truckId = Int(truck.identifier)
            APIController.shared.fetchSingleTruck(truckId: truckId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let truckData):
                        self.truckListing = truckData
                        self.editMode = true
                        self.title = "Edit \(truckData.name)"
                        self.truckNameTextField.text = truckData.name
                        self.cuisineTypePickerView.selectRow(truckData.cuisineId, inComponent: 0, animated: true)
                        let coordinateArray = truckData.location.components(separatedBy: " ")
                        if let latitude = Double(coordinateArray[0]),
                           let longitude = Double(coordinateArray[1]) {
                            self.latitudeTextField.text = String(latitude)
                            self.longitudeTextField.text = String(longitude)
                            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = location
                            annotation.title = truckData.name
                            annotation.subtitle = truckData.cuisine
                            self.truckPin = annotation
                            self.mapView.showAnnotations([self.truckPin], animated: false)
                            let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, span: self.span)
                            self.mapView.setRegion(coordinateRegion, animated: true)
                        }
                    default:
                        self.title = "Error - do not edit this truck"
                    }
                }
            }
        } else {
            title = "Create Truck"
        }
    }
    
    private func reverseGeocode(address: String, completion: @escaping (CLPlacemark) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let placemarks = placemarks,
                  let placemark = placemarks.first else {
                return
            }
            completion(placemark)
        }
    }

} // CreateTruckVC

extension CreateTruckVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

extension CreateTruckVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        userLocation = currentLocation
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, span: span)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
