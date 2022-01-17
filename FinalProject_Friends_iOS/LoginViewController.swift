//
//  LoginViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 16/01/2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var userNames = [User(fullName: "User", email: "test@email.com", phone: "1234456788", password: "password", username: "user1")];
    
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
    @IBAction func login(_ sender: UIButton) {
        let name = username.text
        let pw = password.text
        if (userNames.first(where: {$0.username == name && $0.password == pw} ) != nil) {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TaskListViewController") as! TaskListViewController

            AppDelegate().window?.rootViewController = vc
            AppDelegate().window?.makeKeyAndVisible()
            
        } else {
            let alertController = UIAlertController(title: "Unauthorized", message: "Username or password incorrect", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
}
