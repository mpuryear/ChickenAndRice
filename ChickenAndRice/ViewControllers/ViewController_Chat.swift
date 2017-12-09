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

    var thmbIdx : Int = 0
    
    var responseChannels : [Model_Channel] = []
    var responseServers : [Model_Server] = []
    var clickedChannels : Bool = false
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var chatTableView: UITableView!
    
    
    @IBOutlet weak var dayThemeButton: UIButton!
    @IBOutlet weak var nightThemeButton: UIButton!
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
    
    @IBAction func didTapDayTheme(_ sender: UIButton) {
        dayThemeButton.isHidden = true
        nightThemeButton.isHidden = false
        Model_User.current_user.theme = true
        messageTextField.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.lightGray
        
        self.chatTableView.reloadData()
        
    }
    
    
    @IBAction func didTapNightTheme(_ sender: UIButton) {
        nightThemeButton.isHidden = true
        dayThemeButton.isHidden = false
        Model_User.current_user.theme = false
        messageTextField.backgroundColor = UIColor.lightGray
        self.view.backgroundColor = UIColor.darkGray
        
        self.chatTableView.reloadData()
    }
    
    
    @IBOutlet weak var serverSelectButton: UIButton!
    
    @IBOutlet weak var channelSelectButton: UIButton!
    
    @IBOutlet weak var thumbnailButton: UIButton!
    
    @IBAction func didTapServerSelect(_ sender: Any) {
       SocketIOManager.sharedInstance.requestSubscribedServers(username: Model_User.current_user.username)
    }
        
    
    @IBAction func didTapChannelSelect(_ sender: Any) {
        SocketIOManager.sharedInstance.requestChannelsOfServer(username: Model_User.current_user.username, server_id: Model_Server.current_server._id)
       clickedChannels = true
    }
    
    
    @IBAction func didTapThumbnail(_ sender: Any) {
        
        print("didTapThumbnail")

        // TODO:  implement gallery image picker
        // http://www.codingexplorer.com/choosing-images-with-uiimagepickercontroller-in-swift/
        
        

        // This simply allows us to cycle through our images in ./Art
        var image : UIImage
        /*
        let string0 = "cat"
        let string1 = "send_icon"
        let string2 = "chicken_and_rice"
        
        
        // for testing cycle between thumbnails.
        let path0 = Bundle.main.path(forResource: string0, ofType: "png")
        let path1 = Bundle.main.path(forResource: string1, ofType: "png")
        let path2 = Bundle.main.path(forResource: string2, ofType: "jpeg")
        
        var thumbnail : Data
        switch thmbIdx {
        case 1: thumbnail = (NSData.init(contentsOfFile: path1!) as Data?)!
        image = UIImage(imageLiteralResourceName: string1 + ".png")
        case 2: thumbnail = (NSData.init(contentsOfFile: path2!) as Data?)!
        image = UIImage(imageLiteralResourceName: string2 + ".jpeg")//(UIImage(named: string2) as UIImage?)!
        default: thumbnail = (NSData.init(contentsOfFile: path0!) as Data?)!
        image = UIImage(imageLiteralResourceName: string0 + ".png")
        }
        thmbIdx = (thmbIdx + 1) % 3
        print("thmbIdx \(thmbIdx)")
        

        image = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        
        thumbnailButton.setTitle("", for: .normal)
//        thumbnailButton.setImage(image, for: .normal)
        thumbnailButton.setBackgroundImage(image, for: .normal)

        
        Model_User.current_user.thumbnail = thumbnail
        
        
        // We will call this when the user actually selects a thumbnail, not just at the end of this func
        SocketIOManager.sharedInstance.changeUserThumbnail(username: Model_User.current_user.username, thumbnail: thumbnail)
 */
        
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        print("didTapSend")
        if let text = messageTextField.text, !text.isEmpty {
            SocketIOManager.sharedInstance.sendMessage(
                message: messageTextField.text!,
                withUsername: Model_User.current_user.username,
                channel_id: Model_Channel.current_channel._id,
                thumbnail: Model_User.current_user.thumbnail!
            )
            
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
        SocketIOManager.sharedInstance.getChatMessage(completionHandler: { (message) -> Void in DispatchQueue.main.async{
            () -> Void in

            
            // now that we recieved a message, we need to get the thumbnail from the server.
            
            
            print("\nmessage appended\n")
            self.messageModel.append(message)
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
            dayThemeButton.isHidden = true
            nightThemeButton.isHidden = false
            messageTextField.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.lightGray
            chatTableView.backgroundColor = UIColor.lightGray
        } else {
            nightThemeButton.isHidden = true
            dayThemeButton.isHidden = false
            messageTextField.backgroundColor = UIColor.lightGray
            self.view.backgroundColor = UIColor.darkGray
            chatTableView.backgroundColor = UIColor.darkGray
        }
        
        
        print("View did Load")

        
        establishMessageHandling()
        establishChannelJoinMessageHandling()
        establishStatusChangeHandling()
        establishChannelHandling()
        establishServerHandling()
        
        SocketIOManager.sharedInstance.subscribeToServer(username: Model_User.current_user.username, connect_string: "general")
        Model_Channel.current_channel._id = "5a06f87aa551eb6a1c6b9057" // default channel id
        
        serverSelectButton.setTitle("Server Select", for: .normal)
        channelSelectButton.setTitle("Channel Select", for: .normal)
        
   
        
        ViewController_Chat.hasLoaded = true
    }

    
    override func viewDidAppear(_ animated: Bool) {
        print("view appeared: chat : model channel current name: \(Model_Channel.current_channel.name)")
    
        //serverSelectButton.setTitle(Model_Server.current_server.name, for: .normal)
        //channelSelectButton.setTitle(Model_Channel.current_channel.name, for: .normal)

        //shareableStringTextView.text = Model_Server.current_server.shareableLink
  
        
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
        let attribString = NSMutableAttributedString(string: currentMessage.username, attributes: .none)
    
        //Coloring text based on theme.
        if Model_User.current_user.theme {
            cell.messageTextView.textColor = UIColor.black
            cell.backgroundColor = UIColor.lightGray
            cell.messageTextView.backgroundColor = UIColor.lightGray
            cell.contentView.backgroundColor = UIColor.lightGray
            cell.dateTextView.textColor = UIColor.black
            //cell.usernameTextView.textColor = UIColor.black
            
            let range = (currentMessage.username as NSString).range(of: currentMessage.username)
            attribString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: range)
        } else {
            cell.messageTextView.textColor = UIColor.white
            cell.backgroundColor = UIColor.darkGray
            cell.messageTextView.backgroundColor = UIColor.darkGray
            cell.contentView.backgroundColor = UIColor.darkGray
            cell.dateTextView.textColor = UIColor.white
            //cell.usernameTextView = UIColor.white
            
            let range = (currentMessage.username as NSString).range(of: currentMessage.username)
            attribString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: range)
        }
        
        if currentMessage.username == Model_User.current_user.username {
            let range = (currentMessage.username as NSString).range(of: currentMessage.username)
            attribString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: range)
        }
        
        
        // add our text to our views
        cell.dateTextView?.text = currentMessage.dateTime
        cell.usernameTextView?.attributedText = attribString
        cell.messageTextView?.text = currentMessage.message
        cell.thumbnail.image = UIImage(data: currentMessage.thumbnail!)
        cell.thumbnail.image = resizeImage(image: cell.thumbnail.image!, targetSize: CGSize(width: 32, height: 32))
        
        
        
        return cell
    }
    
    // resize the image to targetSize
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
 
}
