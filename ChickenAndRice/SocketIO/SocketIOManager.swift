//
//  SocketIOManager.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/6/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import Foundation
import SocketIO

class SocketIOManager : NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket = SocketIOClient(socketURL: URL(string: "http://198.199.95.209")!)
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServer(username: String, password: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("connectUser", username, password)
    }

    func loginAuthenticated(username: String, completionHandler: @escaping () -> Void){
        socket.on("login_authenticated") { (dataArray, socketAck)  -> Void in
            completionHandler()
            self.socket.emit("login_authenticated", username)
        }
        
    }
    
    func invalidLogin(completionHandler: @escaping () -> Void) {
        socket.on("invalid_login") { (dataArray, socketAck) -> Void in
            completionHandler()
        }
    }
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["username"] = dataArray[0] as! String as AnyObject
            messageDictionary["message"] = dataArray[1] as! String as AnyObject
            messageDictionary["date"] = dataArray[2] as! String as AnyObject
            
            completionHandler(messageDictionary)
        }
    }
    
    func sendMessage(message: String, withUsername username: String) {
        socket.emit("chatMessage", username, message)
    }
}
