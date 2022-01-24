//
//  CategoryTableViewCell.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 23/01/2022.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(obj: Category){
        category.text = obj.title
    }

}
