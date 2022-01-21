//
//  TaskListViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 16/01/2022.
//

import UIKit

class TaskListViewController: UIViewController {
    
    var taskList = [Task(id: "1", title: "Test 1", category: Category(id: 1, title: "School", icon: "book.fill"), createDate: "2022-01-19 21:23:34 +0000", endDate: "2022-01-19 21:23:34 +0000", images: [], isCompleted: false)]
    
    @IBOutlet weak var taskListTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
    
    func addToTaskList(task: Task){
        taskList.append(task)
        print("tasks", taskList.count)
        taskListTV.reloadData()
    }
    
    func setupTableView() {
        self.taskListTV.dataSource = self
        self.taskListTV.delegate = self
    }
    
    @IBAction func addTaskHandler(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditViewController") as! AddEditViewController
        vc.addToTaskList = addToTaskList
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = taskList[indexPath.row]
        let cell = taskListTV.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! TaskTableViewCell
        cell.setCell(obj: obj)
        
        cell.radioButtonTapped = {
            obj.isCompleted = !obj.isCompleted
            self.taskListTV.reloadData()
        }
        
        return cell
    }
    
    // MARK: trailingSwipeActionsConfigurationForRowAt
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = taskList[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to delete Task", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                    self.taskList.remove(at: indexPath.row)
                    self.taskListTV.reloadData()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        let update = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditViewController") as! AddEditViewController
            vc.task = task
            vc.taskList = self.taskList
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        update.image = UIGraphicsImageRenderer(size: CGSize(width: 25, height: 30)).image(actions: { (_) in
            UIImage(named: "edit_white")?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 28))
        })
        delete.image = UIGraphicsImageRenderer(size: CGSize(width: 25, height: 30)).image(actions: { (_) in
            UIImage(named: "delete_white")?.draw(in: CGRect(x: 0, y: 0, width: 25, height: 25))
        })
        
        delete.backgroundColor = .systemRed
        update.backgroundColor = .systemYellow
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, update])
        return configuration
    }
    
    func alert(message: String?, title: String? = nil, okAction: (()->())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            okAction?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}



//MARK: UITABLEVIEWDELEGATE
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
