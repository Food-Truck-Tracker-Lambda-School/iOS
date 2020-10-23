//
//  LoginVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/14/20.
//

import UIKit

class LoginVC: UIViewController {
    
    // Outlets
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTexxtField: UITextField!
    @IBOutlet private weak var loginBtn: UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
   
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
//        presentFTAlertOnMainThread(title: "No Information", message: "Please provide an username and password to Login", buttonTitle: "Ok")
        
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTexxtField.text, !password.isEmpty else {
            // Alert
            return
        }
        
        let user = ReturningUser(username: username, password: password)
        
        APIController.shared.signIn(existingAccount: user, newAccount: nil) { result in
            
            switch result {
            case .success(true):
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "LoginGoToTabBarSegue", sender: nil)
                }
            case .failure(let error):
                print("Failed to Login \(error)")
                self.presentFTAlertOnMainThread(title: "Wrong User", message: "Please provide the correct user information.", buttonTitle: "Ok")
            default:
                return
            }
        }
        
    }//
    

}//
