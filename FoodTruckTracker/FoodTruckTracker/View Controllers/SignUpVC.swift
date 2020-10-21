//
//  SignUpVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit

class SignUpVC: UIViewController {
    
    // Outlets
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var singUpBtn: UIButton!
    @IBOutlet private weak var operatorSegmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var apiController = APIController()
    let user: User? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func singUpButton(_ sender: UIButton) {
        print("SignUp Button Tapped")
//        presentFTAlertOnMainThread(title: "Empty Textfield", message: "Need to fill out all fields to SignUp.", buttonTitle: "Ok")
        print("SingUp Got Tapped")
        guard let username = usernameTextField.text, !username.isEmpty,
           let email = emailTextField.text, !email.isEmpty,
           let password = passwordTextField.text, !password.isEmpty else {
            // Alert
            return
        }
        
        var isOperator: Int = 1
        switch operatorSegmentedControl.selectedSegmentIndex  {
        case 1:
            isOperator = 2
        default:
            isOperator = 1
        }
       
        let user = User(username: username, password: password, roleId: isOperator, email: email)
        
        APIController.shared.signIn(existingAccount: nil, newAccount: user, completion: { result in
            
            switch result {
            case .success(let success):
                // Perform Segue
               
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signUpGoToTabBarSegue", sender: nil)
                }
                
                print("SignUp Success \(success)")
            case .failure(let error):
                // Alert
                print("Failed to SignUp \(error)")
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
