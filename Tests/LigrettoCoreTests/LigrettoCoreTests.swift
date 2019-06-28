import XCTest
@testable import LigrettoCore

class LigrettoDelegate: GameDelegate {

    enum Path {
        case didFinnish
        case didAddPlayer
        case didStartNewRound
        case didReset
        case none
    }

    var gameResult: GameResult?
    var latestPath = Path.none

    func didFinnish(_ game: Game, with result: GameResult) {
        latestPath = .didFinnish
        gameResult = result
    }

    func didAddPlayer(in game: Game) {
        latestPath = .didAddPlayer
    }

    func didStartNewRound(in game: Game) {
        latestPath = .didStartNewRound
    }

    func didReset(_ game: Game) {
        latestPath = .didReset
    }

    func reset() {
        latestPath = .none
    }
}

final class LigrettoCoreTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let mats = Player(name: "Mats", color: .blue)
        let steffen = Player(name: "Steffen", color: .red)

        let delegate = LigrettoDelegate()
        let game = Game()
        game.delegate = delegate

        XCTAssert(game.completedRounds.count == 0)

        let dicentRound = PlayerStats(leftOverCards: 4, placedCards: 30)
        let ligrettoRound = PlayerStats(leftOverCards: 0, placedCards: 30)

        XCTAssert(ligrettoRound.isLigretto)
        XCTAssert(dicentRound.isLigretto == false)
        XCTAssert(delegate.latestPath == .none)

        game.add(mats)
        game.add(steffen)

        XCTAssert(game.players.contains(mats))
        XCTAssert(game.players.contains(steffen))

        XCTAssert(delegate.latestPath == .didAddPlayer)
        delegate.reset()
        XCTAssert(delegate.latestPath == .none)

        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(dicentRound, for: steffen)
        game.saveRound()

        XCTAssert(game.lastRound?.playerWithLigretto() == mats)
        XCTAssert(game.lastRound?.score(for: mats) == ligrettoRound.score)
        XCTAssert(game.lastRound?.score(for: steffen) == dicentRound.score)

        XCTAssert(game.score(for: mats) == ligrettoRound.score)
        XCTAssert(game.score(for: steffen) == dicentRound.score)

        XCTAssert(delegate.latestPath == .didStartNewRound)
        delegate.reset()

        XCTAssert(game.completedRounds.count == 1)

        game.registerRound(ligrettoRound, for: mats)
        game.saveRound()

        XCTAssert(game.score(for: mats) == 2 * ligrettoRound.score)
        XCTAssert(game.score(for: steffen) == dicentRound.score)

        game.registerRound(ligrettoRound, for: mats)
        game.saveRound()
        game.registerRound(ligrettoRound, for: mats)
        game.saveRound()

        XCTAssert(game.lastRound?.score(for: mats) == ligrettoRound.score)
        XCTAssert(game.lastRound?.score(for: steffen) == nil)

        XCTAssert(delegate.latestPath == .didFinnish)
        switch delegate.gameResult {
        case .some(.winner(let player)): XCTAssertEqual(player, mats)
        default: XCTFail("Incorrect winner")
        }

        game.reset()
        XCTAssert(delegate.latestPath == .didReset)
        delegate.reset()

        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(ligrettoRound, for: steffen)
        game.saveRound()
        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(ligrettoRound, for: steffen)
        game.saveRound()
        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(ligrettoRound, for: steffen)
        game.saveRound()
        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(ligrettoRound, for: steffen)
        game.saveRound()

        XCTAssert(delegate.latestPath == .didFinnish)
        switch delegate.gameResult {
        case .some(.drawn(let players)): XCTAssertEqual(players, [mats, steffen])
        default: XCTFail("Incorrect winner")
        }

        game.reset()
        XCTAssert(delegate.latestPath == .didReset)
        delegate.reset()

        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(ligrettoRound, for: steffen)
        game.saveRound()
        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(ligrettoRound, for: steffen)
        game.saveRound()
        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(ligrettoRound, for: steffen)
        game.saveRound()
        game.registerRound(ligrettoRound, for: mats)
        game.registerRound(dicentRound, for: steffen)
        game.saveRound()

        XCTAssert(delegate.latestPath == .didFinnish)
        switch delegate.gameResult {
        case .some(.winner(let player)): XCTAssertEqual(player, mats)
        default: XCTFail("Incorrect winner")
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
