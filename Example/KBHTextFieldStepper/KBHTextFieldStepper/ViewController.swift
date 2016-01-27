//
//  ViewController.swift
//  KBHTextFieldStepper
//
//  Created by Keith Hunter on 8/9/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textFieldStepper = KBHTextFieldStepper(frame: CGRectMake(16, 28, 240, 60))
        textFieldStepper.tintColor = UIColor ( red: 0.4745, green: 0.4627, blue: 0.5333, alpha: 1.0 )
        textFieldStepper.textField.keyboardType = .NumberPad
        self.view.addSubview(textFieldStepper)
        textFieldStepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
    }
    
    func stepperValueChanged(sender:KBHTextFieldStepper) {
       print("\(sender.value)")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}

