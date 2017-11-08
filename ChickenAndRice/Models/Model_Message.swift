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
        override init() {
            self.dateTime = ""
            self.message = ""
            self.username = ""
            super.init()
        }
}
