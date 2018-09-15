//
//  ViewController.swift
//  Concentration
//
//  Created by Zachery Miller on 9/2/18.
//  Copyright © 2018 Zachery Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var game = Concentration(numberofPairsOfCards: (cardButtons.count + 1) / 2)
    
    @IBOutlet var cardButtons: [UIButton]!
    @IBAction func touchCard(_ sender: UIButton) {
        
        if let cardNumber = cardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        }
        else {
           print("chosen card was not in cardButtons")
        }
    }
    @IBAction func NewGame(_ sender: UIButton) {
        emoji.removeAll()
        GameOver.text = ""
        game = Concentration(numberofPairsOfCards: (cardButtons.count + 1) / 2)
        updateViewFromModel()
    }
    
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var GameOver: UILabel!
    
    func updateViewFromModel() {
        for index in cardButtons.indices {  
            let button = cardButtons[index]
            let card = game.cards[index]
            
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControlState.normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            else {
                button.setTitle("", for: UIControlState.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0) : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
            
            if game.numMatchedPairs == cardButtons.count / 2 {
                GameOver.text = "Game Over!"
            }
        }
        
        ScoreLabel.text = "Score: \(game.score)"
    }
    var emojiChoices = [["🐶","🐱","🐭","🐸","🐰","🦊","🐻","🐼"], ["⚽️","🏀","🏈","⚾️","🎾","🏐","🏒","🎱","🏓"],
                        ["🚛","🚕","🚒","🚌","🏎","🚑","🚓","🚜"],["🍎","🍊","🍋","🍌","🍉","🍇","🍒","🍓"],
                        ["🐝","🐛","🦋","🐜","🦗","🕷","🐞","🦂"], ["🐙","🦑","🦐","🦀","🐬","🐳","🦈","🐠"]]
    var chosenEmojiTheme : [String] = []
    var emoji = Dictionary<Int, String>()
    
    func emoji(for card: Card) -> String {
        if emoji.isEmpty {
            let randomEmojiTheme = Int(arc4random_uniform(UInt32(emojiChoices.count)))
            chosenEmojiTheme = emojiChoices[randomEmojiTheme]
        }
        
        if emoji[card.identifier] == nil, chosenEmojiTheme.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(chosenEmojiTheme.count)))
            emoji[card.identifier] = chosenEmojiTheme.remove(at: randomIndex)
        }
        
        if let chosenEmoji = emoji[card.identifier] {
            return chosenEmoji
        }
        else {
            return "?"
        }

    }

}

