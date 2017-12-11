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
    
    func disconnectHandler(completionHandler: @escaping () -> Void) {
    
        socket.on("disconnect"){
            data, ack in
            completionHandler()
        }
    }
    
    
    func connectToServer(username: String, password: String) {
        socket.emit("connectUser", username, password)
    }

    func loginAuthenticated(username: String, completionHandler: @escaping (_ user_thumbnail: Data) -> Void){
        socket.on("client_login_authenticated") { (data, socketAck)  -> Void in
            
            // this returns the client thumbnail
             let t = data[0] as! [String : AnyObject]
           
            if let thumbnail_dict = t["data"] as? NSDictionary {
                let bytes = thumbnail_dict["data"] as! [UInt8]
                let thumbnail = NSData(bytes: bytes, length: bytes.count)
                completionHandler(thumbnail as Data)
                return
            }
            
            // if our login didnt had a thumbnail. Use the default one, and update the server
            let path = Bundle.main.path(forResource: "cat", ofType: "png")
            let thumbnail = NSData.init(contentsOfFile: path!) as Data?
            
            self.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail!)
            completionHandler(thumbnail!)
        }
    }
    
    func invalidLogin(completionHandler: @escaping () -> Void) {
        socket.on("invalid_login") { (dataArray, socketAck) -> Void in
            completionHandler()
        }
    }
    
    func getChatMessage(completionHandler: @escaping (_ message: Model_Message) -> Void) {
        socket.on("newChatMessage") { (data, socketAck) -> Void in
            
            
           let t = data[0] as! [String : AnyObject]
            
                
            let dateTime = t["created"] as! String
            let message = t["text"] as! String
            let username = t["sender"] as! String
               
                
                
            let currentMessage = Model_Message()
                

            let thumbnail_tuple = t["thumbnail"] as! [String: AnyObject]
            
            
            let thumbnail_dict = thumbnail_tuple["data"] as! NSDictionary
         
            let bytes = thumbnail_dict["data"] as! [UInt8]
            let thumbnail = NSData(bytes: bytes, length: bytes.count)
           // let receivedData = thumbnail_dict["data"] as! NSData
            
           
            // use default image
            currentMessage.dateTime = dateTime
            currentMessage.message = message
            currentMessage.username = username
            currentMessage.thumbnail = thumbnail as Data
           
            completionHandler(currentMessage)
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
                    
                    // use default image
                    let currentMessage = Model_Message()
                    currentMessage.dateTime = dateTime
                    currentMessage.message = message
                    currentMessage.username = username
                 
                    // Extract from our array of dictionaries
                    if let thumbnail_tuple = i["thumbnail"] as? [String: AnyObject] {
                        
                    // convert the data portion of our dictionary into another dictionary
                    let thumbnail_dict = thumbnail_tuple["data"] as! NSDictionary
                    
                    // extract the bytes from our data from server
                    let bytes = thumbnail_dict["data"] as! [UInt8]
                  
                    // convert our thumbnail into the swift NSData object
                    let thumbnail = NSData(bytes: bytes, length: bytes.count)
                        
                    // Convert the newly parsed NSData into our thumbnails datatype
                    currentMessage.thumbnail = thumbnail as Data
                    }
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
    
    func sendMessage(message: String, withUsername username: String, channel_id: String, thumbnail: Data) {
        
        socket.emit("chatMessage", username, message, channel_id, thumbnail)
    }
    
    func changeUserThumbnail(username: String, thumbnail: Data) {
        socket.emit("changeUserThumbnail", username, thumbnail)
    }
}
