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
    
    var selectedLabel : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        channelTableView.delegate = self
        channelTableView.dataSource = self
 
        
        // Do any additional setup after loading the view.
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! TableViewCell_Channel
        
        selectedLabel = (currentCell.channelName?.text)!
        
        SocketIOManager.sharedInstance.leaveServer(username: Model_User.current_user.username, room: Model_Channel.current_channel.name)
        
        Model_Channel.current_channel.name = selectedLabel
        
        SocketIOManager.sharedInstance.joinServer(username: Model_User.current_user.username, room: Model_Channel.current_channel.name)
        
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
        
        
        // Color the user name if it is the current user
    
        // add our text to our views
        cell.channelName.text = currentChannel.name
        
        return cell
    }
}
