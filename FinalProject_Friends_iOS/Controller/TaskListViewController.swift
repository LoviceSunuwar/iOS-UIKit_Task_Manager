//
//  TaskListViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 16/01/2022.
//

import UIKit
import CoreData

class TaskListViewController: UIViewController {
    
    var taskList = [Task]()
    var searchTasks = [Task]()
    var category: Category!
    
    var isSearching = false
    var searchController: UISearchController!
    var isAsc = true
    var lastContentOffset: CGFloat = 0
    
    @IBOutlet weak var taskListTV: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        // Do any additional setup after loading the view.
        navigationBarSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Task Manager"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    
    func setupTableView() {
        self.taskListTV.dataSource = self
        self.taskListTV.delegate = self
    }
    
    @IBAction func addTaskHandler(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditViewController") as! AddEditViewController
        vc.loadTask = loadTasks
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigationBarSetup() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .default
        searchController.searchBar.placeholder = "Search task"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "password")
        appDelegate.goToLoginPage()
    }
    
    //MARK: Core Data Methods
    private func loadTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let tasks = try context.fetch(request)
            taskList = tasks.filter({ (task) -> Bool in
                let defaults = UserDefaults.standard
                let username = defaults.value(forKey: "username") as! String
                return task.category == category && task.user?.username == username
            })
            sortTask()
        } catch {
            print("Error loading tasks ",error.localizedDescription)
        }
    }
    
    private func deleteTask(task: Task){
        context.delete(task)
    }
    
    private func saveTask(){
        appDelegate.saveContext()
    }
    
    @IBAction func sortTask(_ sender: UIButton) {
        isAsc = !isAsc
        sortButton.setImage(isAsc ? UIImage(systemName: "arrow.up") : UIImage(systemName: "arrow.down"), for: .normal)
        sortTask()
    }
    
    private func sortTask(){
        taskList = taskList.sorted(by: {isAsc ? $0.title! < $1.title! : $0.title! > $1.title!})
        taskListTV.reloadData()
    }
}


// MARK: UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            isSearching = false
            searchTasks = []
            taskListTV.reloadData()
            return
        }
        isSearching = true
        searchTasks = taskList.filter({ (temp) -> Bool in
            let title: String = temp.title!.lowercased()
            let category: String = (temp.category?.title?.lowercased()) ?? ""
            return title.contains(searchText.lowercased()) || category.contains(searchText.lowercased())
        })
        taskListTV.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        taskListTV.reloadData()
    }
    
    
}

//MARK: UITABLEVIEWDATASOURCE
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchTasks.count
        } else {
            return taskList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = isSearching ? searchTasks[indexPath.row] : taskList[indexPath.row]
        let cell = taskListTV.dequeueReusableCell(withIdentifier: "task", for: indexPath) as! TaskTableViewCell
        cell.setCell(obj: obj)
        
        cell.radioButtonTapped = {
            obj.isCompleted = !obj.isCompleted
            self.saveTask()
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
                self.deleteTask(task: self.taskList[indexPath.row])
                self.saveTask()
                self.taskList.remove(at: indexPath.row)
                self.taskListTV.deleteRows(at: [indexPath], with: .fade)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        let update = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddEditViewController") as! AddEditViewController
            vc.task = task
            vc.taskList = self.taskList
            vc.loadTask = self.loadTasks
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


// MARK: Scroll
extension TaskListViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        
        // For Floating button fade when scroll
        if lastContentOffset >= scrollView.contentOffset.y {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.sortButton.alpha = 1
            }
        } else if lastContentOffset < scrollView.contentOffset.y {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.sortButton.alpha = 0
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
}
