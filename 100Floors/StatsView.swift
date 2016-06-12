//
//  StatsView.swift
//  100Floors
//
//  Created by Sid Mani on 4/16/16.
//
//

import Foundation
import UIKit

/*class StatsView: UIView {
    private var stats:Stats!
    private var bars = [UIProgressView](count: Stats.numStats, repeatedValue:UIProgressView(progressViewStyle: .Default))
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for i in 0..<bars.count {
            bars[i].center = CGPointMake(self.bounds.width/2, self.bounds.height*(1-CGFloat(i) / CGFloat(bars.count)))
            self.addSubview(bars[i])
            print(self.bounds.height*(1-CGFloat(i) / CGFloat(bars.count)))
        }
   //     let testview = UIView(frame: self.frame)
   //     testview.backgroundColor = UIColor.redColor()
   //     testview.center = CGPointZero
   //     addSubview(testview)
   //     print("subview added")
       // self.backgroundColor = UIColor.redColor()
    }
    func setStats(to:Stats) {
        stats = to
        for i in 0..<bars.count {
            bars[i].setProgress(Float(stats.getIndex(i)/100), animated: true)
        }
    }
}*/