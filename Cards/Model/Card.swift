//
//  Card.swift
//  Cards
//
//  Created by Марк Кобяков on 05.05.2022.
//

enum CardType: CaseIterable {
    case circle
    case cross
    case square
    case fill
}

enum CardColor: CaseIterable {
    case red
    case green
    case black
    case gray
    case brown
    case yellow
    case purple
    case orange
}

typealias Card = (type: CardType, color: CardColor)
