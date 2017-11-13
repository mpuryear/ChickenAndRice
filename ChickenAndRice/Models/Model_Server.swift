//
//  Model_Server.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/12/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import Foundation


class Model_Server : NSObject {
    
    static let current_server = Model_Server()
    var name : String
    var _id  : String
    var shareableLink: String
    var default_channel: String
    
    override init() {
        self.name = "general"
        self._id = "5a06efb2aa678b690467ae85"
        self.shareableLink = "general"
        self.default_channel = "general"
        super.init()
    }
    
    init(name: String, id: String, link: String, default_channel: String) {
        self.name = name
        self._id = id
        self.shareableLink = link
        self.default_channel = default_channel
        super.init()
    }
    
}
