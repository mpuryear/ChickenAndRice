//
//  Model_Message.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/6/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import Foundation

class Model_Message : NSObject {
        public var dateTime : String
        public var message : String
        public var username : String
        public var thumbnail_id : String
        override init() {
            self.dateTime = ""
            self.message = ""
            self.username = ""
            self.thumbnail_id = "1" // default thumbnail id
            super.init()
        }
    
    init(dateTime: String, message: String, username: String, thumbnail_id: String) {
        self.dateTime = dateTime
        self.message = message
        self.username = username
        self.thumbnail_id = thumbnail_id
        super.init()
    }
}
