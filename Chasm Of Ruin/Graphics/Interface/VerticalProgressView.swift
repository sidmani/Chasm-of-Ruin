//
//  VerticalProgressView.swift
//  VerticalProgressView
//
//  Created by mlaskowski on 11/08/15.
//  Copyright (c) 2015 mlaskowski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class VerticalProgressView : UIView {
    
    public var fillDoneColor : UIColor = UIColor.green
    @IBInspectable public var vertical = true

    var progress: CGFloat = 0
    
    let label = UILabel()
    let modifierLabel = UILabel()
    private let animationDuration: Double = 0.5
    public let filledView = CALayer()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.filledView.backgroundColor = self.fillDoneColor.cgColor
        self.filledView.frame = self.bounds

        self.layer.addSublayer(filledView)
        modifierLabel.textColor = ColorScheme.strokeColor

        if (self.vertical) {
            label.bounds = CGRect(x: 0, y: self.bounds.height - 30, width: self.bounds.width - 10, height: 30)
            label.center = CGPoint(x: self.bounds.width/2 - 2.5, y: self.bounds.height - 15)
            label.textAlignment = .right
            label.textColor = ColorScheme.strokeColor

            modifierLabel.bounds = CGRect(x: 10, y: 30, width: self.bounds.width, height: 30)
            modifierLabel.center = CGPoint(x: self.bounds.width/2 + 2.5, y: 15)
            modifierLabel.textAlignment = .left
        }
        else {
            label.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
            label.textAlignment = .center
            label.textColor = UIColor.black //TODO: check this
            label.alpha = 0.4
            label.bounds = CGRect(x: 0, y: label.center.y-15, width: self.bounds.width, height: 30)
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(enableHPLabel)))
            label.isUserInteractionEnabled = true
        }
        
        self.addSubview(modifierLabel)
        self.addSubview(label)
        self.layer.borderColor = ColorScheme.strokeColor.cgColor
        self.layer.borderWidth = 2.0
        self.backgroundColor = ColorScheme.fillColor
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
    }
    
    @objc func enableHPLabel() {
        label.isHidden = !label.isHidden
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        if (vertical) {
            let filledHeight = rect.size.height * progress
            let y = self.frame.size.height - filledHeight
            self.filledView.frame = CGRect(x: 0, y: y, width: rect.size.width, height: rect.size.height)

        }
        else {
            let filledWidth = rect.size.width * progress
            let x = filledWidth - self.frame.size.width
            self.filledView.frame = CGRect(x: x, y: 0, width: rect.size.width, height: rect.size.height)
        }
        
    }
    
    private func shouldHavePosition() -> CGFloat {
        if (vertical) {
            return self.frame.size.height - self.frame.size.height * progress
        }
        else {
            return self.frame.size.width * progress - self.frame.size.width
        }
    }
    
    private func setFilledPosition(_ position: CGFloat, animated: Bool) {
        //animated
        let duration: TimeInterval = animated ? self.animationDuration : 0;
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)

        if (vertical) {
            self.filledView.frame.origin.y = position
        }
        else {
            self.filledView.frame.origin.x = position
        }
        
        CATransaction.commit()
    }
    
    private func setFilledPosition(_ color:UIColor, position: CGFloat, animated: Bool) {
        //animated
        let duration: TimeInterval = animated ? self.animationDuration : 0;
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        
        if (self.vertical) {
            self.filledView.frame.origin.y = position
        }
        else {
            self.filledView.frame.origin.x = position
        }
        self.filledView.backgroundColor = color.cgColor
        
        CATransaction.commit()
        
    }
    
    public func setProgress(_ progress: CGFloat, animated: Bool){
        //bounds check
        self.progress = max(0, min(progress, 1))
        setFilledPosition(self.shouldHavePosition(), animated: animated)
    }
    
    public func setProgress(_ color:UIColor, progress: CGFloat, animated: Bool){
        //bounds check
        self.progress = max(0, min(progress, 1))
        setFilledPosition(color, position: self.shouldHavePosition(), animated: animated)
    }
    
    public func setColor(_ color:UIColor) {
        setFilledPosition(color, position: self.shouldHavePosition(), animated: true)
    }

    
}
