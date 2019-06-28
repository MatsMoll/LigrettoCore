//
//  File.swift
//  
//
//  Created by Mats Mollestad on 08/06/2019.
//

import Foundation

public enum GameResult {
    case winner(Player)
    case drawn([Player])
}

public protocol GameDelegate: class {
    func didStartNewRound(in game: Game)
    func didFinnish(_ game: Game, with result: GameResult)
    func didAddPlayer(in game: Game)
    func didChange(_ player: Player, to newPlayer: Player, in game: Game)
    func didRemovePlayer(in game: Game)
    func didReset(_ game: Game)
}

public extension GameDelegate {
    func didStartNewRound(in game: Game) {}
    func didFinnish(_ game: Game, with result: GameResult) {}
    func didAddPlayer(in game: Game) {}
    func didChange(_ player: Player, to newPlayer: Player, in game: Game) {}
    func didRemovePlayer(in game: Game) {}
    func didReset(_ game: Game) {}
}

public class Game {

    public private(set) var players: Set<Player> = []

    public var sortedPlayers: Array<Player> {
        totalScores
            .sorted(by: { $0.value > $1.value })
            .map { $0.key }
    }

    public private(set) var completedRounds: [Round] = []

    private var currentRound = Round()

    private var totalScores: [Player : Int] = [:]

    public private(set) var lastStandingTrend: [Player : StandingTrend] = [:]

    public var scoreGoal: Int = 100

    public weak var delegate: GameDelegate?

    public var lastRound: Round? {
        completedRounds.last
    }

    public var highestRound: Round? {
        completedRounds.max { ($0.highestScore?.1.score ?? 0) < ($1.highestScore?.1.score ?? 0) }
    }

    public var hasWinnere: Bool {
        totalScores.contains(where: { $0.value >= self.scoreGoal })
    }

    public init() {}

    /// Register `PlayerStats` in the current round
    /// - Parameter stats: The stats for the round
    /// - Parameter player: The player to registrate the stats for
    public func registerRound(_ stats: PlayerStats, for player: Player) {
        currentRound.register(stats, for: player)
    }

    /// Saves the current round
    public func saveRound() {
        guard !hasWinnere else { return notifyOfNewRound() }
        guard currentRound.containsValidStats else { return }

        completedRounds.append(currentRound)
        for player in currentRound.players {
            add(player)
            totalScores[player] = (score(for: player) ?? 0) + (currentRound.score(for: player) ?? 0)
        }
        currentRound = Round()
        lastStandingTrend = standingChange(in: completedRounds.count - 1)
        
        notifyOfNewRound()
    }

    private func notifyOfNewRound() {
        if hasWinnere {
            let potensialWinners = totalScores
                .filter { $0.value >= self.scoreGoal }
                .sorted(by: { $0.value > $1.value })
            let winnerScore = potensialWinners.first?.value ?? 0
            let winners = potensialWinners
                .filter { $0.value == winnerScore }
                .map { $0.key }

            if winners.count > 1 {
                delegate?.didFinnish(self, with: .drawn(winners))
            } else {
                delegate?.didFinnish(self, with: .winner(winners[0]))
            }
        } else {
            delegate?.didStartNewRound(in: self)
        }
    }

    /// Adds a player to the game
    /// - Parameter player: The player to add
    public func add(_ player: Player) {
        guard !players.contains(player) else { return }
        players.insert(player)
        totalScores[player] = 0
        delegate?.didAddPlayer(in: self)
    }

    public func change(_ oldPlayer: Player, to newPlayer: Player) {
        guard !players.contains(newPlayer) else { return }
        players.insert(newPlayer)
        players.remove(oldPlayer)
        totalScores[newPlayer] = totalScores[oldPlayer]
        totalScores[oldPlayer] = nil
        completedRounds.forEach { $0.change(oldPlayer, to: newPlayer) }
        delegate?.didChange(oldPlayer, to: newPlayer, in: self)
    }

    public func remove(_ player: Player) {
        players.remove(player)
        totalScores[player] = nil
        delegate?.didRemovePlayer(in: self)
    }

    public func score(for player: Player) -> Int? {
        totalScores[player]
    }

    public func reset() {
        totalScores = [:]
        delegate?.didReset(self)
    }

    public func newGame() -> Game {
        let new = Game()
        players.forEach { new.add($0) }
        new.scoreGoal = scoreGoal
        return new
    }

    public func currentStats(for player: Player) -> PlayerStats? {
        currentRound.stats(for: player)
    }

    public func standing(for player: Player) -> Int? {
        standings(from: totalScores)[player]
    }

    public func standingChange(in round: Int) -> [Player : StandingTrend] {

        var roundScores: [Player : Int] = [:]

        if round >= 1 {
            for i in 0..<round {
                for player in completedRounds[i].players {
                    roundScores[player] = (roundScores[player] ?? 0) + (completedRounds[i].score(for: player) ?? 0)
                }
            }
        }

        let startingStandings = standings(from: roundScores)
        for player in completedRounds[round].players {
            roundScores[player] = (roundScores[player] ?? 0) + (completedRounds[round].score(for: player) ?? 0)
        }
        let endStandings = standings(from: roundScores)

        return endStandings.mapDictionary { player, currentStanding in
            guard let startStanding = startingStandings[player] else {
                if currentStanding == endStandings.count {
                    return .same
                } else {
                    return .up(endStandings.count - currentStanding)
                }
            }
            let change = currentStanding - startStanding
            if change == 0 {
                return .same
            } else if change < 0 {
                return .up(abs(change))
            } else {
                return .down(change)
            }
        }
    }

    private func standings(from scores: [Player : Int]) -> [Player : Int] {
        let sortedScores = scores
            .map { $0.value }
            .sorted(by: { $0 > $1 })

        let standings: [Int : Int] = sortedScores.reduce([:]) {
            $0.merging([$1 : (sortedScores.firstIndex(of: $1) ?? 0) + 1], uniquingKeysWith: { $1 })
        }
        return scores.mapValues { standings[$0] ?? 0 }
    }
}

extension Dictionary {
    func mapDictionary<T>(transformation: (Key, Value) -> T) -> [Key : T] {
        var dict = [Key : T]()
        for (key, value) in self {
            dict.updateValue(transformation(key, value), forKey: key)
        }
        return dict
    }
}