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
    
    
    func requestMessagesByChannelId(username: String, channel_id: String) {
        socket.emit("getMessagesByChannelId", username, channel_id)
    }
    
    // response from "getMessagesByChannelId
    func getChatMessagesForChannel(completionHandler: @escaping (_ messages: [Model_Message]) -> Void) {
        socket.on("messages") {
            dataArray, ack -> Void in
            
            var messages : [Model_Message] = []
            
                let data = dataArray[0] as! [[String : AnyObject]]
                for i in data {
                
                    let dateTime = i["created"] as! String
                    let message = i["text"] as! String
                    let username = i["sender"] as! String
                    let thumbnail_id = i["thumbnail_id"] as! String
                
                    let currentMessage = Model_Message(dateTime: dateTime, message: message, username: username, thumbnail_id: thumbnail_id)
                    messages.append(currentMessage)
                }

            completionHandler(messages)
        }
    }
    
    func joinChannel(username: String, channel_id: String) {
        socket.emit("joinChannel", username, channel_id)
    }
    
    func leaveChannel(username: String, channel_id: String) {
        socket.emit("leaveChannel", username, channel_id)
    }
    
    func createServer(username: String, servername: String) {
        socket.emit("createServer", username, servername)
    }
    
    func createChannel(username: String, channel_name: String, server_id: String) {
        socket.emit("createChannel", username, channel_name, server_id)
    }
    
    func serverCreated(completionHandler: @escaping (_ results: Model_Server) -> Void) {
        socket.on("serverCreated") {
            data, ack in
            
            let t = data[0] as! [String: AnyObject]
            let name = t["name"] as! String
            let id = t["_id"] as! String
            let link = t["connection_string"] as! String
            let default_channel = t["channel_ids"] as! [String]
            let server = Model_Server(name: name, id: id, link: link, default_channel: default_channel[0])
            completionHandler(server)
        }
    }
    
    func channelCreated(completionHandler: @escaping (_ results: Model_Channel) -> Void) {
        socket.on("channelCreated") {
            data, ack in
            
            let t = data[0] as! [String: AnyObject]
            let name = t["name"] as! String
            let id = t["_id"] as! String
            let channel = Model_Channel(name: name, id: id)
            completionHandler(channel)
        }
    }
    
    func subscribeToServer(username: String, connect_string: String) {
        socket.emit("subscribeToServer", username, connect_string)
    }
    
    func serverSubscribeSuccess(completionHandler: @escaping (_ server: Model_Server) -> Void) {
        socket.on("joinedServer") {
            data, Ack in
            
            let t = data[0] as! [String: AnyObject]
            let name = t["name"] as! String
            let id = t["_id"] as! String
            let string = t["connection_string"] as! String
            let default_channel = t["channel_ids"] as! [String]
            let server = Model_Server(name: name, id: id, link: string, default_channel: default_channel[0])
            completionHandler(server)
        }
    }
    
    func requestChannelsOfServer(username: String, server_id: String) {
        socket.emit("getChannels", username, server_id);
    }
    
    func getChannel(completionHandler: @escaping (_ channel: [Model_Channel]) -> Void) {
        socket.on("channel") { (dataArray, socketAck) -> Void in
            
            print("dataArray: \(dataArray)")
            
            var channels : [Model_Channel] = []
            
            let data = dataArray[0] as! [[String : AnyObject]]
            for i in data {
        
                let name = i["name"] as! String
                let _id = i["_id"] as! String
            
                let currentChannel = Model_Channel(name: name, id: _id)
                channels.append(currentChannel)
            }
            completionHandler(channels)
 
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
    
    func getServer(completionHandler: @escaping (_ server: [Model_Server]) -> Void){
        socket.on("server") {
            dataArray, ack in
            
            var results : [Model_Server] = []
            
            let data = dataArray[0] as! [[String : AnyObject]]
            for servers in data {
            let name = servers["name"] as! String
            let _id = servers["_id"] as! String
            let link = servers["connection_string"] as! String
            let default_channel = servers["channel_ids"] as! [String]
                
            let currentServer = Model_Server(name: name, id: _id, link: link, default_channel: default_channel[0])
                results.append(currentServer)
            }
            completionHandler(results)
        }
    }
    
    func failedToJoinServer(completionHandler: @escaping() -> Void){
        socket.on("failedToJoinServer") {
            data, ack in
            completionHandler()
        }
    }
    
    func failedToCreateServer(completionHandler: @escaping() -> Void) {
        socket.on("failedToCreateServer") {
            data, ack in
            completionHandler()
        }
    }
    
    func failedToCreateChannel(completionHandler: @escaping() -> Void) {
        socket.on("failedToCreateChannel") {
            data, ack in
            completionHandler()
        }
    }
    
    func sendMessage(message: String, withUsername username: String, channel_id: String) {
        socket.emit("chatMessage", username, message, channel_id)
    }
}
