//
//  CreateTruckVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/17/20.
//

import UIKit

class CreateTruckVC: UIViewController {
    
    // Outlets
    @IBOutlet private weak var truckImageView: UIImageView!
    @IBOutlet private weak var truckNameTextField: UITextField!
    @IBOutlet weak var cuisineTypePickerView: UIPickerView!
    
    // MARK: - Properties
    
    private let cuisineTypes = Cuisine.allCases.map { $0.rawValue }

    override func viewDidLoad() {
        super.viewDidLoad()
        cuisineTypePickerView.delegate = self
        cuisineTypePickerView.dataSource = self
        
    }
    

    @IBAction func createMenuButton(_ sender: UIButton) {
        guard let name = truckNameTextField.text, !name.isEmpty else { return }
        
        let location = "here"
        
        let cuisineId = cuisineTypePickerView.selectedRow(inComponent: 0)
        let truck = TruckListing(name: name, location: location, cuisineId: cuisineId)
        
        APIController.shared.createTruck(truck: truck) { (result) in
            switch result {
            case .success(let success):
                // Perform Segue
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "TruckGoToCreateMenu", sender: nil)
                }
                print("Create Truck Success \(success)")
                
            case .failure(let error):
                // Alert
                print("Failed Creating Truck \(error)")
            }
        }
        
    }//
    

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
