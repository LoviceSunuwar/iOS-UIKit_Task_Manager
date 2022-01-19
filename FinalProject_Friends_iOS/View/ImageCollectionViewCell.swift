//
//  ImageCollectionViewCell.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 19/01/2022.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var taskImage: UIImageView!
    
    var deleteButtonTapped:(()->())?
    var image:Data! {
        didSet {
            setupData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        taskImage.layer.cornerRadius = 10
        taskImage.layer.masksToBounds = true
        
        deleteButton.layer.cornerRadius = deleteButton.frame.height/2
        deleteButton.layer.masksToBounds = true
    }
    
    func setupData() {
        taskImage.image = UIImage(data: image)
        taskImage.contentMode = .scaleAspectFill
    }
    
    // Box to add an image
    func setupEmptyData() {
        taskImage.image = UIImage(systemName: "plus")
        taskImage.contentMode = .center
        deleteButton.isHidden = true
    }
    
    @IBAction func deleteHandler(_ sender: UIButton) {
        self.deleteButtonTapped?()
    }
    
}
