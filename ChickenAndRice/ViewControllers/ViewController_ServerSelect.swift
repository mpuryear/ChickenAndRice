//
//  ViewController_ServerSelect.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/12/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit

import UIKit

class ViewController_ServerSelect: UIViewController,  UITableViewDataSource, UITableViewDelegate {
    
    var servers : [Model_Server] = []
    
    
    @IBOutlet weak var serverTableView: UITableView!
    
    @IBOutlet weak var shareableStringTextView: UITextView!
    
    
    @IBOutlet weak var inputTextField: UITextField!
    var selectedLabel : String = ""
  
    @IBAction func didTapJoinServer(_ sender: Any) {
        // attempt to join based on connect string
        
        if inputTextField.text == "" {
            // TODO Alert user there must be text in the field

            
            return;
        }
        
        SocketIOManager.sharedInstance.subscribeToServer(username: Model_User.current_user.username, connect_string: inputTextField.text!)
    }
    
    @IBAction func didTapCreateServer(_ sender: Any) {
        // create a new server with name
        
        if inputTextField.text == "" {
            // TODO Alert user there must be text in the field
            
            return;
        }
        
        SocketIOManager.sharedInstance.createServer(username: Model_User.current_user.username, servername: inputTextField.text!)
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        serverTableView.delegate = self
        serverTableView.dataSource = self
        
        SocketIOManager.sharedInstance.serverCreated(completionHandler: {
            (results) -> Void in
            self.appendToData(server: results)
            self.serverTableView.reloadData()
        });
        
        SocketIOManager.sharedInstance.serverSubscribeSuccess(completionHandler: {
           (results) -> Void in
            self.appendToData(server: results)
            self.serverTableView.reloadData()
        });
        
        SocketIOManager.sharedInstance.failedToJoinServer(completionHandler: { () -> Void in
            
            // TODO Alert user that this server doesnt exist via UIALert
            // see login view controller for example
            
        });
        
    SocketIOManager.sharedInstance.failedToCreateServer(completionHandler: {
            () -> Void in
        // TODO Alert user that this server doesnt exist via UIALert
        // see login view controller for example
        
        });
        
        SocketIOManager.sharedInstance.getChannel(completionHandler: { (channel) -> Void in
               Model_Channel.current_channel.name = channel[0].name
        });
        
        
        SocketIOManager.sharedInstance.getChannel(completionHandler: {
            (results) -> Void in DispatchQueue.main.async {
                
               
                    Model_Channel.current_channel._id = results[0]._id
                    Model_Channel.current_channel.name = results[0].name
                    
               
                }
           
           
        })
        // Do any additional setup after loading the view.
        
        shareableStringTextView.text = Model_Server.current_server.shareableLink
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appendToData(server: Model_Server) {
        for s in servers {
            if s._id == server._id {
                return
            }
        }
        servers.append(server)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! TableViewCell_Server
        
        selectedLabel = (currentCell.serverName?.text)!
      
        // Leave our current channel and then join the default of our newly selected server
        SocketIOManager.sharedInstance.leaveChannel(username: Model_User.current_user.username, channel_id: Model_Channel.current_channel._id)

        
        Model_Server.current_server.name = self.servers[indexPath!.row].name
        Model_Server.current_server._id = self.servers[indexPath!.row]._id
        Model_Server.current_server.default_channel = self.servers[indexPath!.row].default_channel

        
        SocketIOManager.sharedInstance.joinChannel(username: Model_User.current_user.username, channel_id: Model_Server.current_server.default_channel)
 
        
        
       Model_Server.current_server.shareableLink =
        self.servers[indexPath!.row].shareableLink;
       
        
        SocketIOManager.sharedInstance.requestChannelsOfServer(username: Model_User.current_user.username, server_id: Model_Server.current_server._id)
        
        
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.servers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell", for: indexPath) as! TableViewCell_Server
        
        let currentServer = self.servers[indexPath.row]
        
        
        // Color the user name if it is the current user
        
        // add our text to our views
        cell.serverName.text = currentServer.name
        
        return cell
    }
}
