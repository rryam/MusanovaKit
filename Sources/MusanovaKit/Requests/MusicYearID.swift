//
//  MusicYearID.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 07/04/23.
//

import Foundation

/// An object that represents a unique identifier for a music year.
@frozen
public struct MusicYearID: Equatable, Hashable, Sendable, RawRepresentable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
  /// The corresponding value of the raw type.
  public let rawValue: String

  /// Creates a music year identifier with a string.
  public init(_ rawValue: String) {
    self.rawValue = rawValue
  }

  /// Creates a music year identifier with an integer.
  public init(_ rawValue: Int) {
    self.rawValue = String(rawValue)
  }

  /// Creates a new instance with the specified raw value.
  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  /// Creates an instance initialized to the given string value.
  public init(stringLiteral value: String) {
    self.rawValue = value
  }

  /// Creates an instance initialized to the given integer value.
  public init(integerLiteral value: Int) {
    self.rawValue = String(value)
  }

  /// A type that represents an extended grapheme cluster literal.
  public typealias ExtendedGraphemeClusterLiteralType = String

  /// The raw type that can be used to represent all values of the conforming
  /// type.
  public typealias RawValue = String

  /// A type that represents a string literal.
  public typealias StringLiteralType = String

  /// A type that represents a Unicode scalar literal.
  public typealias UnicodeScalarLiteralType = String

  /// A type that represents an integer literal.
  public typealias IntegerLiteralType = Int
}
