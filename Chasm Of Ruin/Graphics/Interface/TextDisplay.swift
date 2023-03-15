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
    private var printLetterTimer:Timer?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        rectangleLayer.fillColor = ColorScheme.fillColor.cgColor
        rectangleLayer.strokeColor = ColorScheme.strokeColor.cgColor
        rectangleLayer.lineWidth = 2
        let rectangleView = UIView()
        rectangleView.layer.addSublayer(rectangleLayer)
        
        textView.textAlignment = .center
        textView.textColor = UIColor.white
        self.addSubview(rectangleView)
        self.addSubview(textView)
        
        textView.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rectangleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), cornerRadius: 12).cgPath
        textView.bounds = self.bounds
        textView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
    
    private var letterIndex = 0
    private var chars:[String] = []
    
    func setText(_ to:String, letterDelay:Double, hideAfter:Double) {
        hideSelfTimer?.invalidate()
        printLetterTimer?.invalidate()
        self.isHidden = false
        textView.text = ""
        letterIndex = 0
        self.chars = to.characters.map {String($0)}
        printLetterTimer = Timer.scheduledTimer(timeInterval: letterDelay, target: self, selector: #selector(printLetter), userInfo: nil, repeats: true)
        hideSelfTimer = Timer.scheduledTimer(timeInterval: hideAfter + Double(chars.count) * letterDelay, target: self, selector: #selector(hideSelf), userInfo: nil, repeats: false)
    }
    
    @objc func hideSelf() {
        self.isHidden = true
    }
    
    private var hideSelfTimer:Timer?
    
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

