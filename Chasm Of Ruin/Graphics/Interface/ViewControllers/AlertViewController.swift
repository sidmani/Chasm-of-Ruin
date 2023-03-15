//
//  AlertViewController.swift
//  Chasm Of Ruin
//
//  Created by Sid Mani on 7/11/16.
//
//

import Foundation
import UIKit

class AlertViewController: UIViewController {
    @IBOutlet weak var noButton: RectButton!
    @IBOutlet weak var yesButton: RectButton!
    @IBOutlet weak var label: UILabel!
    
    var text:String = ""
    var yesText:String = "Yes"
    var noText:String = "No"
    var completion:(Bool) -> () = {_ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.setTitle(noText, for: UIControlState())
        yesButton.setTitle(yesText, for: UIControlState())
        label.text = text
    }
    
    @IBAction func yesButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        self.completion(true)
    }
    
    @IBAction func noButtonPressed() {
        self.dismiss(animated: true, completion: nil)
        self.completion(false)
    }
}
