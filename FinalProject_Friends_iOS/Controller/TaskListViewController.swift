//
//  TaskListViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 16/01/2022.
//

import UIKit

class TaskListViewController: UIViewController {
    
    var taskList = [Task]()

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
    
    @IBAction func addtask(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditViewController") as! AddEditViewController
        vc.addToTaskList = addToTaskList
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addToTaskList(task: Task){
        taskList.append(task)
        print("tasks", taskList.count)
    }
    
}
