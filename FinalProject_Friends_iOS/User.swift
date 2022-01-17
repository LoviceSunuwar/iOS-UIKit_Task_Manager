//
//  User.swift
//  FinalProject_Friends_iOS
//
//  Created by Roch on 16/01/2022.
//

import Foundation
class User {
    var fullName:String
    var email:String
    var phone:String
    var password:String
    var username:String
    
    init(fullName:String, email:String, phone:String, password:String,username:String){
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.password = password
        self.username = username
    }
}
