//
//  File.swift
//  
//
//  Created by Mats Mollestad on 08/06/2019.
//

import Foundation

public class Round: Codable {

    internal var scores: [Player : PlayerStats] = [:]

    public var players: [Player] { return scores.keys.map { $0 } }

    public var containsValidStats: Bool { scores.contains(where: { $0.value.placedCards > 0 }) }

    public var highestScore: (Player, PlayerStats)? {
        scores.max(by: { $0.value.score < $1.value.score })
    }

    public func score(for player: Player) -> Int? {
        scores[player]?.score
    }

    public func stats(for player: Player) -> PlayerStats? {
        scores[player]
    }

    public func hasPlayerReached(goal scoreGoal: Int) -> Bool {
        scores.contains(where: { $0.value.score >= scoreGoal })
    }

    public func playerWithLigretto() -> Player? {
        scores.first(where: { $0.value.isLigretto })?.key
    }

    public func register(_ stats: PlayerStats, for player: Player) {
        scores[player] = stats
    }

    public func change(_ oldPlayer: Player, to newPlayer: Player) {
        guard scores[newPlayer] == nil else { return }
        scores[newPlayer] = scores[oldPlayer]
        scores[oldPlayer] = nil
    }

    public func hasLigretto(_ player: Player) -> Bool {
        scores[player]?.isLigretto == true
    }
}
