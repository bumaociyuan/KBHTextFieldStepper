//
//  KBHTextFieldStepper.swift
//  KBHTextFieldStepper
//
//  Created by Keith Hunter on 8/9/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit


public class KBHTextFieldStepper: UIControl {
    
    lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRectMake(48.5, 0, 20, 29))
        textField.textAlignment = .Center
        textField.text = "0"
//        textField.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
        return textField
    }()
    
    
    // MARK: - Initializers
    
    public init() {
        let theFrame = CGRectMake(0, 0, 114, 29)
        super.init(frame: theFrame)
        self.setup()
    }
    
    public override init(frame: CGRect) {
        let theFrame = CGRectMake(frame.origin.x, frame.origin.y, 114, 29)
        super.init(frame: theFrame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 114, 29)
    }
    
    private func setup() {
        // This class has a set frame where only the textField can change size: layout is the - | textField | +
        let minus = KBHTextFieldStepperButton(origin: CGPointMake(0, 0), type: .Minus)
        let plus = KBHTextFieldStepperButton(origin: CGPointMake(67, 0), type: .Plus)
        
        self.addSubview(minus)
        self.addSubview(self.textField)
        self.addSubview(plus)
        
        minus.addTarget(self, action: "decrement", forControlEvents: .TouchUpInside)
        plus.addTarget(self, action: "increment", forControlEvents: .TouchUpInside)
    }

    
    // MARK: - Drawing
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.tintColor.setStroke()
        self.tintColor.setFill()
        
        let outline = UIBezierPath(roundedRect: rect, cornerRadius: 5)
        outline.lineWidth = 1.5
        outline.stroke()
        
        let leftDivider = UIBezierPath(rect: CGRectMake(self.textField.frame.origin.x - 1.5, 0, 1.5, rect.size.height))
        leftDivider.fill()
        
        let rightDivider = UIBezierPath(rect: CGRectMake(self.textField.frame.origin.x + self.textField.frame.size.width, 0, 1.5, rect.size.height))
        rightDivider.fill()
    }
    
    
    // MARK: - Actions
    
    internal func decrement() {
        self.sendActionsForControlEvents(.ValueChanged)
    }
    
    internal func increment() {
        self.sendActionsForControlEvents(.ValueChanged)
    }

}


private enum KBHTextFieldStepperButtonType {
    case Plus, Minus
}

private class KBHTextFieldStepperButton: UIControl {
    
    var type: KBHTextFieldStepperButtonType
    
    
    // MARK: - Initializers
    
    required init(origin: CGPoint = CGPointMake(0, 0), type: KBHTextFieldStepperButtonType) {
        self.type = type
        super.init(frame: CGRectMake(origin.x, origin.y, 47, 29))
        self.backgroundColor = .clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Drawing
    
    private override func drawRect(rect: CGRect) {
        self.tintColor.setFill()
        
        if self.type == .Minus {
            self.drawMinus()
        } else {
            self.drawPlus()
        }
    }
    
    private func drawMinus() {
        let minus = UIBezierPath(rect: CGRectMake(15.6667, 14.5, 15.6667, 1.5))
        minus.fill()
    }
    
    private func drawPlus() {
        let horiz = UIBezierPath(rect: CGRectMake(15.6667, 14.5, 15.6667, 1.5))
        horiz.fill()
        let vert = UIBezierPath(rect: CGRectMake(23.5, 6.6665, 1.5, 15.6667))
        vert.fill()
    }
    
    private override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.sendActionsForControlEvents(.TouchUpInside)
    }
    
}
