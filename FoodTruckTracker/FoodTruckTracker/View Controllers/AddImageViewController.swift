//
//  AddImageViewController.swift
//  FoodTruckTracker
//
//  Created by Cora Jacobson on 10/23/20.
//

import UIKit

class AddImageViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    
    // MARK: - Properties
    
    var truck: Truck? {
        didSet {
            guard truck != nil else { return }
            fetchTruckListing()
        }
    }
    var truckListing: TruckListing?
    
    var item: MenuItem?
    
    var image: UIImage?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 2
        setUpImage()
        if let truck = truck,
           let name = truck.name,
           item == nil {
            titleLabel.text = "Change image for \(name)"
            if let imageArray = ImageController.shared.getUIImage(truck, nil, nil) {
                imageView.image = imageArray[0]
            }
        } else if let item = item {
            titleLabel.text = "Add image for \(item.name)"
            if let imageArray = ImageController.shared.getUIImage(nil, nil, item) {
                imageView.image = imageArray[0]
            }
        }
        presentFTAlertOnMainThread(title: "Sorry", message: "Image uploading is unavailable at this time. Please try again later.", buttonTitle: "OK")
    }
    
    // MARK: - Actions
    
    @IBAction func saveImageButton(_ sender: UIButton) {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 0.1),
              let truckId = truckListing?.identifier else { return }
        let filename = getDocumentsDirectory().appendingPathComponent("copy.jpg")
        try? imageData.write(to: filename)
        var itemId: Int?
        if let item = item {
            itemId = item.id
        }
        APIController.shared.postImageFile(photoFile: filename, truckId: truckId, itemId: itemId) { result in
            switch result {
            case .success(true):
                self.presentFTAlertOnMainThread(title: "Success", message: "Your image has been uploaded.", buttonTitle: "OK")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            default:
                self.presentFTAlertOnMainThread(title: "Error", message: "Failed to upload image.", buttonTitle: "OK")
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func fetchTruckListing() {
        if let truck = truck {
            APIController.shared.fetchSingleTruck(truck: truck) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let truckData):
                        self.truckListing = truckData
                    default:
                        NSLog("Error - unable to fetch Truck Data")
                    }
                }
            }
        } else {
            NSLog("Error - no truck selected")
        }
    }
    
    private func setUpImage() {
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        imageView.addGestureRecognizer(tapGesture)
    }

    @objc func presentPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

extension AddImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = imageSelected
            imageView.image = imageSelected
        }

        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = imageOriginal
            imageView.image = imageOriginal
        }

        picker.dismiss(animated: true, completion: nil)
    }

}
