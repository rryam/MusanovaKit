import Foundation
import Testing

@testable import MusanovaKit

/// Tests for accented character handling in the lyrics parser (Issue #12)
struct LyricsParserAccentedCharacterTests {
  // MARK: - Basic Accented Character Tests

  @Test
  func testParserDoesNotAddSpaceBeforeAccentedCharacters() throws {
    // Tests merging of single letter with following accented character
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="0.0" end="0.5">je</span><span begin="0.5" end="1.0">vais</span><span begin="1.0" end="1.5">o</span><span begin="1.5" end="2.0">ù</span><span begin="2.0" end="2.5">tu</span></p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    let line = try #require(paragraphs.first?.lines.first)
    // "o ù" should be "où" without a space between o and ù
    #expect(line.text == "je vais où tu")
    #expect(line.segments.count == 5)
  }

  @Test
  func testParserMergesSingleLetterWithAccentedStartToken() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="0.0" end="1.0">o</span><span begin="1.0" end="2.0">ù aller</span></p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "où aller")
    #expect(line.segments.count == 2)
  }

  @Test
  func testParserKeepsSpaceBeforeAccentedWord() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="0.0" end="1.0">aller</span><span begin="1.0" end="2.0">à</span><span begin="2.0" end="3.0">droite</span></p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "aller à droite")
    #expect(line.segments.count == 3)
  }

  @Test
  func testParserMergesSplitAccentedTokens() throws {
    // Tests tokens that contain space-separated letter + accented char
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="0.0" end="0.5">voici</span>
          <span begin="0.5" end="1.0">o ù</span>
          <span begin="1.0" end="1.5">nous</span>
          <span begin="1.5" end="2.0">sommes</span>
          <span begin="2.0" end="2.5">et</span>
          <span begin="2.5" end="3.0">l à</span>
          <span begin="3.0" end="3.5">aussi</span>
        </p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "voici où nous sommes et là aussi")
    #expect(line.segments.count == 7)
    #expect(line.segments[1].text == "où")
    #expect(line.segments[5].text == "là")
  }

  // MARK: - UTF-8 Multi-byte Character Splitting (Issue #12)

  @Test
  func testParserHandlesUTF8CharacterSplitting() throws {
    // Tests that XMLParser splitting multi-byte UTF-8 chars doesn't cause spaces
    // Words like "café", "résumé", "éléphant" should remain intact
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="0.0" end="0.5">un</span>
          <span begin="0.5" end="1.0">café</span>
          <span begin="1.0" end="1.5">et</span>
          <span begin="1.5" end="2.0">un</span>
          <span begin="2.0" end="2.5">résumé</span>
          <span begin="2.5" end="3.0">très</span>
          <span begin="3.0" end="3.5">détaillé</span>
        </p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    let line = try #require(paragraphs.first?.lines.first)
    // Words with accented characters should be intact, no spaces inserted
    #expect(line.text == "un café et un résumé très détaillé")
    #expect(!line.text.contains("caf é"))
    #expect(!line.text.contains("r ésumé"))
    #expect(!line.text.contains("d étaillé"))
  }

  @Test
  func testParserHandlesMultipleAccentedWords() throws {
    // Tests multiple words with accents in sequence
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="0.0" end="0.5">le</span>
          <span begin="0.5" end="1.0">bébé</span>
          <span begin="1.0" end="1.5">a</span>
          <span begin="1.5" end="2.0">mangé</span>
          <span begin="2.0" end="2.5">du</span>
          <span begin="2.5" end="3.0">pâté</span>
        </p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "le bébé a mangé du pâté")
    #expect(line.segments.count == 6)
    #expect(line.segments[1].text == "bébé")
    #expect(line.segments[3].text == "mangé")
    #expect(line.segments[5].text == "pâté")
  }

  @Test
  func testParserHandlesVariousAccentedCharacters() throws {
    // Test various accented characters: é, è, ê, ë, à, â, ù, û, ô, î, ç
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="0.0" end="1.0">très</span>
          <span begin="1.0" end="2.0">bête</span>
          <span begin="2.0" end="3.0">naïf</span>
          <span begin="3.0" end="4.0">drôle</span>
          <span begin="4.0" end="5.0">sûr</span>
        </p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "très bête naïf drôle sûr")
    // No spaces should be inserted within words
    #expect(!line.text.contains("tr ès"))
    #expect(!line.text.contains("b ête"))
    #expect(!line.text.contains("na ïf"))
    #expect(!line.text.contains("dr ôle"))
    #expect(!line.text.contains("s ûr"))
  }

  @Test
  func testParserHandlesMultiLineVerseWithAccents() throws {
    // Tests a complete multi-line structure with various accented characters
    let ttml = wrapTTML(body: """
      <div begin="0.0" end="10.0" itunes:songPart="Verse">
        <p begin="0.0" end="3.0" itunes:key="L1" ttm:agent="v1">
          <span begin="0.0" end="0.5">le</span>
          <span begin="0.5" end="1.0">café</span>
          <span begin="1.0" end="1.5">est</span>
          <span begin="1.5" end="2.0">prêt</span>
          <span begin="2.0" end="2.5">à</span>
          <span begin="2.5" end="3.0">boire</span>
        </p>
        <p begin="3.0" end="6.0" itunes:key="L2" ttm:agent="v1">
          <span begin="3.0" end="3.5">je</span>
          <span begin="3.5" end="4.0">ne</span>
          <span begin="4.0" end="4.5">sais</span>
          <span begin="4.5" end="5.0">pas</span>
          <span begin="5.0" end="5.5">où</span>
          <span begin="5.5" end="6.0">aller</span>
        </p>
        <p begin="6.0" end="10.0" itunes:key="L3" ttm:agent="v1">
          <span begin="6.0" end="6.5">il</span>
          <span begin="6.5" end="7.0">était</span>
          <span begin="7.0" end="7.5">là</span>
          <span begin="7.5" end="8.0">très</span>
          <span begin="8.0" end="8.5">tôt</span>
          <span begin="8.5" end="9.0">ce</span>
          <span begin="9.0" end="10.0">matin</span>
        </p>
      </div>
      """)
    let paragraphs = parse(ttml: ttml)

    #expect(paragraphs.count == 1)
    #expect(paragraphs[0].songPart == "Verse")
    #expect(paragraphs[0].lines.count == 3)

    // Line 1
    let line1 = paragraphs[0].lines[0]
    #expect(line1.text == "le café est prêt à boire")
    #expect(!line1.text.contains("caf é"))
    #expect(!line1.text.contains("pr êt"))

    // Line 2
    let line2 = paragraphs[0].lines[1]
    #expect(line2.text == "je ne sais pas où aller")

    // Line 3
    let line3 = paragraphs[0].lines[2]
    #expect(line3.text == "il était là très tôt ce matin")
    #expect(!line3.text.contains("tr ès"))
    #expect(!line3.text.contains("t ôt"))
  }

  // MARK: - Helpers

  private func parse(ttml: String) -> [LyricParagraph] {
    let parser = LyricsParser()
    return parser.parse(ttml)
  }

  private func wrapTTML(body: String) -> String {
    """
    <tt xmlns="http://www.w3.org/ns/ttml" xmlns:itunes="http://music.apple.com/lyric-ttml-internal" xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
      <body>
        \(body)
      </body>
    </tt>
    """
  }
}
