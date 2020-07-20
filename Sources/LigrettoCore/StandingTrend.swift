//
//  File.swift
//  
//
//  Created by Mats Mollestad on 23/06/2019.
//

import Foundation

public struct StandingTrendValue: Codable, ExpressibleByIntegerLiteral {

    let value: Int

    public init(integerLiteral value: IntegerLiteralType) {
        self.value = value
    }
}

public enum StandingTrend: Codable, Equatable {

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(Int.self)
        switch value {
        case ..<0: self = .down(abs(value))
        case 0: self = .same
        default: self = .up(value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .down(let value): try container.encode(-value)
        case .up(let value): try container.encode(value)
        default: try container.encode(0)
        }
    }

    case up(Int)
    case down(Int)
    case same
}
