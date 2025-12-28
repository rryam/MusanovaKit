//
//  LyricsParser.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 21/06/24.
//

import Foundation

/// A parser for converting TTML (Timed Text Markup Language) lyrics into structured `LyricParagraph` objects.
public class LyricsParser: NSObject, XMLParserDelegate {
  /// Characters that should not have a preceding space (ASCII punctuation).
  private static let punctuationChars: Set<Character> = Set(",.!?:;)]}")

  /// Non-ASCII Latin letters that may start a token that's a continuation
  /// of the previous word (like "ù" in "où").
  private static let nonAsciiLatinRegex: NSRegularExpression = {
    let pattern = "^[\\p{Latin}&&[^\\p{ASCII}]]$"
    do {
      return try NSRegularExpression(pattern: pattern)
    } catch {
      preconditionFailure("Invalid non-ASCII Latin regex: \(error)")
    }
  }()

  private static func isNonAsciiLatin(_ char: Character) -> Bool {
    let text = String(char)
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    return nonAsciiLatinRegex.firstMatch(in: text, range: range) != nil
  }

  /// The parsed lyric paragraphs.
  private var paragraphs: [LyricParagraph] = []

  /// The current paragraph being parsed.
  private var currentParagraph: [LyricLine] = []

  /// The song part (e.g., "Verse", "Chorus") of the current paragraph.
  private var currentSongPart: String?

  /// The element stack to track the current parsing context.
  private var elementStack: [String] = []

  private struct LineToken {
    let text: String
    let needsLeadingSpace: Bool
  }

  private var currentLineTokens: [LineToken] = []
  private var currentLineSegments: [LyricSegment] = []
  private var currentSegmentStart: TimeInterval?
  private var currentSegmentEnd: TimeInterval?
  private var currentSegmentText: String = ""
  private var hasPendingWhitespace: Bool = false

  /// Parses the given XML string into an array of `LyricParagraph` objects.
  ///
  /// - Parameter xmlString: The TTML lyrics string to parse.
  /// - Returns: An array of parsed `LyricParagraph` objects.
  func parse(_ xmlString: String) -> [LyricParagraph] {
    paragraphs = []
    currentParagraph = []
    currentSongPart = nil
    currentLineTokens = []
    currentLineSegments = []
    currentSegmentStart = nil
    currentSegmentEnd = nil
    currentSegmentText = ""
    hasPendingWhitespace = false
    elementStack = []
    if let data = xmlString.data(using: .utf8) {
      let parser = XMLParser(data: data)
      parser.delegate = self
      parser.parse()
    }
    return paragraphs
  }

  /// Called when the parser begins parsing an element.
  ///
  /// - Parameters:
  ///   - parser: The parser object.
  ///   - elementName: The name of the element that is being parsed.
  ///   - namespaceURI: The namespace URI or `nil` if none is available.
  ///   - qName: The qualified name or `nil` if none is available.
  ///   - attributeDict: A dictionary of attribute names and values.
  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
    elementStack.append(elementName)

    if elementName == "div" {
      currentSongPart = attributeDict["itunes:songPart"]
      currentParagraph = []
    } else if elementName == "p" {
      currentLineTokens = []
      currentLineSegments = []
      hasPendingWhitespace = false
    } else if elementName == "span" {
      currentSegmentText = ""
      currentSegmentStart = attributeDict["begin"].flatMap(parseTimecode)
      currentSegmentEnd = attributeDict["end"].flatMap(parseTimecode)
    }
  }

  /// Called when the parser finds characters within an element.
  ///
  /// - Parameters:
  ///   - parser: The parser object.
  ///   - string: The character string.
  public func parser(_ parser: XMLParser, foundCharacters string: String) {
    guard let currentElement = elementStack.last else { return }

    if currentElement == "span" {
      let normalized = normalizeSpanText(string)
      if !normalized.isEmpty {
        if !currentSegmentText.isEmpty {
          currentSegmentText += " "
        }
        currentSegmentText += normalized
      } else if string.containsWhitespaceOnly {
        hasPendingWhitespace = true
      }
    } else if currentElement == "p" {
      let normalized = normalizePlainText(string)
      if !normalized.isEmpty {
        appendToCurrentLineTokens(normalized)
      } else if string.containsWhitespaceOnly {
        hasPendingWhitespace = true
      }
    }
  }

  /// Called when the parser ends parsing an element.
  ///
  /// - Parameters:
  ///   - parser: The parser object.
  ///   - elementName: The name of the element.
  ///   - namespaceURI: The namespace URI or `nil` if none is available.
  ///   - qName: The qualified name or `nil` if none is available.
  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "div" {
      let paragraph = LyricParagraph(lines: currentParagraph, songPart: currentSongPart)
      paragraphs.append(paragraph)
      currentParagraph = []
      currentSongPart = nil
    } else if elementName == "span" {
      let start = currentSegmentStart ?? 0
      let end = currentSegmentEnd ?? start
      let trimmedText = currentSegmentText.trimmingCharacters(in: .whitespacesAndNewlines)
      let mergedText = mergeSingleLetterAccentedTokens(in: trimmedText)
      if !mergedText.isEmpty {
        let segment = LyricSegment(text: mergedText, startTime: start, endTime: end)
        currentLineSegments.append(segment)
        appendToCurrentLineTokens(mergedText)
      }
      currentSegmentText = ""
      currentSegmentStart = nil
      currentSegmentEnd = nil
      hasPendingWhitespace = false
    } else if elementName == "p" {
      let lineText = assembledLineText()

      let line = LyricLine(text: lineText, segments: currentLineSegments)
      currentParagraph.append(line)
      currentLineTokens = []
      currentLineSegments = []
      hasPendingWhitespace = false
    }
    if !elementStack.isEmpty {
      elementStack.removeLast()
    }
  }

  private func parseTimecode(_ value: String) -> TimeInterval? {
    let components = value.split(separator: ":")
    guard !components.isEmpty else { return nil }

    var hours = 0
    var minutes = 0
    var secondsComponent = components.last!

    switch components.count {
    case 3:
      guard let hoursValue = Int(components[0]), let minutesValue = Int(components[1]) else { return nil }
      hours = hoursValue
      minutes = minutesValue
      secondsComponent = components[2]
    case 2:
      guard let minutesValue = Int(components[0]) else { return nil }
      minutes = minutesValue
      secondsComponent = components[1]
    default:
      break
    }

    guard let seconds = Double(secondsComponent.replacingOccurrences(of: ",", with: ".")) else {
      return nil
    }
    return TimeInterval(hours * 3600 + minutes * 60) + seconds
  }

  private func appendToCurrentLineTokens(_ text: String) {
    guard !text.isEmpty else { return }

    let needsSpace = hasPendingWhitespace && !currentLineTokens.isEmpty
    currentLineTokens.append(LineToken(text: text, needsLeadingSpace: needsSpace))
    hasPendingWhitespace = false
  }

  private func assembledLineText() -> String {
    var result = ""
    var previousTokenText: String?

    for token in currentLineTokens where !token.text.isEmpty {
      if result.isEmpty {
        result = token.text
        previousTokenText = token.text
        continue
      }

      let avoidSpace = shouldAvoidPrecedingSpace(before: token.text, previousToken: previousTokenText)
      // Add space between tokens unless avoiding it (punctuation or accented continuation).
      if !avoidSpace && !result.hasSuffix(" ") {
        result += " "
      }

      result += token.text
      previousTokenText = token.text
    }

    return result
  }

  private func normalizeSpanText(_ string: String) -> String {
    mergeSingleLetterAccentedTokens(in: string.collapsingWhitespace())
  }

  private func normalizePlainText(_ string: String) -> String {
    mergeSingleLetterAccentedTokens(in: string.collapsingWhitespace())
  }

  private func shouldAvoidPrecedingSpace(before token: String, previousToken: String?) -> Bool {
    guard let first = token.first else { return false }

    if Self.punctuationChars.contains(first) {
      return true
    }

    guard let previousToken, previousToken.count == 1, previousToken.first?.isLetter == true else {
      return false
    }

    return Self.isNonAsciiLatin(first)
  }

  private func mergeSingleLetterAccentedTokens(in text: String) -> String {
    let parts = text.split(separator: " ")
    guard parts.count > 1 else { return text }

    var result: [String] = []
    var index = 0
    while index < parts.count {
      let current = String(parts[index])
      if current.count == 1,
         let currentFirst = current.first,
         currentFirst.isASCII,
         currentFirst.isLetter,
         index + 1 < parts.count {
        let next = String(parts[index + 1])
        if let nextFirst = next.first, Self.isNonAsciiLatin(nextFirst) {
          result.append(current + next)
          index += 2
          continue
        }
      }

      result.append(current)
      index += 1
    }

    return result.joined(separator: " ")
  }
}

private extension String {
  func collapsingWhitespace() -> String {
    guard !isEmpty else { return self }

    let collapsed = replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var containsWhitespaceOnly: Bool {
    !isEmpty && allSatisfy { $0.isWhitespace }
  }
}
