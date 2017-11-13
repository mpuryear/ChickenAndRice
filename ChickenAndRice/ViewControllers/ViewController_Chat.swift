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
    
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
  
    @IBOutlet weak var shareableStringTextView: UITextView!
    
    @IBOutlet weak var serverSelectButton: UIButton!
    
    @IBOutlet weak var channelSelectButton: UIButton!
    
    @IBAction func didTapServerSelect(_ sender: Any) {
        self.performSegue(withIdentifier: "Segue_ChatToServer", sender: self)
    }
    @IBAction func didTapDisconnect(_ sender: Any) {
        //SocketIOManager.sharedInstance.closeConnection()
        handleDisconnected()
        SocketIOManager.sharedInstance.closeConnection()
    }
    
    
    @IBAction func didTapChannelSelect(_ sender: Any) {

        // clear messages
        messageModel.removeAll()
        chatTableView.reloadData()
        
        self.performSegue(withIdentifier: "Segue_ChatToChannel", sender: self)
        
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        print("didTapSend")
        if let text = messageTextField.text, !text.isEmpty {
            SocketIOManager.sharedInstance.sendMessage(message: messageTextField.text!, withUsername: Model_User.current_user.username,
                                                       room: Model_Channel.current_channel.name )
            
            messageTextField.text = "" // clear the text box
        }
        /*
           SocketIOManager.sharedInstance.requestSubscribedServers(username: Model_User.current_user.username)
 */
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
            }
        })
    }
    
    func establishServerHandling() {
        SocketIOManager.sharedInstance.getServer(completionHandler: {
            (results) -> Void in DispatchQueue.main.async {
                self.responseServers = results
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
       //self.performSegue(withIdentifier: "unwindChatToLogin", sender: nil)
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
     //   SocketIOManager.sharedInstance.reconnect()
    }
    
    func handleDisconnected() {
       // self.performSegue(withIdentifier: "unwindChatToLogin", sender: nil)
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
     //   SocketIOManager.sharedInstance.reconnect()
       
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 44
        chatTableView.separatorStyle = .none   

    
        print("View did Load")

        
        establishMessageHandling()
        establishStatusChangeHandling()
        establishChannelHandling()
        establishServerHandling()
        
        SocketIOManager.sharedInstance.subscribeToServer(username: Model_User.current_user.username, connect_string: "general")
        
        SocketIOManager.sharedInstance.requestSubscribedServers(username: Model_User.current_user.username)
       
        // get channels for our default server
        SocketIOManager.sharedInstance.requestChannelsOfServer(username: Model_User.current_user.username, server_id: Model_Server.current_server._id)
        
        ViewController_Chat.hasLoaded = true
    }

    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared: chat : model channel current name: \(Model_Channel.current_channel.name)")
    
        serverSelectButton.setTitle(Model_Server.current_server.name, for: .normal)
        channelSelectButton.setTitle(Model_Channel.current_channel.name, for: .normal)

            shareableStringTextView.text = Model_Server.current_server.shareableLink
        
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
