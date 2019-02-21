//
//  CustomPlaceholderTextFieldHandler.swift
//  CreditcardUI
//
//  Created by Ankur on 2/20/19.
//  Copyright © 2019 ankur. All rights reserved.

import Foundation
import UIKit

enum CardType: String {
    case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay
    
    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay]
    
    var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .Diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
            return "^(62|88)[0-9]{5,}$"
        case .Hipercard:
            return "^(606282|3841)[0-9]{5,}$"
        case .Elo:
            return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        default:
            return ""
        }
    }
}

class CustomPlaceholderTextFieldHandler: NSObject {
    let placeholderText: String
    let placeholderAttributes = [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
    let inputAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    var input = ""
    
    init(placeholder: String) {
        self.placeholderText = placeholder
        super.init()
    }
    
    func resetPlaceholder(for textField: UITextField) {
        input = ""
        setCombinedText(for: textField)
    }
    
    fileprivate func setCursorPosition(for textField: UITextField) {
        guard let cursorPosition = textField.position(from: textField.beginningOfDocument, offset: input.count)
            else { return }
        
        textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
    }
    
    fileprivate func setCombinedText(for textField: UITextField) {
        let placeholderSubstring = String(placeholderText[input.endIndex...])//placeholderText.substring(from: input.endIndex)
        let attributedString = NSMutableAttributedString(string: input + placeholderSubstring, attributes: placeholderAttributes)

        attributedString.addAttributes(inputAttributes, range: NSMakeRange(0, input.count))
        
        textField.attributedText = attributedString
    }
}

extension CustomPlaceholderTextFieldHandler: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 19 {
            return false
        }
        if string == "" {
            if input.count > 0 {
                input = input.substring(to: input.index(before: input.endIndex))
            }
        } else {
           
            if(range.location == 3 || range.location == 8 || range.location == 13){
                input += string + " "
            }
            else{
                 input += string
            }
        }
        if(input.count == 0){
            let cardDataDict:[String: Any] = ["type": "Reset","formatted":"","isValid":false]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cardtype"), object: nil, userInfo: cardDataDict)
        }
        
        if input.count <= placeholderText.count {
            setCombinedText(for: textField)
            setCursorPosition(for: textField)
            let (type, formatted, valid) = checkCardNumber(input: input)
            if(type.rawValue != "Unknown"){
                
                let cardDataDict:[String: Any] = ["type": type.rawValue,"formatted":formatted,"isValid":valid]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cardtype"), object: nil, userInfo: cardDataDict)
            }
            else{
               
                if range.location == 18 {
                    let cardDataDict:[String: Any] = ["type": "Unknown","formatted":formatted,"isValid":valid]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cardtype"), object: nil, userInfo: cardDataDict)
                    return false
                }
            }
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setCursorPosition(for: textField)
    }
    
    func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }

    // MARK: - luhn algo check
    func luhnCheck(number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            guard let digit = Int(tuple.element) else { return false }
            let odd = tuple.offset % 2 == 1
            
            switch (odd, digit) {
            case (true, 9):
                sum += 9
            case (true, 0...8):
                sum += (digit * 2) % 9
            default:
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
    
     // MARK: - validate card and identification
    func checkCardNumber(input: String) -> (type: CardType, formatted: String, valid: Bool) {
        // Get only numbers from the input string
        
        let numberOnly = input.replacingOccurrences(of: "[^0-9]", with: "",options: .regularExpression)
        
        var type: CardType = .Unknown
        var formatted = ""
        var valid = false
        
        // detect card type
        for card in CardType.allCards {
            if (matchesRegex(regex: card.regex, text: numberOnly)) {
                type = card
                break
            }
        }
        
        // check validity
        valid = luhnCheck(number: numberOnly)
        
        // format
        var formatted4 = ""
        for character in numberOnly {
            if formatted4.count == 4 {
                formatted += formatted4 + " "
                formatted4 = ""
            }
            formatted4.append(character)
        }
        
        formatted += formatted4 // the rest
        
        // return the tuple
        return (type, formatted, valid)
    }
}
