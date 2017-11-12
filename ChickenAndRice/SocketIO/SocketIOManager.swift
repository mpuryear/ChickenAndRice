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
    

    
    //198.199.95.209
    var socket = SocketIOClient(socketURL: URL(string: "http://198.199.95.209")!)

    var hasDisconnected :  Bool
    
    override init() {
        hasDisconnected = true
        

        
        super.init()
    }
    
    func establishConnection() {
        socket.forceNew = true
        socket.reconnects = true
        if !(socket.status == .connected || socket.status == .connecting || socket.status == .disconnected) {
            print("CALLING CONNECT")
            socket.connect()
        }
    }
    
    func onAny() {
        socket.onAny({
            
            data in
            
            let currentEvent = data.event as String
            if (currentEvent == "disconnected" || currentEvent == "notConnected") {
                self.hasDisconnected = true
            } 
            
            print("\nANy event =====> \(data.event)\n" )
            
            
        })
    }
    
    func reconnect() {
 
        if !(socket.status == .connected || socket.status == .connecting) {
                print("\n\nCALLING RECONNECT")
                print("connected: \(SocketIOClientStatus.connected.rawValue)")
                print("connecting: \(SocketIOClientStatus.connecting.rawValue)")
                print("notConnected: \(SocketIOClientStatus.notConnected.rawValue)")
                print("disconnted: \(SocketIOClientStatus.disconnected.rawValue)")
                print("current socket: \(socket.status.rawValue)")
                socket.reconnect()
            }
        
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    func statusChangeHandler(completionHandler: @ escaping (_ status: String) -> Void) {
        socket.on("statusChange") {
            data, ack in
            
            
            var status : String
            
            let status_code = data[0] as! SocketIO.SocketIOClientStatus
            switch(status_code) {
            case .notConnected: status = "notConnected"
            case .disconnected: status = "disconnected"
            case .connecting: status = "connecting"
            case .connected: status = "connected"
            }
            
            
            completionHandler(status)
        }
    }
    
    /*
    func reconnectAttemptHandle(completionHandler: @ escaping() -> Void) {
        socket.on("reconnectAttempt") {
            data, ack in
            completionHandler()
        }
        
    }
    */
    func disconnectHandler(completionHandler: @escaping () -> Void) {
    
        socket.on("disconnect"){
            data, ack in
            completionHandler()
        }
    }
    
    
    func connectToServer(username: String, password: String) {
        socket.emit("connectUser", username, password)
    }

    func loginAuthenticated(username: String, completionHandler: @escaping () -> Void){
        socket.on("client_login_authenticated") { (dataArray, socketAck)  -> Void in
            completionHandler()  
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
    
    func joinServer(username: String, room: String) {
        socket.emit("joinRoom", username, room)
    }
    
    func leaveServer(username: String, room: String) {
        socket.emit("leaveRoom", username, room)
    }
    
    func subscribeToServer(username: String, connect_string: String) {
        socket.emit("subscribeToServer", username, connect_string)
    }
    
    func requestChannelsOfServer(username: String, server_id: String) {
        socket.emit("getChannels", username, server_id);
    }
    
    func getChannel(completionHandler: @escaping (_ channel: String) -> Void) {
        socket.on("channel") { (dataArray, socketAck) -> Void in
            
            print("dataArray: \(dataArray)")
            
            var name = ""
            
            let data = dataArray as! [[String : Any]]
            
            name = data[0]["name"] as! String
            
            completionHandler(name)
 
        }
        
    }
    
    func attemptRegisterUser(username: String, password: String) {
        socket.emit("registerUser", username, password);
    }
    
    func username_taken(completionHandler: @ escaping() -> Void) {
        socket.on("username_taken") {
            data, ack in
            
            completionHandler()
        }
        
    }
    
    func user_created(completionHandler: @escaping () -> Void) {
        socket.on("user_created") {
            data, ack in
            completionHandler()
        }
    }
    
    func requestSubscribedServers(username: String) {
        print("\(username) requests")
        socket.emit("requestSubscribedServers", username)
    }
    
    func getSubscribedServers(completionHandler: @escaping (_ serverList: [String]) -> Void) {
            



    }
    
    
    
    func sendMessage(message: String, withUsername username: String, room: String) {
        socket.emit("chatMessage", username, message, room)
    }
}
