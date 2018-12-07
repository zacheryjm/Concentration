//
//  CardView.swift
//  Concentration
//
//  Created by Zachery Miller on 11/12/18.
//  Copyright © 2018 Zachery Miller. All rights reserved.
//

import UIKit

class CardView: UIView {

    var isFaceUp = false
    var isMatched = false
    private var emoji : String
    var fontSize : CGFloat = 50.0

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        drawBackground()
        if self.isFaceUp && !self.isMatched {
            drawEmoji()
        }
    }

    
    
    init(frame: CGRect, emojiForCard : String) {
        self.emoji = emojiForCard
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawEmoji() {
        
        let label = UILabel()
        label.text = emoji
        label.font = label.font.withSize(fontSize)
        label.textAlignment = .center
        label.center = CGPoint(x:self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        label.drawText(in: bounds)

    }
    
    private func drawBackground() {
        
        guard let graphicsContext = UIGraphicsGetCurrentContext() else {
            print("unable to get graphics context in drawBackground()")
            return
        }
        
        UIColor.black.setFill()
        graphicsContext.fill(bounds)
        
        // draw rectangle with rounded corners
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        if self.isFaceUp {
            UIColor.white.setFill()
        }
        else if self.isMatched {
            UIColor.black.setFill()
        }
        else {
            UIColor.blue.setFill()
        }
        roundedRect.fill()
        
    }
    
}


// extension for card size calculations
extension CardView {
    private struct SizeRatio {
        static let gridInset: CGFloat = 10
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
}
