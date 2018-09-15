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
    var oneCardFaceUpIndex = -1
    var twoCardFaceUpIndex = -1
    var score = 0
    var numMatchedPairs = 0
    
    func chooseCard(at index: Int) {
        
        if cards[index].isMatched {
            return
        }
        
        if twoCardFaceUpIndex != -1 {
            cards[oneCardFaceUpIndex].isFaceUp = false
            cards[twoCardFaceUpIndex].isFaceUp = false
            oneCardFaceUpIndex = -1
            twoCardFaceUpIndex = -1
        }
        
        if oneCardFaceUpIndex == -1 {
            oneCardFaceUpIndex = index
            cards[index].isFaceUp = true
        }
        else {
            twoCardFaceUpIndex = index
            cards[index].isFaceUp = true
            if cards[oneCardFaceUpIndex].identifier == cards[index].identifier {
                
                cards[oneCardFaceUpIndex].isMatched = true
                cards[index].isMatched = true
                score += 2
                numMatchedPairs += 1
            }
            else {
                if cards[oneCardFaceUpIndex].hasBeenSeen {
                    score -= 1
                }
                if cards[index].hasBeenSeen {
                    score -= 1
                }
                
                cards[oneCardFaceUpIndex].hasBeenSeen = true
                cards[twoCardFaceUpIndex].hasBeenSeen = true
            }
        }
        
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
