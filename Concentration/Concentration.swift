//
//  Concentration.swift
//  Concentration
//
//  Created by Zachery Miller on 9/5/18.
//  Copyright © 2018 Zachery Miller. All rights reserved.
//

import Foundation

class Concentration {
    
    private var cards = [Card]()
    private var score = 0
    private var numMatchedPairs = 0
    
    func chooseCard(at index: Int) {
        
        var numFaceUpCards = 0
        var oneCardFaceUpIndex = -1
        
        for cardIndex in cards.indices{
            if cards[cardIndex].isFaceUp {
                numFaceUpCards += 1
                if numFaceUpCards <= 1 {
                    oneCardFaceUpIndex = cardIndex
                }
                else {
                    cards[cardIndex].isFaceUp = false
                    cards[oneCardFaceUpIndex].isFaceUp = false
                    oneCardFaceUpIndex = -1
                }
                
            }
        }
        
        //Do nothing if the user chooses a matched card or the same card twice
        if cards[index].isMatched || index == oneCardFaceUpIndex {
            return
        }
        
        //No cards are face up. Flip this card as users first choice
        if oneCardFaceUpIndex == -1 {
            cards[index].isFaceUp = true
            return
        }
        //Compare two face up cards to see if it is a match. If true, give points.
        if cards[index].identifier == cards[oneCardFaceUpIndex].identifier {
            cards[index].isMatched = true
            cards[oneCardFaceUpIndex].isMatched = true
            score += 2
            numMatchedPairs += 1
        }
        //chosen cards were not a match. Determine if penalty is necessary.
        else {
            if cards[oneCardFaceUpIndex].hasBeenSeen {
                score -= 1
            }
            if cards[index].hasBeenSeen {
                score -= 1
            }
            
            cards[oneCardFaceUpIndex].hasBeenSeen = true
            cards[index].hasBeenSeen = true
        }
        
        cards[index].isFaceUp = true
        
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
