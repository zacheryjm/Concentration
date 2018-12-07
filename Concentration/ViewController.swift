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
        super.viewDidLoad()
        setUpEmojiTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initialLoadComplete {
            initializeCardViewGrid()
            initialLoadComplete = true
        }
        updateViewFromModel()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var isLandscapeOrientation = false
        
        if UIDevice.current.orientation.isLandscape {
            isLandscapeOrientation = true
        } else if UIDevice.current.orientation.isPortrait {
            isLandscapeOrientation = false
        }
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            
            self.updateCardViewGrid(for: isLandscapeOrientation)
            self.view.setNeedsLayout()
            self.view.setNeedsDisplay()
        })
    }
    
    private var initialLoadComplete = false

    @IBOutlet weak var cardsInPlayView: UIView!
    
    private lazy var game = Concentration(numberofPairsOfCards: Concentration.MAXNUMBEROFMATCHES)
    private lazy var grid = Grid(layout: .aspectRatio(CardSize.aspectRatio),frame: cardsInPlayView.bounds)


    @IBAction func NewGame(_ sender: UIButton) {
        emoji.removeAll()
        GameOver.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        game = Concentration(numberofPairsOfCards: Concentration.MAXNUMBEROFMATCHES)
        setUpEmojiTheme()
        initializeCardViewGrid()
        updateViewFromModel()
    }
    
    @IBAction func chooseCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            
            //Don't allow user to click more than two cards at once
            if game.faceUpCardIndexes.count == 2 {
                return
            }
            let location = sender.location(in: cardsInPlayView)
            
            if let tappedView = cardsInPlayView.hitTest(location, with: nil) as? CardView {

                if let cardIndex = cardsInPlayView.subviews.index(of: tappedView) {
                    
                    game.cards[cardIndex].isFaceUp = !game.cards[cardIndex].isFaceUp
                    
                    //If the card is already faceup, update model to make it facedown.
                    if self.game.faceUpCardIndexes.contains(cardIndex) {
                        self.game.faceUpCardIndexes.removeLast()
                        self.game.cards[cardIndex].hasBeenSeen = true
                    }
                    else {
                        self.game.faceUpCardIndexes.append(cardIndex)
                    }
                        
                    UIView.transition(with: tappedView,
                                      duration: 0.5,
                                      options: [.transitionFlipFromLeft],
                                      animations: {
                                        tappedView.isFaceUp = self.game.cards[cardIndex].isFaceUp
                                        tappedView.setNeedsDisplay()},
                                      completion: { finished in
                                        
                                        //Check for a match if there are two cards faceup
                                        if self.game.faceUpCardIndexes.count == 2 {
                                            
                                            let firstCardIndex = self.game.faceUpCardIndexes[self.game.FIRSTFACEUPCARD]
                                            let secondCardIndex = self.game.faceUpCardIndexes[self.game.SECONDFACEUPCARD]
                                            
                                            if self.checkForMatch() {
                                                self.animateMatchedCard(forCardIndex: firstCardIndex)
                                                self.animateMatchedCard(forCardIndex: secondCardIndex)
                                            }
                                            else {
                                                self.animateNotMatchedCard(forCardIndex: firstCardIndex)
                                                self.animateNotMatchedCard(forCardIndex: secondCardIndex)
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
    
    //MARK: Animations for card flip
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
    
    //MARK: View modification
    private func updateViewFromModel() {
        
        if game.gameOver {
            GameOver.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            ScoreLabel.text = "Final Score: \(game.score)"

        }
        else {
            ScoreLabel.text = "Score: \(game.score)"
        }
    }
    
    private func initializeCardViewGrid() {
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
    
    private func updateCardViewGrid(for landscapeOrientation : Bool) {
        if landscapeOrientation {
            let ROWCOUNT = 4
            let COLUMNCOUNT = 4
            grid = Grid(layout: .dimensions(rowCount: ROWCOUNT, columnCount: COLUMNCOUNT), frame: cardsInPlayView.bounds)
        }
        else {
            grid = Grid(layout: .aspectRatio(CardSize.aspectRatio),frame: cardsInPlayView.bounds)

        }
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
                
                if landscapeOrientation {
                    cardView.fontSize = 35.0
                }
                else {
                    cardView.fontSize = 50.0

                }
                
                if card.isMatched {
                    cardView.isMatched = true
                    cardView.isHidden = true
                }
                if card.isFaceUp {
                    cardView.isFaceUp = true
                }
                cardsInPlayView.addSubview(cardView)
            } else {
                print("grid[\(index)] does not exist")
            }
        }
        
        
    }
    
    //MARK: Emoji functions for Card Face
    var chosenEmojiTheme : [String] = Emoji.emojiThemes[0]
    var emoji = Dictionary<Int, Int>()
    
    func setUpEmojiTheme() {
        var emojiPosition = [Int]()
        game = Concentration(numberofPairsOfCards: Concentration.MAXNUMBEROFMATCHES)
        
        for index in chosenEmojiTheme.indices {
            emojiPosition.append(index)
        }
        
        for card in game.cards {
            if emoji[card.identifier] == nil, emojiPosition.count > 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(emojiPosition.count)))
                emoji[card.identifier] = emojiPosition.remove(at: randomIndex)
            }
        }
    }
    
    func emoji(for card: Card) -> String {
        if let index = emoji[card.identifier] {
            let chosenEmoji = chosenEmojiTheme[index]
            return chosenEmoji
        }
        else {
            return "?"
        }
        
    }
    
    //MARK: checkForMatch

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

//MARK: Extensions

extension ViewController {
    private struct CardSize {
        static let aspectRatio: CGFloat = 0.7
        static let borderWidth: CGFloat = 2.0
        static let inset: CGFloat = 4.0
    }
}

extension ViewController {
    struct Emoji {
        static let emojiThemes = [["🐶","🐱","🐭","🐸","🐰","🦊","🐻","🐼"], ["⚽️","🏀","🏈","⚾️","🎾","🏐","🏒","🎱","🏓"],
                            ["🚛","🚕","🚒","🚌","🏎","🚑","🚓","🚜"],["🍎","🍊","🍋","🍌","🍉","🍇","🍒","🍓"],
                            ["🐝","🐛","🦋","🐜","🦗","🕷","🐞","🦂"], ["🐙","🦑","🦐","🦀","🐬","🐳","🦈","🐠"]]
        static let emojiThemeNames = ["Animals", "Sports", "Vehicles", "Fruits", "Bugs", "Sea Creatures"]
        
    }
}
