//
//  ViewController_Chat.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/6/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController_Chat: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var messageModel : [Model_Message] = [Model_Message]()
    static var hasLoaded : Bool =  false

    
    var responseChannels : [Model_Channel] = []
    var responseServers : [Model_Server] = []
    var clickedChannels : Bool = false
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
  
    @IBOutlet weak var shareableStringTextView: UITextView!
    
    @IBOutlet weak var serverSelectButton: UIButton!
    
    @IBOutlet weak var channelSelectButton: UIButton!
    
    @IBAction func didTapServerSelect(_ sender: Any) {
       SocketIOManager.sharedInstance.requestSubscribedServers(username: Model_User.current_user.username)
    }
        
    
    @IBAction func didTapChannelSelect(_ sender: Any) {

        SocketIOManager.sharedInstance.requestChannelsOfServer(username: Model_User.current_user.username, server_id: Model_Server.current_server._id)
       clickedChannels = true
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        print("didTapSend")
        if let text = messageTextField.text, !text.isEmpty {
            SocketIOManager.sharedInstance.sendMessage(message: messageTextField.text!, withUsername: Model_User.current_user.username,
                                                       channel_id: Model_Channel.current_channel._id )
            
            messageTextField.text = "" // clear the text box
        }
    }
    
    func playMessageNotification() {
        if let soundURL = Bundle.main.url(forResource: "rooster-1", withExtension: "wav") {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            // Play
            AudioServicesPlaySystemSound(mySound);
        }
    }
    
    func establishChannelHandling() {
        SocketIOManager.sharedInstance.getChannel(completionHandler: {
            (results) -> Void in DispatchQueue.main.async {
                self.responseChannels = results
                if self.clickedChannels {
                // clear messages
                self.messageModel.removeAll()
                self.chatTableView.reloadData()
                    // set Model_Channel.current
                    Model_Channel.current_channel._id = self.responseChannels[0]._id
                    Model_Channel.current_channel.name = self.responseChannels[0].name
                    
                self.performSegue(withIdentifier: "Segue_ChatToChannel", sender: self)
                }
                self.clickedChannels = false
            }
        })
    }
    
    func establishServerHandling() {
        SocketIOManager.sharedInstance.getServer(completionHandler: {
            (results) -> Void in DispatchQueue.main.async {
                self.responseServers = results
            
                self.messageModel.removeAll()
                self.chatTableView.reloadData()
                
                 self.performSegue(withIdentifier: "Segue_ChatToServer", sender: self)
            }
        })
    }
    
    func establishMessageHandling() {
        print("Establishing message handling")
        SocketIOManager.sharedInstance.getChatMessage(completionHandler: { (messageInfo) -> Void in DispatchQueue.main.async{
            () -> Void in
            
            let currentMessage = Model_Message()
            
            if let date = messageInfo["date"] as? String {
                
                let modifiedDate = "[" + date + "] "
                currentMessage.dateTime = modifiedDate
            }
            if let username = messageInfo["username"] as? String {
                
                let modifiedUsername = username
                currentMessage.username = modifiedUsername
            }
            if let message = messageInfo["message"] as? String {
                
                currentMessage.message = message
            }
            
            print("\nmessage appended\n")
            self.messageModel.append(currentMessage)
            self.chatTableView.reloadData()
        
            print("played sound")
            self.playMessageNotification()
            
            // scroll to bottom of the tableview
            let indexPath = NSIndexPath(row: self.messageModel.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
        

            }
        })
    }

    func handleNotConnected() {
       
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
     
    }
    
    func handleDisconnected() {
      
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
     
       
    }
    
    func handleConnecting() {
        
    }
    
    func handleConnected() {
        
    }
    
    func establishStatusChangeHandling() {
        SocketIOManager.sharedInstance.statusChangeHandler(completionHandler: {
            (status) ->  Void in DispatchQueue.main.async{
                () -> Void in
                
                let response = status as String
                print("\n\n\n CHAT_VC: \(response)")
                switch(response) {
                case "notConnected": self.handleNotConnected()
                case "disconnected": self.handleDisconnected()
                case "connecting": self.handleConnecting()
                case "connected": self.handleConnected()
                default: break
                }
                
                
                
                
            }});
    }
    
    
    func establishChannelJoinMessageHandling() {
        SocketIOManager.sharedInstance.getChatMessagesForChannel(completionHandler: {
            (channelMessages) -> Void in
            self.messageModel = channelMessages
            self.chatTableView.reloadData()

            if self.messageModel.count > 0 {
                // scroll to bottom of the tableview but only if we have something to scroll to
                let indexPath = NSIndexPath(row: self.messageModel.count - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 44
        chatTableView.separatorStyle = .none   

    
        // TODO : THEMES
        if Model_User.current_user.theme {
            // white bg black text
            
        } else {
            // dark theme. black bg white text
            
        }
        
        
        print("View did Load")

        
        establishMessageHandling()
        establishChannelJoinMessageHandling()
        establishStatusChangeHandling()
        establishChannelHandling()
        establishServerHandling()
        
        SocketIOManager.sharedInstance.subscribeToServer(username: Model_User.current_user.username, connect_string: "general")
        Model_Channel.current_channel._id = "5a06f87aa551eb6a1c6b9057" // default channel id
        
        
        //SocketIOManager.sharedInstance.requestSubscribedServers(username: Model_User.current_user.username)
   
        
        ViewController_Chat.hasLoaded = true
    }

    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared: chat : model channel current name: \(Model_Channel.current_channel.name)")
    
        serverSelectButton.setTitle(Model_Server.current_server.name, for: .normal)
        channelSelectButton.setTitle(Model_Channel.current_channel.name, for: .normal)

        shareableStringTextView.text = Model_Server.current_server.shareableLink
  
        
        // requeest messages for current channel.
       //curre SocketIOManager.sharedInstance.requestChannelsOfServer(username: Model_User.current_user.username, server_id: Model_Server.current_server._id)
        
        
        
        SocketIOManager.sharedInstance.requestMessagesByChannelId(username: Model_User.current_user.username, channel_id: Model_Channel.current_channel._id)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue_ChatToChannel" {
            if let viewController = segue.destination as? ViewController_ChannelSelect {
                if(responseChannels.count > 0){
                    viewController.channels = responseChannels
                }
            }
        }else if segue.identifier == "Segue_ChatToServer" {
            if let viewController = segue.destination as? ViewController_ServerSelect {
                if(responseServers.count > 0) {
                    viewController.servers = responseServers
                }
            }
        }
    }
    
    
   func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! TableViewCell_Chat
   
        let currentMessage = self.messageModel[indexPath.row]
        
        
        // Color the user name if it is the current user
        let attribString = NSMutableAttributedString(string: currentMessage.username, attributes: .none)
     
        if currentMessage.username == Model_User.current_user.username {
            let range = (currentMessage.username as NSString).range(of: currentMessage.username)
            attribString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: range)
        }
        
        // add our text to our views
        cell.dateTextView?.text = currentMessage.dateTime
        cell.usernameTextView?.attributedText = attribString
        cell.messageTextView?.text = currentMessage.message
        
        return cell
    }
 
}
