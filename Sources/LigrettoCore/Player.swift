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
        case green
        case orange
        case purple
    }

    public let name: String
    public var color: Color

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}


public struct PlayerStats {

    let leftOverCards: Int
    let placedCards: Int

    public var score: Int { placedCards - 2 * leftOverCards }
    public var isLigretto: Bool { leftOverCards == 0 }
}
