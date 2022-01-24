//
//  CategoryViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 23/01/2022.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {

    @IBOutlet weak var categoryTV: UITableView!
    
    var categories = [Category]()
    var taskList = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupTableView()
        loadCategory()
        loadTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Categories"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    

    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        saveCategory(category: nil)
    }
    
    func saveCategory(category: Category!) {
        var categoryName = UITextField()
        let isEdit = category != nil
        let alert = UIAlertController(title: (!isEdit ? "Add" : "Edit") + " Category", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: (!isEdit ? "Add" : "Edit"), style: .default) { (action) in
            if !categoryName.text!.isEmpty {
                if self.categories.first(where: {$0.title == categoryName.text}) == nil {
                    if !isEdit {
                        let newCategory = Category(context: context)
                        newCategory.title = categoryName.text
                        self.categories.append(newCategory)
                    } else {
                        category.title = categoryName.text
                    }
                   
                    appDelegate.saveContext()
                    self.categoryTV.reloadData()
                } else {
                    self.alert(message: "Category already exists", title: nil, okAction: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            categoryName = field
            categoryName.placeholder = "Category name"
            if isEdit {
                categoryName.text = category.title
            }
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func alert(message: String?, title: String? = nil, okAction: (()->())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            okAction?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Setup
    private func setupTableView(){
        categoryTV.delegate = self
        categoryTV.dataSource = self
    }
    
    //MARK: Load Data
    private func loadCategory(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading tasks ",error.localizedDescription)
        }
        
    }
    
    private func loadTasks(){
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            taskList = try context.fetch(request)
        } catch {
            print("Error loading tasks ",error.localizedDescription)
        }
    }
    

}

// MARK: UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: UITableViewDelegate
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = categories[indexPath.row]
        let cell = categoryTV.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableViewCell
        
        cell.setCell(obj: obj)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TaskListViewController") as! TaskListViewController
        vc.taskList = taskList.filter({ (task) -> Bool in
            return task.category == categories[indexPath.row]
        })
        vc.category = categories[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = categories[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to delete category?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                context.delete(category)
                appDelegate.saveContext()
                self.categories.remove(at: indexPath.row)
                self.categoryTV.deleteRows(at: [indexPath], with: .fade)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
        let update = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            self.saveCategory(category: category)
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
    
    
}
