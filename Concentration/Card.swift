//
//  Card.swift
//  Concentration
//
//  Created by Zachery Miller on 9/5/18.
//  Copyright © 2018 Zachery Miller. All rights reserved.
//

import Foundation

struct Card {
    var isFaceUp = false
    var isMatched = false
    var hasBeenSeen = false
    var identifier : Int
    
    static var identifierFactory = 0
    
    static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    init() {
        self.identifier = Card.getUniqueIdentifier()
    }
}
