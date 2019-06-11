//
//  File.swift
//  
//
//  Created by Mats Mollestad on 08/06/2019.
//

import Foundation

public protocol GameDelegate: class {
    func didStartNewRound(in game: Game)
    func didFinnish(_ game: Game)
    func didAddPlayer(in game: Game)
}

public class Game {

    public private(set) var players: Set<Player> = []

    public private(set) var completedRounds: [Round] = []

    private var currentRound = Round()

    private var totalScores: [Player : Int] = [:]

    public let scoreGoal: Int

    public weak var delegate: GameDelegate?

    public var lastRound: Round? { completedRounds.last }

    init(scoreGoal: Int = 100) {
        self.scoreGoal = scoreGoal
    }

    public var hasWinnere: Bool {
        totalScores.contains(where: { $0.value >= self.scoreGoal })
    }

    /// Register `PlayerStats` in the current round
    /// - Parameter stats: The stats for the round
    /// - Parameter player: The player to registrate the stats for
    public func registerRound(_ stats: PlayerStats, for player: Player) {
        currentRound.register(stats, for: player)
    }

    /// Saves the current round
    public func saveRound() {
        guard !hasWinnere else { return }

        completedRounds.append(currentRound)
        for player in currentRound.players {
            add(player)
            totalScores[player] = (score(for: player) ?? 0) + (currentRound.score(for: player) ?? 0)
        }
        currentRound = Round()
        if hasWinnere {
            delegate?.didFinnish(self)
        } else {
            delegate?.didStartNewRound(in: self)
        }
    }

    /// Adds a player to the game
    /// - Parameter player: The player to add
    public func add(_ player: Player) {
        guard !players.contains(player) else { return }
        players.insert(player)
        delegate?.didAddPlayer(in: self)
    }

    public func score(for player: Player) -> Int? {
        totalScores[player]
    }
}
