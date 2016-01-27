//
//  KBHTextFieldStepper.swift
//  KBHTextFieldStepper
//
//  Created by Keith Hunter on 8/9/15.
//  Copyright © 2015 Keith Hunter. All rights reserved.
//

import UIKit

public class KBHTextFieldStepper: UIControl, UITextFieldDelegate {
	
	// MARK: Public Properties
	
	public var value: Double {
		get { return _value }
		set { setValue(newValue) }
	}
	public var minimumValue: Double = 0 {
		didSet {
			if value < minimumValue {
				value = minimumValue
			}
		}
	}
	public var maximumValue: Double = 100 {
		didSet {
			if value > maximumValue {
				value = maximumValue
			}
		}
	}
	public var stepValue: Double = 1
	public var textFieldDelegate: UITextFieldDelegate? {
		didSet { textField.delegate = textFieldDelegate }
	}
	public var wraps: Bool = false
	public var autorepeat: Bool = true
	public var continuous: Bool = true
	
	// MARK: Private Properties
	
	/// This is private so that no one can mess with the text field's configuration. Use value and textFieldDelegate to control text field customization.
	var textField: UITextField!
	private let numberFormatter: NSNumberFormatter = {
		let numberFormatter = NSNumberFormatter()
		numberFormatter.numberStyle = .DecimalStyle
		return numberFormatter
	}()
	private var _value: Double = 0
	
	/// A timer to implement the functionality of holding down one of the KBHTextFieldStepperButtons. Once started, the run loop will hold a strong reference to the timer, so this property can be weak. The timer is allocated once a button is pressed and deallocated once the button is unpressed.
	private weak var timer: NSTimer?
	
	private var rightDivider: UIView!
	private var leftDivider: UIView!
	
	public override func tintColorDidChange() {
		rightDivider.backgroundColor = tintColor
		leftDivider.backgroundColor = tintColor
		layer.borderColor = tintColor.CGColor
		super.tintColorDidChange()
	}
	
	// MARK: Initializers
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		let width = frame.size.width
		let height = frame.size.height
		let buttonWidth = height
		let buttonHeight = height
		backgroundColor = .whiteColor()
		
		// Buttons
		let minus = KBHTextFieldStepperButton(frame: CGRectMake(0, 0, buttonWidth, buttonHeight), type: .Minus)
		let plusFrame = CGRect(origin: CGPointMake(frame.size.width - minus.frame.size.width, 0), size: CGSizeMake(buttonWidth, buttonHeight))
		let plus = KBHTextFieldStepperButton(frame: plusFrame, type: .Plus)
		minus.addTarget(self, action: "minusTouchDown:", forControlEvents: .TouchDown)
		minus.addTarget(self, action: "minusTouchUp:", forControlEvents: .TouchUpInside)
		plus.addTarget(self, action: "plusTouchDown:", forControlEvents: .TouchDown)
		plus.addTarget(self, action: "plusTouchUp:", forControlEvents: .TouchUpInside)
		
		// Dividers
		leftDivider = UIView(frame: CGRectMake(minus.frame.size.width, 0, 1.5, height))
		rightDivider = UIView(frame: CGRectMake(frame.size.width - plus.frame.size.width, 0, 1.5, height))
		leftDivider.backgroundColor = tintColor
		rightDivider.backgroundColor = tintColor
		
		// Text Field
		textField = UITextField(frame: CGRectMake(leftDivider.frame.origin.x + leftDivider.frame.size.width, 0, rightDivider.frame.origin.x - (leftDivider.frame.origin.x + leftDivider.frame.size.width), height))
		textField.textAlignment = .Center
		textField.text = "0"
		textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
		textField.delegate = self
		
		// Layout:  - | textField | +
		addSubview(minus)
		addSubview(leftDivider)
		addSubview(textField)
		addSubview(rightDivider)
		addSubview(plus)
		
		// Border
		layer.borderWidth = 1
		layer.borderColor = tintColor.CGColor
		layer.cornerRadius = 5
		clipsToBounds = true
		
		value = minimumValue
	}
	
	// MARK: Getters/Setters
	
	private func setValue(value: Double) {
		if value > maximumValue {
			_value = wraps ? minimumValue : maximumValue
		} else if value < minimumValue {
			_value = wraps ? maximumValue : minimumValue
		} else {
			_value = value
		}
		
		textField.text = numberFormatter.stringFromNumber(NSNumber(double: _value))
	}
	
	// MARK: Actions
	
	internal func minusTouchDown(sender: KBHTextFieldStepperButton) { buttonTouchDown(sender, selector: "decrement") }
	internal func plusTouchDown(sender: KBHTextFieldStepperButton) { buttonTouchDown(sender, selector: "increment") }
	
	private func buttonTouchDown(sender: KBHTextFieldStepperButton, selector: Selector) {
		sender.backgroundColor = tintColor.colorWithAlphaComponent(0.15)
		sendSubviewToBack(sender)
		performSelector(selector)
		
		if autorepeat {
			timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: selector, userInfo: nil, repeats: true)
		}
	}
	
	internal func minusTouchUp(sender: KBHTextFieldStepperButton) { buttonTouchUp(sender) }
	internal func plusTouchUp(sender: KBHTextFieldStepperButton) { buttonTouchUp(sender) }
	
	private func buttonTouchUp(sender: KBHTextFieldStepperButton) {
		sender.backgroundColor = backgroundColor
		sendSubviewToBack(sender)
		
		guard let timer = timer else { return }
		timer.invalidate()
		
		// autorepeat is on since we used a timer. If not continuous, send the only value changed event
		if !continuous {
			sendActionsForControlEvents(.ValueChanged)
		}
	}
	
	internal func decrement() {
		let previousValue = value
		value -= stepValue
		if previousValue != value {
			sendValueChangedEvent()
		}
	}
	
	internal func increment() {
		let previousValue = value
		value += stepValue
		if previousValue != value {
			sendValueChangedEvent()
		}
	}
	
	private func sendValueChangedEvent() {
		if autorepeat && continuous {
			sendActionsForControlEvents(.ValueChanged)
		} else if !autorepeat {
			// If not using autorepeat, this is only called once. Send value changed updates
			sendActionsForControlEvents(.ValueChanged)
		}
	}
	
	// MARK: UITextFieldDelegate
	
	public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		if string == "\n" {
			textField.resignFirstResponder()
			return false
		}
		
		// Allow deleting characters
		if string.characters.count == 0 {
			return true
		}
		
		let legalCharacters = NSCharacterSet.decimalDigitCharacterSet().mutableCopy() as! NSMutableCharacterSet
		legalCharacters.addCharactersInString(".")
		legalCharacters.addCharactersInString("")
		
		if let char = string.utf16.first where legalCharacters.characterIsMember(char) {
			let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
			_value = Double(newString)!
			return true
		} else {
			return false
		}
	}
	
	public func textFieldDidEndEditing(textField: UITextField) {
		if textField.text?.characters.count == 0 {
			value = 0
		} else {
			value = Double(textField.text!)!
		}
		sendActionsForControlEvents(.ValueChanged)
	}
}

// MARK: - Private Classes

internal enum KBHTextFieldStepperButtonType {
	case Plus, Minus
}

internal class KBHTextFieldStepperButton: UIControl {
	
	private var type: KBHTextFieldStepperButtonType
	
	// MARK: Initializers
	
	internal required init(frame: CGRect, type: KBHTextFieldStepperButtonType) {
		self.type = type
		super.init(frame: frame)
		backgroundColor = .clearColor()
	}
	
	internal required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Drawing
	
	internal override func drawRect(rect: CGRect) {
		tintColor.setFill()
		
		if type == .Minus {
			drawMinus()
		} else {
			drawPlus()
		}
	}
	
	private func drawMinus() {
		let centerY = frame.size.height / 2
		let startX = frame.size.width / 4
		let endX = frame.size.width / 4 * 3
		let rect = CGRectMake(startX, centerY - 0.5, endX - startX, 1.5)
		let minus = UIBezierPath(rect: rect)
		minus.fill()
	}
	
	private func drawPlus() {
		let centerY = frame.size.height / 2
		let centerX = frame.size.width / 2
		let startX = frame.size.width / 4
		let endX = frame.size.width / 4 * 3
		
		let startY = frame.size.height / 4
		let endY = frame.size.height / 4 * 3
		
		let horiz = UIBezierPath(rect: CGRectMake(startX, centerY - 0.5, endX - startX, 1.5))
		horiz.fill()
		let vert = UIBezierPath(rect: CGRectMake(centerX - 0.5, startX, 1.5, endY - startY))
		vert.fill()
	}
	
	// MARK: Actions
	
	internal override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		sendActionsForControlEvents(.TouchDown)
	}
	
	internal override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		sendActionsForControlEvents(.TouchUpInside)
	}
}
