//
//  AddEditViewController.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 19/01/2022.
//

import UIKit
import CoreData

class AddEditViewController: UIViewController {
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var audioTV: UITableView!
    
    var category = [Category]()
    var selectedCategory: Category!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var task: Task! = nil
    var taskList = [Task]()
    
    var images: [Data] = []
    var imagePicker: ImagePicker?
    
    var loadTask:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loadCategory()
        audioTV.isHidden = true
        selectedCategory = category[0]
        setupPickerView()
        setupCollectionView()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = (task != nil ? "Edit" : "Add") + " Task"
    }
    
    func setupData() {
        if task != nil {
            taskTitleTextField.text = task!.title
            let categoryIndex = category.firstIndex(of: task.category!)!
            pickerView.selectRow(categoryIndex, inComponent: 0, animated: true)
            self.images = task.images!
            createButton.setTitle("Update", for: .normal)
            datePicker.date = task.endDate!.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss Z") ?? Date()
            self.title = "Update Task"
//            audioTV.isHidden = task.audio!.count == 0
        } else {
            createButton.setTitle("Create", for: .normal)
            self.title = "Add Task"
        }
        
        
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
    
    @IBAction func createButtonHandler(_ sender: UIButton) {
        guard let title = taskTitleTextField.text, !title.isEmpty else {
            self.alert(message: "Title is required", title: "Alert", okAction: nil)
            return
        }
        
        if task == nil {
            let newTask = Task(context: self.context)
            newTask.title = title
            newTask.category = selectedCategory
            newTask.createdDate = "\(Date())"
            newTask.endDate = "\(datePicker.date)"
            newTask.images = images
            newTask.isCompleted = false
            appDelegate.saveContext()
            self.loadTask?()
        } else {
            task.title = title
            task.category = selectedCategory
            task.endDate = "\(datePicker.date)"
            task.images = images
            appDelegate.saveContext()
            self.loadTask?()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func alert(message: String?, title: String? = nil, okAction: (()->())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            okAction?()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addAudio(_ sender: UIButton) {
        
    }
    
    //MARK: Core Data Methods
    private func loadCategory(){
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            category = try context.fetch(request)
        } catch {
            print("Error loading category", error.localizedDescription)
        }
    }
    
    
}

// MARK: For Picker View START
extension AddEditViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row].title
    }
    
    
}

extension AddEditViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = category[row]
    }
}
// For Picker View END

// MARK: For Collection View START
extension AddEditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        
        if images.count != indexPath.row {
            //not a last index
            cell.image = images[indexPath.row]
            cell.deleteButton.isHidden = false
            cell.deleteButtonTapped = {
                let deleteActionSheetController = UIAlertController(title: "Alert", message: "Are you sure you want to delete?", preferredStyle: .alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                    self.images.remove(at: indexPath.row)
                    self.reloadCollectionView()
                }
                
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                    
                }
                
                deleteActionSheetController.addAction(deleteAction)
                deleteActionSheetController.addAction(cancelAction)
                
                self.present(deleteActionSheetController, animated: true, completion: nil)
            }
        } else {
            // last index add button should be shown
            cell.setupEmptyData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if images.count == indexPath.row {
            // add new image
            imagePicker = ImagePicker(presentationController: self)
            imagePicker?.present(from: self.view)
            imagePicker?.completion = { [weak self] selectedImage in
                guard let self = self else { return }
                let imageData = selectedImage.jpegData(compressionQuality: 0.8)!
                self.images.append(imageData)
                self.reloadCollectionView()
            }
        }
    }
    
    
}

extension AddEditViewController: UICollectionViewDelegateFlowLayout {
    // Define size of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        return CGSize(width: height, height: height) // square cell
    }
    
    // Padding for inner view in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension UICollectionView {
    
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
    
}
// For Collection View END


