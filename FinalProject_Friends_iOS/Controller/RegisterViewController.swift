//
//  RegisterViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Shivam on 16/01/2022.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var username: UITextField!
    
    var userNames = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadUsers()
    }
    
    //MARK: Core Data Methods
    private func loadUsers(){
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            userNames = try context.fetch(request)
        } catch {
            print("Error loading user ", error.localizedDescription)
        }
    }
    
    
    // MARK: UIButton
    @IBAction func register(_ sender: UIButton) {
        
        if !fullName.text!.isEmpty && !email.text!.isEmpty && !phone.text!.isEmpty && !password.text!.isEmpty && !confirmPassword.text!.isEmpty && !username.text!.isEmpty {
            
            let usernameExists = userNames.first(where: {$0.username?.lowercased() == username.text?.lowercased()})
            let emailValid = isValidEmail(email.text!)
            let phoneValid = phone.text?.count == 10
            
            if usernameExists == nil && emailValid && phoneValid {
                // check is password and confirm password is same
                if password.text == confirmPassword.text {
                    // add function to store user data in database
                    let newUser = User(context: context)
                    newUser.fullName = fullName.text
                    newUser.email = email.text
                    newUser.phone = phone.text
                    newUser.password = password.text
                    newUser.username = username.text
                    appDelegate.saveContext()
                    
                    // store username and password to check if user has logged in later
                    let defaults = UserDefaults.standard
                    defaults.set(username.text, forKey: "username")
                    
                    appDelegate.goToCategoryPage()
                } else {
                    let alertController = UIAlertController(title: "Invalid", message: "Password and Confirm Password must be same.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "Invalid", message: usernameExists != nil ? "This username already exists. Please use another one." : !phoneValid ? "Phone number must be 10 digits" :  "Email address not valid", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
        } else {
            let alertController = UIAlertController(title: "Invalid", message: "Please fill all of the fields", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
}
