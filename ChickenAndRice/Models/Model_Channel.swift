//
//  Model_Channel.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/12/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import Foundation

class Model_Channel : NSObject {
    static let current_channel = Model_Channel()
    var name : String
    var _id  : String
    
    override init() {
        self.name = "channel1"
        self._id = ""
        super.init()
    }
    
    init(name: String, id: String) {
        self.name = name
        self._id = id
        super.init()
    }
    
    
}
