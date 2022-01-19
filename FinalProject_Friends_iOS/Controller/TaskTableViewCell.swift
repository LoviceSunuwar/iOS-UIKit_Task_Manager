//
//  TaskTableViewCell.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 19/01/2022.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var dueDate: UILabel!
    @IBOutlet weak var isCompleted: UIButton!
    @IBOutlet weak var categoryIcon: UIImageView!
    
    var radioButtonTapped: (()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(obj: Task){
        isCompleted.isSelected = obj.isCompleted
        taskTitle.text = obj.title
        categoryIcon.image = UIImage(named: obj.category.icon)
        let date = obj.endDate.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss Z")
        let dateString = date?.toFormattedDate()
        dueDate.text = dateString
    }
    
    @IBAction func isCompletedHandler(_ sender: UIButton) {
        self.radioButtonTapped?()
    }
    
}
