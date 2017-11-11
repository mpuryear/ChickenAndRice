//
//  ViewController.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/6/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit

class ViewController_Login: UIViewController {

    class Toast
    {
        class private func showAlert(backgroundColor:UIColor, textColor:UIColor, message:String)
        {
            
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let label = UILabel(frame: CGRect.zero)
            label.textAlignment = NSTextAlignment.center
            label.text = message
            label.font = UIFont(name: "", size: 15)
            label.adjustsFontSizeToFitWidth = true
            
            label.backgroundColor =  backgroundColor //UIColor.whiteColor()
            label.textColor = textColor //TEXT COLOR
            
            label.sizeToFit()
            label.numberOfLines = 4
            label.layer.shadowColor = UIColor.gray.cgColor
            label.layer.shadowOffset = CGSize(width: 4, height: 3)
            label.layer.shadowOpacity = 0.3
            label.frame = CGRect(x: appDelegate.window!.frame.size.width, y: 64, width: appDelegate.window!.frame.size.width, height: 44)
            
            label.alpha = 1
            
            appDelegate.window!.addSubview(label)
            
            var basketTopFrame: CGRect = label.frame;
            basketTopFrame.origin.x = 0;
            
            UIView.animate(withDuration
                :2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                    label.frame = basketTopFrame
            },  completion: {
                (value: Bool) in
                UIView.animate(withDuration:2.0, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    label.alpha = 0
                },  completion: {
                    (value: Bool) in
                    label.removeFromSuperview()
                })
            })
        }
        
        class func showPositiveMessage(message:String)
        {
            showAlert(backgroundColor: UIColor.green, textColor: UIColor.white, message: message)
        }
        class func showNegativeMessage(message:String)
        {
            showAlert(backgroundColor: UIColor.red, textColor: UIColor.white, message: message)
        }
    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
        
    }

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func didReleaseButton(_ sender: Any) {
        print("Connect Button Pressed")
       
        Model_User.current_user.username = usernameTextField.text!
        Model_User.current_user.password = passwordTextField.text!
        connectToServer()

    }
    
    func connectToServer() {
        SocketIOManager.sharedInstance.connectToServer(username: usernameTextField.text!, password: passwordTextField.text!)
    }
    
    func authenticateLogin() {

        SocketIOManager.sharedInstance.loginAuthenticated(username: usernameTextField.text!, completionHandler: { () -> Void in
            print("\ncalled\n")
            self.performSegue(withIdentifier: "Segue_LoginToChat", sender: self)
            Model_User.current_user.authenticated = true
        })
        
    }
    
    func handleConnected() {
        
    }
    
    func handleConnecting() {
    }
    
    func handleDisconnected() {
        //reconnect
    SocketIOManager.sharedInstance.reconnect()
   }
    
    func handleNotConnected() {
        Toast.showPositiveMessage(message: "Disconnected")
       SocketIOManager.sharedInstance.reconnect()
    }
    
    func establishStatusChangeHandling() {
        SocketIOManager.sharedInstance.statusChangeHandler(completionHandler: {
            
            (status) ->  Void in DispatchQueue.main.async{
                () -> Void in
                
                let response = status as String
                print("\n\n\n LOGIN_VC:  \(response)")
               
                
                switch(response) {
                case "notConnected": self.handleNotConnected()
                case "disconnected": self.handleDisconnected()
                case "connecting": self.handleConnecting()
                case "connected": self.handleConnected()
                default: break
                }
                
               
             }
 
            });
    }
    
    func establishInvalidLoginHandling() {
        SocketIOManager.sharedInstance.invalidLogin(completionHandler: { () -> Void in
            DispatchQueue.main.async{
                () -> Void in
                Model_User.current_user.authenticated = false
                
                let alert = UIAlertController(title: "Alert", message: "Incorrect username/password", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
 
        
        print("\nViewdidLoad\n")
        SocketIOManager.sharedInstance.onAny()
        establishStatusChangeHandling() 
        authenticateLogin()
        
        SocketIOManager.sharedInstance.establishConnection()

       // establishInvalidLoginHandling()
  

 
        // Do any additional setup after loading the view, typically from a nib.
   
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Model_User.current_user.authenticated = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

