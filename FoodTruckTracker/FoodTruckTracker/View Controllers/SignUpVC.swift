//
//  SignUpVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit

class SignUpVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var singUpBtn: UIButton!
    @IBOutlet private weak var operatorSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    
    var apiController = APIController()
    let user: User? = nil
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func singUpButton(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty,
           let email = emailTextField.text, !email.isEmpty,
           let password = passwordTextField.text, !password.isEmpty else {
            self.presentFTAlertOnMainThread(title: "Empty Text Field", message: "Please fill out all the fields to create an account.", buttonTitle: "OK")
            return
        }
        
        var isOperator: Int = 1
        switch operatorSegmentedControl.selectedSegmentIndex {
        case 1:
            isOperator = 2
        default:
            isOperator = 1
        }
       
        let user = User(username: username, password: password, roleId: isOperator, email: email)
        
        APIController.shared.signIn(existingAccount: nil, newAccount: user, completion: { result in
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signUpGoToTabBarSegue", sender: nil)
                }
            case .failure(let error):
                self.presentFTAlertOnMainThread(title: "Error", message: "Failed to create a new account. Try a different username.", buttonTitle: "OK")
                NSLog("Error creating an account: \(error)")
            }
        })
    }//
    
    @IBAction func operatorSegmented(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            self.apiController.userRole = .diner
        } else {
            self.apiController.userRole = .owner
        }
    }

} // SignUpVC
