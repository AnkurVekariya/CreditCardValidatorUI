//
//  ViewController.swift
//  CreditcardUI
//
//  Created by Ankur on 2/20/19.
//  Copyright © 2019 ankur. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var cardText: UITextField!
    
    //set placeholder for card text with delegate
    let placeholderHandler = CustomPlaceholderTextFieldHandler(placeholder: "XXXX XXXX XXXX XXXX")


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lblError.text = ""
        // Register to receive notification for card type
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayCardUI(_:)), name: NSNotification.Name(rawValue: "cardtype"), object: nil)
        
        cardText.delegate = placeholderHandler
        placeholderHandler.resetPlaceholder(for: cardText)
    }
    
    // handle notification
    @objc func displayCardUI(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let type = dict["type"] as? String{
                lblError.text = ""
                if type == "Visa"{
                  imgCard.image =  UIImage(named:"VisaCardLogo")!
                }
                else if type == "MasterCard"{
                    imgCard.image =  UIImage(named:"MasterCardLogo")!
                }
                else if type == "Discover"{
                    imgCard.image =  UIImage(named:"DiscoverCardLogo")!
                }
                else if type == "Amex"{
                    imgCard.image =  UIImage(named:"AmericanCardLogo")!
                }
                else if type == "Diners"{
                    imgCard.image =  UIImage(named:"DinerCardLogo")!
                }
                else if type == "Reset"{
                    lblError.text = ""
                    imgCard.image = UIImage(named:"Placeholder")!
                }
                else{
                    lblError.text = "\(type) Card"
                }
            }
        }
    }

}

