//
//  ViewController.swift
//  Concentration
//
//  Created by Zachery Miller on 9/2/18.
//  Copyright © 2018 Zachery Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        addCardViewsToGrid()
        updateViewFromModel()
    }
    private lazy var game = Concentration(numberofPairsOfCards: Concentration.MAXNUMBEROFMATCHES)
    private lazy var grid = Grid(layout: .aspectRatio(CardSize.aspectRatio),frame: cardsInPlayView.bounds)

    @IBOutlet weak var cardsInPlayView: UIView!

    @IBAction func NewGame(_ sender: UIButton) {
        emoji.removeAll()
        GameOver.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        game = Concentration(numberofPairsOfCards: Concentration.MAXNUMBEROFMATCHES)
        addCardViewsToGrid()
        updateViewFromModel()
    }
    
    @IBAction func chooseCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: cardsInPlayView)
            
            if let tappedView = cardsInPlayView.hitTest(location, with: nil) as? CardView {

                if let cardIndex = cardsInPlayView.subviews.index(of: tappedView) {
                    game.cards[cardIndex].isFaceUp = !game.cards[cardIndex].isFaceUp
                        
                    UIView.transition(with: tappedView,
                                      duration: 0.5,
                                      options: [.transitionFlipFromLeft],
                                      animations: {
                                        tappedView.isFaceUp = self.game.cards[cardIndex].isFaceUp
                                        tappedView.setNeedsDisplay()},
                                      completion: { finished in
                                        
                                        if self.game.faceUpCardIndexes.contains(cardIndex) {
                                            self.game.faceUpCardIndexes.removeLast()
                                        }
                                        else {
                                            self.game.faceUpCardIndexes.append(cardIndex)
                                        }
                        
                                        if self.game.faceUpCardIndexes.count == 2 {
                                            
                                            if self.checkForMatch() {
                                                self.animateMatchedCard(forCardIndex: self.game.faceUpCardIndexes[self.game.FIRSTFACEUPCARD])
                                                self.animateMatchedCard(forCardIndex: self.game.faceUpCardIndexes[self.game.SECONDFACEUPCARD])
                                                
                                            }
                                            else {
                                                self.animateNotMatchedCard(forCardIndex: self.game.faceUpCardIndexes[self.game.FIRSTFACEUPCARD])
                                                self.animateNotMatchedCard(forCardIndex: self.game.faceUpCardIndexes[self.game.SECONDFACEUPCARD])
                                            }
                                            self.game.removeFaceUpCards()
                                            self.updateViewFromModel()
                                        }
                    })
                }
            }
        }
    }
    
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var GameOver: UILabel!
    
    private var faceUpCardViews : [CardView] {
        let cardViews = cardsInPlayView.subviews as! [CardView]

        return cardViews.filter {$0.isFaceUp}
        
    }
    
    private func animateMatchedCard(forCardIndex : Int) {
        if let cardView = cardsInPlayView.subviews[forCardIndex] as? CardView {
            UIView.transition(with: cardView,
                              duration: 0.5,
                              options: [.transitionFlipFromTop],
                              animations: {
                                cardView.isFaceUp = self.game.cards[forCardIndex].isFaceUp
                                cardView.isMatched = self.game.cards[forCardIndex].isMatched
                                cardView.setNeedsDisplay()},
                              completion: {finished in
                                cardView.isHidden = true
            })

        }
    }
    
    private func animateNotMatchedCard(forCardIndex : Int) {
    
        if let cardView = cardsInPlayView.subviews[forCardIndex] as? CardView {
            UIView.transition(with: cardView,
                              duration: 0.5,
                              options: [.transitionFlipFromLeft],
                              animations: {
                                cardView.isFaceUp = self.game.cards[forCardIndex].isFaceUp
                                cardView.isMatched = self.game.cards[forCardIndex].isMatched
                                cardView.setNeedsDisplay()})
        }
    }
    
    private func updateViewFromModel() {
        
        if game.gameOver {
            GameOver.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ScoreLabel.text = "Final Score: \(game.score)"

        }
        else {
            ScoreLabel.text = "Score: \(game.score)"
        }
    }
    
    //TODO: Update function to fix bug that makes the grid not fill entire view
    private func addCardViewsToGrid() {
        grid.frame = cardsInPlayView.bounds
        grid.cellCount = game.cards.count
        
        for cardView in cardsInPlayView.subviews {
            cardView.removeFromSuperview()
        }
        
        for index in 0..<grid.cellCount {
            if let cellFrame = grid[index] {
                let card = game.cards[index]
                let cardView = CardView(frame: cellFrame.insetBy(dx: CardSize.inset, dy: CardSize.inset),
                                        emojiForCard : emoji(for: card))
                
                cardsInPlayView.addSubview(cardView)
            } else {
                print("grid[\(index)] does not exist")
            }
        }
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
    
    func checkForMatch() -> Bool {
        
        var isMatch = false
        
        let firstCardIndex = game.faceUpCardIndexes[game.FIRSTFACEUPCARD]
        let secondCardIndex = game.faceUpCardIndexes[game.SECONDFACEUPCARD]
        
        //Compare two face up cards to see if it is a match. If true, give points.
        if game.cards[firstCardIndex].identifier == game.cards[secondCardIndex].identifier && firstCardIndex != secondCardIndex {
            
            game.cards[firstCardIndex].isMatched = true
            game.cards[secondCardIndex].isMatched = true
            
            game.score += 2
            game.numMatchedPairs += 1
            if game.numMatchedPairs == Concentration.MAXNUMBEROFMATCHES {
                game.gameOver = true
            }
            
            isMatch = true
            
        }
            //chosen cards were not a match. Determine if penalty is necessary.
        else {
            if game.cards[firstCardIndex].hasBeenSeen {
                game.score -= 1
            }
            if game.cards[secondCardIndex].hasBeenSeen {
                game.score -= 1
            }
            
            game.cards[firstCardIndex].hasBeenSeen = true
            game.cards[secondCardIndex].hasBeenSeen = true
        }
        
        game.cards[firstCardIndex].isFaceUp = false
        game.cards[secondCardIndex].isFaceUp = false
        
        return isMatch
    }

}

extension ViewController {
    private struct CardSize {
        static let aspectRatio: CGFloat = 0.7
        static let borderWidth: CGFloat = 2.0
        static let inset: CGFloat = 4.0
    }
}
