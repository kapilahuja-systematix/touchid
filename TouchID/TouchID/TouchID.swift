//
//  TouchID.swift
//  TouchID
//
//  Created by Mac mini on 05/10/16.
//  Copyright © 2016 SIPL. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

@objc protocol TouchIDDelegate {
    @objc optional func TouchIDSuccedd()
    @objc optional func TouchIDFail(ErrorMessage: String)
    @objc optional func PasscodeSuccedd()
    @objc optional func PasscodeFail(ErrorMessage: String)
    @objc optional func SetUpPasscodeSuccedd()
    @objc optional func SetUpPasscodeFail(ErrorMessage: String)
    @objc optional func ChangePasscodeSuccedd()
    @objc optional func ChangePasscodeFail(ErrorMessage: String)
    @objc optional func SetingsPopUpResponse(Message: String)
}

class TouchID: NSObject {
    
    var Count = 0
    var Password = ""
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let sharedInstance = TouchID()
    var touchDelegate: TouchIDDelegate?
    
    func isPasscodeSetup() -> Bool {
        
        let oldPassword = UserDefaults.standard.value(forKey: "UserPassword") as? String
        
        if oldPassword != nil {
            if oldPassword?.characters.count == 4 {
                return true
            }
        }
        
        return false
    }
    
    func setupPassword() {
        
        var message = "Please type new passcode(4 digit) for application"
        
        if Count == 1 {
            message = "Please type passcode(4 digit) again"
        }
        
        let alert=UIAlertController(title: "TouchID", message: message, preferredStyle: UIAlertControllerStyle.alert);
        //default input textField (no configuration...)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        });
        //no event handler (just close dialog box)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
            self.Count = 0
            self.touchDelegate?.SetUpPasscodeFail!(ErrorMessage: "Cancel Clicked")
        }));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            let fields = alert.textFields!;
            
            if self.Count == 1 {
                if fields[0].text! == self.Password {
                    UserDefaults.standard.setValue(self.Password, forKey: "UserPassword")
                    self.touchDelegate?.SetUpPasscodeSuccedd!()
                }else{
                    self.Count = 0
                    self.setupPassword()
                    self.touchDelegate?.SetUpPasscodeFail!(ErrorMessage: "Reenterted Password Mismatch")
                }
            }else{
                self.Password = fields[0].text!
                
                if self.Password.characters.count == 4 {
                    self.Count = self.Count + 1
                }else{
                    self.touchDelegate?.SetUpPasscodeFail!(ErrorMessage: "Passcode is not of 4 digit.")
                }
                self.setupPassword()
            }
            
        }));
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil);
    }
    
    func changePassword() {
        
        let oldPassword = UserDefaults.standard.value(forKey: "UserPassword") as? String
        
        if oldPassword != nil {
            
            var message = "Please type current passcode(4 digit) for application"
            
            if Count == 1 {
                message = "Please type new passcode(4 digit) for application"
            }else if Count == 2 {
                message = "Please type passcode(4 digit) again"
            }
            
            let alert=UIAlertController(title: "TouchID", message: message, preferredStyle: UIAlertControllerStyle.alert);
            //default input textField (no configuration...)
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                textField.keyboardType = .numberPad
            });
            //no event handler (just close dialog box)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
                self.Count = 0
                self.touchDelegate?.ChangePasscodeFail!(ErrorMessage: "Cancel Clicked")
            }));
            //event handler with closure
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
                let fields = alert.textFields!;
                
                if self.Count == 1 {
                    self.Password = fields[0].text!
                    
                    if self.Password.characters.count == 4 {
                        self.Count = self.Count + 1
                    }else{
                        self.touchDelegate?.ChangePasscodeFail!(ErrorMessage: "Passcode is not of 4 digit.")
                    }
                    self.changePassword()
                }else if self.Count == 2 {
                    if fields[0].text! == self.Password {
                        UserDefaults.standard.setValue(self.Password, forKey: "UserPassword")
                        self.touchDelegate?.ChangePasscodeSuccedd!()
                    }else{
                        self.Count = 0
                        self.changePassword()
                        self.touchDelegate?.ChangePasscodeFail!(ErrorMessage: "Reenterted Password Mismatch")
                    }
                }else{
                    if fields[0].text! == oldPassword {
                        self.Count = self.Count + 1
                    }else{
                        self.touchDelegate?.ChangePasscodeFail!(ErrorMessage: "Current Password is Incorrect")
                    }
                    self.changePassword()
                }
                
            }));
            appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil);
        }
        
    }
    
    func authenticateUser() {
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Authentication is needed to access application."
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success, evalPolicyError) in
                
                if success {
                    self.touchDelegate?.TouchIDSuccedd!()
                }
                else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    switch (evalPolicyError as! NSError).code{
                        
                    case LAError.systemCancel.rawValue:
                        self.showPasswordAlert()
                        self.touchDelegate?.TouchIDFail!(ErrorMessage: "Authentication was cancelled by the system")
                        
                    case LAError.userCancel.rawValue:
                        self.showPasswordAlert()
                        self.touchDelegate?.TouchIDFail!(ErrorMessage: "Authentication was cancelled by the user")
                        
                    case LAError.userFallback.rawValue:
                        self.showPasswordAlert()
                        self.touchDelegate?.TouchIDFail!(ErrorMessage: "User selected to enter custom password")
                        
                    default:
                        self.showPasswordAlert()
                        self.touchDelegate?.TouchIDFail!(ErrorMessage: "Authentication failed")
                    }
                }
            })
        }
        else{
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
                
            case LAError.touchIDNotEnrolled.rawValue:
                showSettingAlert(message:"TouchID is not enrolled")
                self.touchDelegate?.TouchIDFail!(ErrorMessage: "TouchID is not enrolled")
                
            case LAError.passcodeNotSet.rawValue:
                showSettingAlert(message:"A passcode has not been set")
                self.touchDelegate?.TouchIDFail!(ErrorMessage: "A passcode has not been set")
                
            case LAError.touchIDNotAvailable.rawValue:
                self.showPasswordAlert()
                self.touchDelegate?.TouchIDFail!(ErrorMessage: "TouchID not available")
                
            default:
                self.showPasswordAlert()
                self.touchDelegate?.TouchIDFail!(ErrorMessage: (error?.localizedDescription)!)
            }
            
            // Optionally the error description can be displayed on the console.
            
            
            // Show the custom alert view to allow users to enter the password.
        }
    }
    
    func showPasswordAlert() {
        
        let oldPassword = UserDefaults.standard.value(forKey: "UserPassword") as? String
        
        let alert=UIAlertController(title: "TouchID", message: "Please type your password", preferredStyle: UIAlertControllerStyle.alert);
        //default input textField (no configuration...)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        });
        //no event handler (just close dialog box)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
            self.touchDelegate?.PasscodeFail!(ErrorMessage: "Cancel Clicked")
        }));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            let fields = alert.textFields!;
            
            if fields[0].text! == oldPassword {
                //Pass
                self.touchDelegate?.PasscodeSuccedd!()
            }else{
                self.showPasswordAlert()
                self.touchDelegate?.PasscodeFail!(ErrorMessage: "Incorrect Passcode Entered")
            }
            
        }));
        DispatchQueue.main.async {
            self.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil);
        }
        
    }
    
    func showSettingAlert(message: String) {
        let alert=UIAlertController(title: "Message", message: "\(message), please go to setting and take proper actions", preferredStyle: UIAlertControllerStyle.alert);
        //no event handler (just close dialog box)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
            self.touchDelegate?.SetingsPopUpResponse!(Message: "Cancel Clicked")
        }));
        //event handler with closure
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.openURL(settingsURL as URL)
                }
                self.touchDelegate?.SetingsPopUpResponse!(Message: "Setting Clicked")
            }
        }));
        DispatchQueue.main.async {
            self.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil);
        }
    }

}
