//
//  ViewController_RegisterUser.swift
//  ChickenAndRice
//
//  Created by Mathew Puryear on 11/11/17.
//  Copyright © 2017 Mathew Puryear. All rights reserved.
//

import UIKit

class ViewController_RegisterUser: UIViewController {

    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func didTapRegister(_ sender: Any) {
                
        // check for username/password is empty and display an alert if so
        if usernameTextField!.text == "" || passwordTextField!.text == "" {
            // TODO add UIAlertController, see viewController_Login
            // cannot have empty fields
        } else {
            SocketIOManager.sharedInstance.attemptRegisterUser(username: usernameTextField.text!, password: passwordTextField.text!)
        }
        
    }
    
    func registerUserHandler() {
        SocketIOManager.sharedInstance.username_taken(completionHandler: {
           () -> Void in
            // UIAlertController for taken username, see viewController_Login
            let alert = UIAlertController(title: "Alert", message: "Username is already taken", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        
        SocketIOManager.sharedInstance.user_created(completionHandler: {
            () -> Void in
            // our username and password were valid, so simply go back to the login page
          self.performSegue(withIdentifier: "unwindRegisterToLogin", sender: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerUserHandler()
        
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

}
