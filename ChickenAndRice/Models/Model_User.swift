//
//  Model_User.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/6/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import Foundation

class Model_User : NSObject{
    static let current_user = Model_User()
    public var username: String
    public var password: String
    public var authenticated: Bool
    public var theme : Bool
    
    override init() {
        self.username = ""
        self.password = ""
        self.authenticated = false
        self.theme = false
        super.init()
    }
    
    init(username: String, password: String, authenticated: Bool) {
        self.username = username
        self.password = password
        self.authenticated = authenticated
        self.theme = false
        super.init()
    }
    
}
