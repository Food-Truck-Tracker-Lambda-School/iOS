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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func singUpButton(_ sender: UIButton) {
    }
    

} // SignUpVC
