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

    var player: AVAudioPlayer?
    
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func didTapSend(_ sender: Any) {
        print("didTapSend")
        if let text = messageTextField.text, !text.isEmpty {
            SocketIOManager.sharedInstance.sendMessage(message: messageTextField.text!, withUsername: Model_User.current_user.username)
            
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
    
    func establishMessageHandling() {
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
            
            print("message appended: " + currentMessage.message)
            self.messageModel.append(currentMessage)
            self.chatTableView.reloadData()
        
            
            self.playMessageNotification()
            
            // scroll to bottom of the tableview
            let indexPath = NSIndexPath(row: self.messageModel.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
        

            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatTableView.delegate = self
        chatTableView.dataSource = self

        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 44
        chatTableView.separatorStyle = .none   
        
        establishMessageHandling()
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
        
        
        
        print("dateTime: \(cell.dateTextView.text)")
        return cell
    }
    
}
