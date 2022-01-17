//
//  RegisterViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Shivam on 16/01/2022.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func register(_ sender: UIButton) {
        
        if !fullName.text!.isEmpty && !email.text!.isEmpty && !phone.text!.isEmpty && !password.text!.isEmpty && !confirmPassword.text!.isEmpty {
            
        } else {
            let alertController = UIAlertController(title: "Invalid", message: "Please fill all of the fields", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
}
