//
//  Tassk.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 19/01/2022.
//

import Foundation
class Task {
    var id: String
    var title: String
    var category: Category
    var createDate:String
    var endDate: String
    var images: [Data]
    var isCompleted: Bool
    
    init( id: String,
          title: String,
          category: Category,
          createDate:String,
          endDate: String,
          images: [Data],
          isCompleted: Bool
    ){
        self.id = id
        self.title = title
        self.category = category
        self.createDate = createDate
        self.endDate = endDate
        self.images = images
        self.isCompleted = isCompleted
    }
    
    func toString() -> String {
        print(endDate)
        return "title: " + title + "/n" + "category: " + category.title + "/n" + "endDate: " + endDate;
    }
}
