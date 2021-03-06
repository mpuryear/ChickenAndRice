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
        public var thumbnail: Data?
    
    override init() {
            self.dateTime = ""
            self.message = ""
            self.username = ""
            self.thumbnail_id = "1" // default thumbnail id
            
            let path = Bundle.main.path(forResource: "cat", ofType: "png")
            self.thumbnail = NSData.init(contentsOfFile: path!) as Data?
            
            super.init()
        }
    
    init(dateTime: String, message: String, username: String, thumbnail_id: String, thumbnail: Data) {
        self.dateTime = dateTime
        self.message = message
        self.username = username
        self.thumbnail_id = thumbnail_id
        self.thumbnail = thumbnail
        super.init()
    }
}
