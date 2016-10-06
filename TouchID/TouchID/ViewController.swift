//
//  ViewController.swift
//  TouchID
//
//  Created by Mac mini on 28/09/16.
//  Copyright © 2016 SIPL. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TouchIDDelegate {
    
    @IBOutlet var touchAuthentication: TouchID! = TouchID.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /* Check if Passcode is already set for application*/
        touchAuthentication.touchDelegate = self
        if !touchAuthentication.isPasscodeSetup() {
            touchAuthentication.setupPassword()
        }else{
            touchAuthentication.authenticateUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- TouchIDDelegate
    
    func TouchIDSuccedd() {
        // Implementation After Authentication Pass
    }
    
    func TouchIDFail(ErrorMessage: String) {
        // Authentication Fail/Error
        print("\(ErrorMessage)")
    }
    
    func SetUpPasscodeSuccedd() {
        // Implementation After SetUpPasscode Pass
    }
    
    func SetUpPasscodeFail(ErrorMessage: String) {
        // SetUpPasscode Fail/Error
        print("\(ErrorMessage)")
    }
    
    func PasscodeSuccedd() {
        // Implementation After Authentication Pass
    }
    
    func PasscodeFail(ErrorMessage: String) {
        // Passcode Fail/Error
        print("\(ErrorMessage)")
    }
    
    func SetingsPopUpResponse(Message: String) {
        // SetingsPopUpResponse
        print("\(Message)")
    }
}

