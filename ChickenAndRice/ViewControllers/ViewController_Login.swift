//
//  ViewController.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/6/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit

class ViewController_Login: UIViewController {


    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func didReleaseButton(_ sender: Any) {
        print("Connect Button Pressed")
        
        SocketIOManager.sharedInstance.connectToServer(username: usernameTextField.text!, password: passwordTextField.text!,
            completionHandler: { (userList) -> Void in
            DispatchQueue.main.async { () -> Void in
                if userList != nil {
                    print("userList not nil")
                    for user in userList! {
                    print("user connected: \(user)" )
                }
            }
        }
                                                        
        })
        
        Model_User.current_user.username = usernameTextField.text!
        Model_User.current_user.password = passwordTextField.text!

        
        SocketIOManager.sharedInstance.loginAuthenticated(username: usernameTextField.text!, completionHandler: { () -> Void in
            DispatchQueue.main.async{
                () -> Void in
                Model_User.current_user.authenticated = true
                self.performSegue(withIdentifier: "Segue_LoginToChat", sender: nil)
            }
        })
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
    SocketIOManager.sharedInstance.invalidLogin(completionHandler: { () -> Void in
            DispatchQueue.main.async{
                () -> Void in
                Model_User.current_user.authenticated = false
                
                let alert = UIAlertController(title: "Alert", message: "Incorrect username/password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        // Do any additional setup after loading the view, typically from a nib.
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

