//
//  LoginViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 16/01/2022.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var userNames = [User]()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    @IBAction func login(_ sender: UIButton) {
        let name = username.text
        let pw = password.text
        
        // check if username and password is correct
        if (userNames.first(where: {$0.username == name && $0.password == pw} ) != nil) {
            
            // store username and password to check if user has logged in later
            let defaults = UserDefaults.standard
            defaults.set(name, forKey: "username")
            defaults.set(pw, forKey: "password")
            
            appDelegate.goToTaskListPage()
            
        } else {
            // show alert if username or password is incorrect
            let alertController = UIAlertController(title: "Unauthorized", message: "Username or password incorrect", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
}
