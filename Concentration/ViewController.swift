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
        updateViewFromModel()
    }
    
    @IBAction func chooseCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: cardsInPlayView)
            
            if let tappedView = cardsInPlayView.hitTest(location, with: nil) as? CardView {
                if let cardIndex = cardsInPlayView.subviews.index(of: tappedView) {
                    
                    self.game.chooseCard(at: cardIndex)

                    UIView.transition(with: tappedView,
                                      duration: 0.5,
                                      options: [.transitionFlipFromLeft],
                                      animations: {
                                        tappedView.setNeedsDisplay()
                                        },
                                      completion: {finished in
                                        self.updateViewFromModel()
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
    
    private func updateViewFromModel() {
        
        if game.gameOver {
            GameOver.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ScoreLabel.text = "Final Score: \(game.score)"

        }
        else {
            ScoreLabel.text = "Score: \(game.score)"
        }
    }
    
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
                                        emojiForCard : emoji(for: card), card : card)
                
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

}

extension ViewController {
    private struct CardSize {
        static let aspectRatio: CGFloat = 0.7
        static let borderWidth: CGFloat = 2.0
        static let inset: CGFloat = 4.0
    }
}
