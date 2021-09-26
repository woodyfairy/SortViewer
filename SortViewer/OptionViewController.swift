//
//  OptionViewController.swift
//  SortViewer
//
//  Created by fairy on 2021/9/17.
//

import UIKit

protocol OptionViewControllerDelegate : AnyObject {
    func optionViewDidOk(option : Option)
}

class OptionViewController: UIViewController {
    var option : Option? = nil
    weak var delegate : OptionViewControllerDelegate? = nil
    
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var timeInput: UITextField!
    @IBOutlet weak var showCheckSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberInput.keyboardType = .numberPad
        timeInput.keyboardType = .decimalPad
        
        if let option = option {
            numberInput.text = "\(option.number)"
            timeInput.text = "\(option.sortStepTime)"
            showCheckSwitch.isOn = option.showChecking
        }
        
        numberInput.addTarget(self, action: #selector(setNumber), for: .editingChanged)
        timeInput.addTarget(self, action: #selector(setTime), for: .editingChanged)
        showCheckSwitch.addTarget(self, action: #selector(setShowCheck), for: .valueChanged)
    }
    
    @objc private func setNumber(){
        let number : Int = numberInput.text?.toInt() ?? 0
        print ("number : \(number)")
        if number > 0 {
            option?.number = number
        }
    }
    @objc private func setTime(){
        let time : Double = timeInput.text?.toDouble() ?? 0
        print ("time : \(time)")
        if time > 0 {
            option?.sortStepTime = time
        }
    }
    @objc private func setShowCheck(){
        print ("showCheck : \(showCheckSwitch.isOn)")
        option?.showChecking = showCheckSwitch.isOn
    }
    
    @IBAction func clickOK(_ sender: Any) {
        if let option = option {
            delegate?.optionViewDidOk(option: option)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension String {
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Double
    public func toDouble() -> Double? {
      
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Float
    public func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Bool
    public func toBool() -> Bool? {
        let trimmedString = trimmed().lowercased()
        if trimmedString == "true" || trimmedString == "false" {
            return (trimmedString as NSString).boolValue
        }
        return nil
    }
    
    public func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
