import Foundation
import Testing

@testable import MusanovaKit

/// Tests for accented character handling in the lyrics parser (Issue #12)
struct LyricsParserAccentedCharacterTests {
  // MARK: - Basic Accented Character Tests

  @Test
  func testParserDoesNotAddSpaceBeforeAccentedCharacters() throws {
    // Simulates structure from "amsterdam" by Disiz
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="14.680000" end="15.001000">suis,</span><span begin="15.001000" end="15.195000">ni</span><span begin="15.195000" end="15.385000">o</span><span begin="15.385000" end="15.572000">ù</span><span begin="15.572000" end="15.784000">je</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    // "o ù" should be "où" without a space between o and ù
    #expect(line.text == "suis, ni où je")
    #expect(line.segments.count == 5)
  }

  @Test
  func testParserMergesSingleLetterWithAccentedStartToken() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="0.0" end="1.0">o</span><span begin="1.0" end="2.0">ù je</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "où je")
    #expect(line.segments.count == 2)
  }

  @Test
  func testParserKeepsSpaceBeforeAccentedWord() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="0.0" end="1.0">vais</span><span begin="1.0" end="2.0">à</span><span begin="2.0" end="3.0">paris</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "vais à paris")
    #expect(line.segments.count == 3)
  }

  @Test
  func testParserMergesAccentedTokensInIssueSample() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="14.680000" end="15.001000">suis,</span>
          <span begin="15.001000" end="15.195000">ni</span>
          <span begin="15.195000" end="15.385000">o ù</span>
          <span begin="15.385000" end="15.572000">je</span>
          <span begin="15.572000" end="15.784000">vais,</span>
          <span begin="15.784000" end="15.996000">c'est</span>
          <span begin="15.996000" end="16.247000">l à</span>
          <span begin="16.247000" end="17.112000">apparemment</span>
          <span begin="17.250000" end="17.482000">Demain</span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "suis, ni où je vais, c'est là apparemment Demain")
    #expect(line.segments.count == 9)
    #expect(line.segments[2].text == "où")
    #expect(line.segments[6].text == "là")
  }

  // MARK: - UTF-8 Multi-byte Character Splitting (Issue #12)

  @Test
  func testParserHandlesUTF8CharacterSplitting() throws {
    // Tests that XMLParser splitting multi-byte UTF-8 chars doesn't cause spaces
    // Words like "félicite", "réussis", "quitté" should remain intact
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="17.250" end="17.482">Demain</span>
          <span begin="17.482" end="17.708">j'me</span>
          <span begin="17.708" end="18.452">félicite</span>
          <span begin="18.452" end="18.591">si</span>
          <span begin="18.591" end="19.274">j'réussis</span>
          <span begin="19.274" end="19.517">à</span>
          <span begin="19.517" end="19.749">rejoindre</span>
          <span begin="19.749" end="20.592">l'appartement</span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    // Words with accented characters should be intact, no spaces inserted
    #expect(line.text == "Demain j'me félicite si j'réussis à rejoindre l'appartement")
    #expect(!line.text.contains("f élicite"))
    #expect(!line.text.contains("r éussis"))
  }

  @Test
  func testParserHandlesAccentedWordsFromAmsterdamSong() throws {
    // Real structure from "amsterdam" by Disiz (Issue #12)
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="34.220" end="34.641">J'ai</span>
          <span begin="34.641" end="35.469">quitté</span>
          <span begin="35.469" end="36.378">l'aventure</span>
          <span begin="36.378" end="36.689">du</span>
          <span begin="36.689" end="37.052">réel</span>
          <span begin="37.052" end="37.230">ce</span>
          <span begin="37.230" end="37.668">soir</span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "J'ai quitté l'aventure du réel ce soir")
    #expect(line.segments.count == 7)
    #expect(line.segments[1].text == "quitté")
    #expect(line.segments[4].text == "réel")
  }

  @Test
  func testParserHandlesVariousAccentedCharacters() throws {
    // Test various accented characters: é, è, ê, ë, à, â, ù, û, ô, î
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="0.0" end="1.0">très</span>
          <span begin="1.0" end="2.0">tête</span>
          <span begin="2.0" end="3.0">fée</span>
          <span begin="3.0" end="4.0">pâte</span>
          <span begin="4.0" end="5.0">où</span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "très tête fée pâte où")
    // No spaces should be inserted within words
    #expect(!line.text.contains("tr ès"))
    #expect(!line.text.contains("t ête"))
    #expect(!line.text.contains("f ée"))
    #expect(!line.text.contains("p âte"))
  }

  @Test
  func testParserHandlesFullAmsterdamVerse() throws {
    // Complete verse from the Amsterdam song
    let ttml = wrapTTML(body: """
      <div begin="6.734" end="20.592" itunes:songPart="Verse">
        <p begin="6.734" end="10.168" itunes:key="L1" ttm:agent="v1">
          <span begin="6.734" end="6.984">La</span>
          <span begin="6.984" end="7.232">nuit,</span>
          <span begin="7.232" end="7.406">des</span>
          <span begin="7.406" end="7.608">fois,</span>
          <span begin="7.608" end="7.815">ça</span>
          <span begin="7.815" end="8.014">tise,</span>
          <span begin="8.014" end="8.234">des</span>
          <span begin="8.234" end="8.393">fois,</span>
          <span begin="8.393" end="8.648">ça</span>
          <span begin="8.648" end="8.940">taz,</span>
          <span begin="8.940" end="9.136">ça</span>
          <span begin="9.136" end="9.335">vit</span>
          <span begin="9.335" end="9.518">très</span>
          <span begin="9.518" end="10.168">bizarrement</span>
        </p>
        <p begin="13.857" end="17.112" itunes:key="L3" ttm:agent="v1">
          <span begin="13.857" end="14.048">Ni</span>
          <span begin="14.048" end="14.216">où</span>
          <span begin="14.216" end="14.399">est-ce</span>
          <span begin="14.399" end="14.506">que</span>
          <span begin="14.506" end="14.680">je</span>
          <span begin="14.680" end="15.001">suis,</span>
          <span begin="15.001" end="15.195">ni</span>
          <span begin="15.195" end="15.385">où</span>
          <span begin="15.385" end="15.572">je</span>
          <span begin="15.572" end="15.784">vais,</span>
          <span begin="15.784" end="15.996">c'est</span>
          <span begin="15.996" end="16.247">là</span>
          <span begin="16.247" end="17.112">apparemment</span>
        </p>
        <p begin="17.250" end="20.592" itunes:key="L4" ttm:agent="v1">
          <span begin="17.250" end="17.482">Demain</span>
          <span begin="17.482" end="17.708">j'me</span>
          <span begin="17.708" end="18.452">félicite</span>
          <span begin="18.452" end="18.591">si</span>
          <span begin="18.591" end="19.274">j'réussis</span>
          <span begin="19.274" end="19.517">à</span>
          <span begin="19.517" end="19.749">rejoindre</span>
          <span begin="19.749" end="20.592">l'appartement</span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    #expect(paragraphs.count == 1)
    #expect(paragraphs[0].songPart == "Verse")
    #expect(paragraphs[0].lines.count == 3)

    // Line 1: "La nuit, des fois, ça tise..."
    let line1 = paragraphs[0].lines[0]
    #expect(line1.text == "La nuit, des fois, ça tise, des fois, ça taz, ça vit très bizarrement")
    #expect(!line1.text.contains("tr ès"))

    // Line 2: "Ni où est-ce que je suis..."
    let line2 = paragraphs[0].lines[1]
    #expect(line2.text == "Ni où est-ce que je suis, ni où je vais, c'est là apparemment")

    // Line 3: "Demain j'me félicite..."
    let line3 = paragraphs[0].lines[2]
    #expect(line3.text == "Demain j'me félicite si j'réussis à rejoindre l'appartement")
    #expect(!line3.text.contains("f élicite"))
    #expect(!line3.text.contains("r éussis"))
  }

  // MARK: - Helper

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
