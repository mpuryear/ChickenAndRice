//
//  ViewController_ChannelSelect.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/12/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit

class ViewController_ChannelSelect: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    var channels : [Model_Channel] = []
    
    @IBOutlet weak var channelTableView: UITableView!
    
    @IBOutlet weak var newChannelTextField: UITextField!
    
    @IBAction func didTapCreateChannel(_ sender: Any) {
        if newChannelTextField.text != "" {
        SocketIOManager.sharedInstance.createChannel(username: Model_User.current_user.username, channel_name: newChannelTextField.text!, server_id: Model_Server.current_server._id)
        } else {
            
            let alert = UIAlertController(title: "Alert", message: "New channels must have a name ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    var selectedLabel : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        channelTableView.delegate = self
        channelTableView.dataSource = self
 
        
        SocketIOManager.sharedInstance.channelCreated(completionHandler: {
            (results) -> Void in
            self.appendToData(channel: results)
            self.channelTableView.reloadData()
        });
        
        
        
        SocketIOManager.sharedInstance.failedToCreateChannel(completionHandler: { () -> Void in
            let alert = UIAlertController(title: "Alert", message: "Failed to create channel", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        });
        // Do any additional setup after loading the view.
        if Model_User.current_user.theme {
            self.view.backgroundColor = UIColor.lightGray
            newChannelTextField.backgroundColor = UIColor.white
            self.view.backgroundColor = UIColor.lightGray
            channelTableView.backgroundColor = UIColor.lightGray
        } else {
            self.view.backgroundColor = UIColor.darkGray
            newChannelTextField.backgroundColor = UIColor.lightGray
            self.view.backgroundColor = UIColor.darkGray
            channelTableView.backgroundColor = UIColor.darkGray
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    func appendToData(channel: Model_Channel) {
        for c in channels {
            if c._id == channel._id {
                return
            }
        }
        channels.append(channel)
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
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! TableViewCell_Channel
        
        selectedLabel = (currentCell.channelName?.text)!
        
        // leave current channel
        SocketIOManager.sharedInstance.leaveChannel(username: Model_User.current_user.username, channel_id: Model_Channel.current_channel._id)
        
        // update our current channel
        Model_Channel.current_channel.name = selectedLabel
        Model_Channel.current_channel._id = self.channels[(indexPath?.row)!]._id
        
        // join newly selected channel
        SocketIOManager.sharedInstance.joinChannel(username: Model_User.current_user.username, channel_id: Model_Channel.current_channel._id)
        
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! TableViewCell_Channel
        
        let currentChannel = self.channels[indexPath.row]
        
        //Coloring text based on theme.
        if Model_User.current_user.theme {
            cell.channelName.textColor = UIColor.black
            cell.backgroundColor = UIColor.lightGray
            tableView.backgroundView?.backgroundColor = UIColor.lightGray
        } else {
            cell.channelName.textColor = UIColor.white
            cell.backgroundColor = UIColor.darkGray
            tableView.backgroundView?.backgroundColor = UIColor.darkGray
        }
        // add our text to our views
        cell.channelName.text = currentChannel.name
        
        return cell
    }
}
