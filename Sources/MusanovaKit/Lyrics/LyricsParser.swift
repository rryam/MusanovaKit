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

  /// Parses the given XML string into an array of `LyricParagraph` objects.
  ///
  /// - Parameter xmlString: The TTML lyrics string to parse.
  /// - Returns: An array of parsed `LyricParagraph` objects.
  func parse(_ xmlString: String) -> [LyricParagraph] {
    paragraphs = []
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
    if elementName == "div" {
      currentSongPart = attributeDict["itunes:songPart"]
      currentParagraph = []
    } else if elementName == "p" {
      currentParagraph.append(LyricLine(text: ""))
    }
  }

  /// Called when the parser finds characters within an element.
  ///
  /// - Parameters:
  ///   - parser: The parser object.
  ///   - string: The character string.
  public func parser(_ parser: XMLParser, foundCharacters string: String) {
    if currentElement == "p", !currentParagraph.isEmpty {
      currentParagraph[currentParagraph.count - 1].text += string.trimmingCharacters(in: .whitespacesAndNewlines)
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
    }
  }
}
