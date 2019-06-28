//
//  File.swift
//  
//
//  Created by Mats Mollestad on 08/06/2019.
//

import Foundation

public struct Player: Hashable {

    public enum Color: String, CaseIterable {
        case red
        case blue
        case lightBlue
        case green
        case orange
        case purple
        case yellow
        case limeGreen
        case pink
        case black
        case gold
        case brown
    }

    public let name: String
    public var color: Color

    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}


public struct PlayerStats {

    public var leftOverCards: Int
    public var placedCards: Int

    public init() {
        self.leftOverCards = 0
        self.placedCards = 0
    }

    internal init(leftOverCards: Int, placedCards: Int) {
        self.leftOverCards = leftOverCards
        self.placedCards = placedCards
    }

    public var score: Int { placedCards - 2 * leftOverCards }
    public var isLigretto: Bool { leftOverCards == 0 }
}
