//
//  LyricsParser.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 21/06/24.
//

import Foundation

/// A parser for converting TTML (Timed Text Markup Language) lyrics into structured `LyricParagraph` objects.
public class LyricsParser: NSObject, XMLParserDelegate {
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
  private var pendingSpaceBetweenElements: Bool = false

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
    pendingSpaceBetweenElements = false
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
        // Don't add space here - multi-byte UTF-8 chars may be split across calls
        // and spacing between spans is handled by the <p> element's whitespace
        currentSegmentText += normalized
      } else if string.containsWhitespaceOnly {
        hasPendingWhitespace = true
      }
    } else if currentElement == "p" {
      // Check if the original string has content (not just whitespace)
      // This preserves spaces between <span> elements in the XML
      let hasContent = !string.allSatisfy { $0.isWhitespace }
      let normalized = normalizePlainText(string)
      if !normalized.isEmpty {
        appendToCurrentLineTokens(normalized)
      } else if hasContent {
        // String has content but normalized to empty - this is a space between spans
        // Don't set hasPendingWhitespace, the space is already in the output
      } else if string.containsWhitespaceOnly {
        hasPendingWhitespace = true
      }
    }

    // Track if we just saw a space between elements
    if currentElement == "span", string == " " {
      pendingSpaceBetweenElements = true
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
      if !trimmedText.isEmpty {
        let segment = LyricSegment(text: trimmedText, startTime: start, endTime: end)
        currentLineSegments.append(segment)
        appendToCurrentLineTokens(trimmedText)
      }
      currentSegmentText = ""
      currentSegmentStart = nil
      currentSegmentEnd = nil
      // Preserve space flag across span boundaries
      hasPendingWhitespace = hasPendingWhitespace || pendingSpaceBetweenElements
      pendingSpaceBetweenElements = false
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
    var index = 0

    while index < currentLineTokens.count {
      let token = currentLineTokens[index]

      guard !token.text.isEmpty else {
        index += 1
        continue
      }

      if result.isEmpty {
        result = token.text
        index += 1
        continue
      }

      // Check if we should merge single letter with accented token (e.g., "o" + "ù" → "où")
      if token.needsLeadingSpace,
         index > 0,
         let prevFirst = currentLineTokens[index - 1].text.first,
         prevFirst.isASCII,
         prevFirst.isLetter,
         currentLineTokens[index - 1].text.count == 1,
         token.text.count == 1,
         let first = token.text.first,
         isAccentedLatinLetter(first) {
        // Merge: remove trailing space if any, then append accented char
        if result.hasSuffix(" ") {
          result.removeLast()
        }
        result += token.text
      } else {
        // Normal case: add space if needed, then token
        let avoidSpace = shouldAvoidPrecedingSpace(before: token.text)
        if !avoidSpace && !result.hasSuffix(" ") {
          result += " "
        }
        result += token.text
      }

      index += 1
    }

    return result
  }

  private func isAccentedLatinLetter(_ char: Character) -> Bool {
    // Check for non-ASCII Latin letters (accented characters)
    let charStr = String(char)
    guard let scalar = charStr.unicodeScalars.first else { return false }
    return scalar.value > 127 && scalar.value <= 0x024F // Latin Extended-A end
  }

  private func normalizeSpanText(_ string: String) -> String {
    string.collapsingWhitespace()
  }

  private func normalizePlainText(_ string: String) -> String {
    string.collapsingWhitespace()
  }

  private func shouldAvoidPrecedingSpace(before token: String) -> Bool {
    guard let first = token.first else { return false }
    return ",.!?:;)]}".contains(first)
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
