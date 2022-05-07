//
//  BoardGameController.swift
//  Cards
//
//  Created by Марк Кобяков on 05.05.2022.
//

import UIKit

class BoardGameController: UIViewController {
    var cardsPairsCounts = 9
    var countFlip = 0
    var removeCards = 0 {
        didSet {
            if removeCards == (cardsPairsCounts + 1)*2 {
                self.showAlertController()
            }
        }
    }
    lazy var game: Game = getNewGame()
    lazy var starButtonView = getStartButtomView()
    lazy var boardGameView = getBoardGameView()
    
    private var cardSize: CGSize {
        CGSize(width: 80, height: 120)
    }
    private var cardMaxXCoordinate: Int {
        Int(boardGameView.frame.width - cardSize.width)
    }
    private var cardMaxYCoordinate: Int {
        Int(boardGameView.frame.height - cardSize.height)
    }
    
    var cardViews = [UIView]()
    
    private var flippedCards = [UIView]()
    
    override func loadView() {
        super.loadView()
        view.addSubview(starButtonView)
        view.addSubview(boardGameView)
    }
    
    private func placeCardsOnBoard(_ cards: [UIView]) {
        for card in cardViews {
            card.removeFromSuperview()
        }
        
        cardViews = cards
        for cardView in cardViews {
            let randomXCoordinate = Int.random(in: 0...cardMaxXCoordinate)
            let randomYCoordinate = Int.random(in: 0...cardMaxYCoordinate)
            cardView.frame.origin = CGPoint(x: randomXCoordinate, y: randomYCoordinate)
            
            boardGameView.addSubview(cardView)
        }
    }
    
    private func getBoardGameView() -> UIView {
        let margin: CGFloat = 20
        
        let boardView = UIView()
        boardView.frame.origin.x = margin
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        boardView.frame.origin.y = topPadding + starButtonView.frame.height + margin
        
        boardView.frame.size.width = UIScreen.main.bounds.width - margin*2
        let bottomPadding = window.safeAreaInsets.bottom
        boardView.frame.size.height = UIScreen.main.bounds.height - boardView.frame.origin.y - bottomPadding
        
        boardView.layer.cornerRadius = 20
        boardView.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.85, alpha: 1)
        
        boardView.layer.shadowOpacity = 0.7
        boardView.layer.shadowRadius = 8
        boardView.layer.shadowOffset = .zero
        
        return boardView
    }
    
    private func getCardsBy(modelData: [Card]) -> [UIView] {
        var cardsViews = [UIView]()
        let cardViewFactory = CardViewFactory()
        
        for (index, modelCard) in modelData.enumerated() {
            let cardOne = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardOne.tag = index
            cardsViews.append(cardOne)
            
            let cardTwo = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardTwo.tag = index
            cardsViews.append(cardTwo)
        }
        
        for card in cardsViews {
            (card as! FlippableView).flipCompletionHandler = { [self] flippedCard in
                flippedCard.superview?.bringSubviewToFront(flippedCard)
                
                if flippedCard.isFlipped {
                    self.countFlip += 1
                    self.flippedCards.append(flippedCard)
                } else {
                    if let cardIndex = self.flippedCards.firstIndex(of: flippedCard) {
                        self.flippedCards.remove(at: cardIndex)
                    }
                }
                
                if self.flippedCards.count == 2 {
                    
                    let firstCard = game.cards[self.flippedCards.first!.tag]
                    let secondCard = game.cards[self.flippedCards.last!.tag]
                    
                    if game.checkCards(firstCard, secondCard) {
                        self.removeCards += 2
                        
                        UIView.animate(withDuration: 0.3) {
                            self.flippedCards.first!.layer.opacity = 0
                            self.flippedCards.last!.layer.opacity = 0
                        } completion: { _ in
                            self.flippedCards.first!.removeFromSuperview()
                            self.flippedCards.last!.removeFromSuperview()
                            self.flippedCards = []
                        }
                    } else {
                        for card in self.flippedCards {
                            (card as! FlippableView).flip()
                        }
                    }
                }
            }
        }
        
        return cardsViews
    }
    
    private func getNewGame() -> Game {
        removeCards = 0
        countFlip = 0
        
        let game = Game()
        game.cardsCount = self.cardsPairsCounts
        game.generateCards()
        return game
    }
    
    private func getStartButtomView() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.center.x = view.center.x
        let window = UIApplication.shared.windows[0]
        let topPadding = window.safeAreaInsets.top
        button.frame.origin.y = topPadding + 2.5
        
        button.setTitle("Начать игру", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.black, for: .highlighted)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 10
        
        button.addTarget(nil, action: #selector(startGame(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func showAlertController() {
        let alertController = UIAlertController(title: "Конец", message: "Вы закончили игру, перевернув карт: \(countFlip)", preferredStyle: .alert)
        
        let newGameAction = UIAlertAction(title: "Новая игра", style: .default) { _ in
            self.startGame()
        }
        
        alertController.addAction(newGameAction)
        
        present(alertController, animated: true)
    }
    
    private func startGame() {
        game = getNewGame()
        let cards = getCardsBy(modelData: game.cards)
        placeCardsOnBoard(cards)
    }
    
    @objc func startGame(_ sender: UIButton) {
        game = getNewGame()
        let cards = getCardsBy(modelData: game.cards)
        placeCardsOnBoard(cards)
    }
}
