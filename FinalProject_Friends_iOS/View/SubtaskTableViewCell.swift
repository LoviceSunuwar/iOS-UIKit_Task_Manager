//
//  SubtaskTableViewCell.swift
//  FinalProject_Friends_iOS
//
//  Created by Nishu on 24/01/2022.
//

import UIKit

class SubtaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subtaskTitle: UILabel!
    @IBOutlet weak var isCompleted: UIButton!
    
    var radioButtonTapped: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCell(obj: SubTask) {
        subtaskTitle.text = obj.title
        isCompleted.isSelected = obj.isCompleted
    }
    
    @IBAction func isCompletedHandler(_ sender: UIButton) {
        self.radioButtonTapped?()
    }
    
}
