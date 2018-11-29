//
//  Concentration.swift
//  Concentration
//
//  Created by Zachery Miller on 9/5/18.
//  Copyright © 2018 Zachery Miller. All rights reserved.
//

import Foundation

class Concentration {
    
    var cards = [Card]()
    var faceUpCardIndexes = [Int]()
    var score = 0
    var numMatchedPairs = 0
    var gameOver = false
    
    static let MAXNUMBEROFMATCHES = 8
    let FIRSTFACEUPCARD = 0
    let SECONDFACEUPCARD = 1
    
    func removeFaceUpCards() {
        faceUpCardIndexes.removeAll()
    }
    
    init(numberofPairsOfCards : Int) {
        for _ in 0..<numberofPairsOfCards {
            let card = Card()
            cards.append(card)
            cards.append(card)
        }
        
        shuffle()
    }
        
    func shuffle() {
        for index in 0..<cards.count {
            let rand = Int(arc4random_uniform(UInt32(cards.count)))
            let card = cards[index]
            cards[index] = cards[rand]
            cards[rand] = card
            
        }
    }
}
