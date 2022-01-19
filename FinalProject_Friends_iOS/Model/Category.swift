//
//  Category.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 19/01/2022.
//

import Foundation
class Category {
    var id: Int
    var title: String
    var icon: String
    
    init(id:Int, title:String, icon:String){
        self.id = id
        self.title = title
        self.icon = icon
    }
}
