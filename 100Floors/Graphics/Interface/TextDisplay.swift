//
//  TextDisplay.swift
//  100Floors
//
//  Created by Sid Mani on 6/19/16.
//
//

import Foundation
import UIKit

class TextDisplay:UIView {
    private let rectangleLayer = CAShapeLayer()
    private let textView = UILabel()
    private var printLetterTimer:NSTimer?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        rectangleLayer.fillColor = ColorScheme.fillColor.CGColor
        rectangleLayer.strokeColor = ColorScheme.strokeColor.CGColor
        rectangleLayer.lineWidth = 2
        let rectangleView = UIView()
        rectangleView.layer.addSublayer(rectangleLayer)
        
        textView.textAlignment = .Center
        textView.textColor = UIColor.whiteColor()
        self.addSubview(rectangleView)
        self.addSubview(textView)
        
        textView.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rectangleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), cornerRadius: 12).CGPath
        textView.bounds = self.bounds
        textView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
    }
    
    private var letterIndex = 0
    private var chars:[String] = []
    
    func setText(to:String, letterDelay:Double, hideAfter:Double) {
        hideSelfTimer?.invalidate()
        printLetterTimer?.invalidate()
        self.hidden = false
        textView.text = ""
        letterIndex = 0
        self.chars = to.characters.map {String($0)}
        printLetterTimer = NSTimer.scheduledTimerWithTimeInterval(letterDelay, target: self, selector: #selector(printLetter), userInfo: nil, repeats: true)
        hideSelfTimer = NSTimer.scheduledTimerWithTimeInterval(hideAfter + Double(chars.count) * letterDelay, target: self, selector: #selector(hideSelf), userInfo: nil, repeats: false)
    }
    
    @objc func hideSelf() {
        self.hidden = true
    }
    
    private var hideSelfTimer:NSTimer?
    
    @objc func printLetter() {
        if (letterIndex >= chars.count) {
            printLetterTimer?.invalidate()
            printLetterTimer = nil
            letterIndex = 0
            chars = []
        }
        else {
            textView.text = textView.text! + chars[letterIndex]
            letterIndex += 1
        }
    }
}