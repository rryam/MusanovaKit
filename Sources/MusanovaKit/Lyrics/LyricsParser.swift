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

  /// The name of the current XML element being processed.
  private var currentElement: String = ""

  /// The element stack to track the current parsing context.
  private var elementStack: [String] = []

  private var currentLineText: String = ""
  private var currentLineSegments: [LyricSegment] = []
  private var currentSegmentStart: TimeInterval?
  private var currentSegmentEnd: TimeInterval?
  private var currentSegmentText: String = ""

  /// Parses the given XML string into an array of `LyricParagraph` objects.
  ///
  /// - Parameter xmlString: The TTML lyrics string to parse.
  /// - Returns: An array of parsed `LyricParagraph` objects.
  func parse(_ xmlString: String) -> [LyricParagraph] {
    paragraphs = []
    currentParagraph = []
    currentSongPart = nil
    currentLineText = ""
    currentLineSegments = []
    currentSegmentStart = nil
    currentSegmentEnd = nil
    currentSegmentText = ""
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
  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    elementStack.append(elementName)

    if elementName == "div" {
      currentSongPart = attributeDict["itunes:songPart"]
      currentParagraph = []
    } else if elementName == "p" {
      currentLineText = ""
      currentLineSegments = []
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
      let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        currentSegmentText += trimmed
      }
    } else if currentElement == "p" {
      let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        if currentLineText.isEmpty {
          currentLineText = trimmed
        } else {
          currentLineText += " " + trimmed
        }
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
      if !currentSegmentText.isEmpty {
        let segment = LyricSegment(text: currentSegmentText, startTime: start, endTime: end)
        currentLineSegments.append(segment)
      }
      currentSegmentText = ""
      currentSegmentStart = nil
      currentSegmentEnd = nil
    } else if elementName == "p" {
      let lineText: String
      if currentLineSegments.isEmpty {
        lineText = currentLineText.trimmingCharacters(in: .whitespacesAndNewlines)
      } else {
        lineText = currentLineSegments.map { $0.text }.joined(separator: " ")
      }

      let line = LyricLine(text: lineText, segments: currentLineSegments)
      currentParagraph.append(line)
      currentLineText = ""
      currentLineSegments = []
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
      hours = Int(components[0]) ?? 0
      minutes = Int(components[1]) ?? 0
      secondsComponent = components[2]
    case 2:
      minutes = Int(components[0]) ?? 0
      secondsComponent = components[1]
    default:
      break
    }

    let seconds = Double(secondsComponent.replacingOccurrences(of: ",", with: ".")) ?? 0
    return TimeInterval(hours * 3600 + minutes * 60) + seconds
  }
}
