//
//  TaskListViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 16/01/2022.
//

import UIKit

class TaskListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Task Manager"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func addtask(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditViewController") as! AddEditViewController
//        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
