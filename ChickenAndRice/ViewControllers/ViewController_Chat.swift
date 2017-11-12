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

    var list = ["1", "2", "3"]
    var responseChannels : [String] = []
    
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var serverSelectButton: UIButton!
    
    @IBAction func didTapServerSelect(_ sender: Any) {

    }
    @IBAction func didTapDisconnect(_ sender: Any) {
        //SocketIOManager.sharedInstance.closeConnection()
        handleDisconnected()
        SocketIOManager.sharedInstance.closeConnection()
    }
    
    
    @IBAction func didTapChannelSelect(_ sender: Any) {
       

        
        // leave current server
        /*
        SocketIOManager.sharedInstance.leaveServer(username: Model_User.current_user.username, room: (serverSelectButton.titleLabel?.text)!)
        
        
        if serverSelectButton.titleLabel?.text == "test1" {
            serverSelectButton.setTitle("test2",for: .normal)
            SocketIOManager.sharedInstance.subscribeToServer(username:   Model_User.current_user.username, connect_string: "rice")
              SocketIOManager.sharedInstance.joinServer(username: Model_User.current_user.username, room: "test2")


        } else if serverSelectButton.titleLabel?.text == "test2" {
            serverSelectButton.setTitle("channel1",for: .normal)
            
           SocketIOManager.sharedInstance.subscribeToServer(username: Model_User.current_user.username, connect_string: "chicken")
            SocketIOManager.sharedInstance.joinServer(username: Model_User.current_user.username, room: "channel1")
        } else if serverSelectButton.titleLabel?.text == "channel1" {
            serverSelectButton.setTitle("test1",for: .normal)
           /*
            SocketIOManager.sharedInstance.subscribeToServer(username: Model_User.current_user.username, connect_string: "chicken")
             */
            SocketIOManager.sharedInstance.joinServer(username: Model_User.current_user.username, room: "test1")
        }

        // clear messages
        messageModel.removeAll()
        chatTableView.reloadData()
        */
        self.performSegue(withIdentifier: "Segue_ChatToChannel", sender: self)
        
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        print("didTapSend")
        if let text = messageTextField.text, !text.isEmpty {
            SocketIOManager.sharedInstance.sendMessage(message: messageTextField.text!, withUsername: Model_User.current_user.username,
                                                       room: Model_Channel.current_channel.name )
            
            messageTextField.text = "" // clear the text box
        }
        
           SocketIOManager.sharedInstance.requestSubscribedServers(username: Model_User.current_user.username)
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
                self.responseChannels.append(results)
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
       
        // get channels for our default server
        SocketIOManager.sharedInstance.requestChannelsOfServer(username: Model_User.current_user.username, server_id: "5a06efb2aa678b690467ae85")
        
        ViewController_Chat.hasLoaded = true
    }

    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared: chat : model channel current name: \(Model_Channel.current_channel.name)")
//        serverSelectButton.titleLabel!.text = Model_Channel.current_channel.name
        serverSelectButton.setTitle(Model_Channel.current_channel.name, for: .normal)

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
