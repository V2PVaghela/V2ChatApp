//
//  SettingsViewController.swift
//  V2ChatApp
//
//  Created by Paresh on 24/08/16.
//  Copyright © 2016 V2Solutions. All rights reserved.
//

import UIKit
import XMPPFramework
import xmpp_messenger_ios

class SettingsViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var validateButton: UIButton!
    
    // Mark: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if OneChat.sharedInstance.isConnected() {
            usernameTextField.hidden = true
            passwordTextField.hidden = true
            validateButton.setTitle("Disconnect", forState: UIControlState.Normal)
        } else {
            if NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID) != "kXMPPmyJID" {
                usernameTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myJID)
                passwordTextField.text = NSUserDefaults.standardUserDefaults().stringForKey(kXMPP.myPassword)
                usernameTextField.text = "harshal@v2mummac0024.local"
                passwordTextField.text = "mail_123"
            }
        }
    }
    
    // Mark: Private Methods
    
    func DismissKeyboard() {
        if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
    }
    
    // Mark: IBAction
    
    @IBAction func validate(sender: AnyObject) {
        if OneChat.sharedInstance.isConnected() {
            OneChat.sharedInstance.disconnect()
            usernameTextField.hidden = false
            passwordTextField.hidden = false
            validateButton.setTitle("Validate", forState: UIControlState.Normal)
        } else {
            OneChat.sharedInstance.connect(username: self.usernameTextField.text!, password: self.passwordTextField.text!) { (stream, error) -> Void in
                if let _ = error {
                    let alertController = UIAlertController(title: "Sorry", message: "An error occured: \(error)", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        //do something
                    }))
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mark: UITextField Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if passwordTextField.isFirstResponder() {
            textField.resignFirstResponder()
            validate(self)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // Mark: Memory Management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
