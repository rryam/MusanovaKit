import Foundation
import Testing

@testable import MusanovaKit

struct LyricsParserTimedTests {
  @Test
  func testParserProducesTimedSegments() throws {
    let ttml = wrapTTML(body: """
      <div begin="0.0" end="5.0" itunes:songPart="Verse">
        <p begin="0.0" end="1.5" itunes:key="L1" ttm:agent="v1">
          <span begin="0.5" end="0.9">We</span>
          <span begin="0.9" end="1.2">rise</span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let firstParagraph = try #require(paragraphs.first)
    let firstLine = try #require(firstParagraph.lines.first)
    let firstSegment = try #require(firstLine.segments.first)

    #expect(!firstLine.segments.isEmpty)
    #expect(firstSegment.text == "We")
    #expect(abs(firstSegment.startTime - 0.5) < 0.0001)
    #expect(abs(firstSegment.endTime - 0.9) < 0.0001)
  }

  @Test
  func testParserHandlesPlainParagraphWithoutSpans() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p>Just some plain text line</p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "Just some plain text line")
    #expect(line.segments.isEmpty)
  }

  @Test
  func testParserKeepsUntimedTextAlongsideSegments() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p>Lead in <span begin="1.0" end="1.5">timed</span> outro</p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.text == "Lead in timed outro")
    #expect(line.segments.count == 1)
    #expect(line.segments.first?.text == "timed")
  }

  @Test
  func testParserHandlesNestedBackgroundSpans() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p>
          <span begin="5.0" end="5.5">Lead</span>
          <span ttm:role="x-bg"><span begin="5.5" end="6.0">Background</span></span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    #expect(line.segments.count == 2)
    #expect(line.segments[0].text == "Lead")
    #expect(abs(line.segments[0].startTime - 5.0) < 0.0001)
    #expect(abs(line.segments[1].startTime - 5.5) < 0.0001)
    #expect(line.segments[1].text == "Background")
  }

  @Test
  func testParserParsesMinuteTimecodes() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="1:02.915" end="1:03.100">Late</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let segment = try #require(paragraphs.first?.lines.first?.segments.first)
    #expect(abs(segment.startTime - 62.915) < 0.0001)
    #expect(abs(segment.endTime - 63.1) < 0.0001)
  }

  @Test
  func testParserDefaultsTimingWhenBeginMissing() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span end="2.5">Hi</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let segment = try #require(paragraphs.first?.lines.first?.segments.first)
    #expect(segment.startTime == 0)
    #expect(abs(segment.endTime - 2.5) < 0.0001)
  }

  @Test
  func testParserHandlesMultipleSongParts() throws {
    let ttml = wrapTTML(body: """
      <div begin="0" end="2" itunes:songPart="Intro">
        <p begin="0" end="2" itunes:key="LIntro" ttm:agent="v1">
          <span begin="0.0" end="0.6">Intro</span>
        </p>
      </div>
      <div begin="2" end="4" itunes:songPart="Verse">
        <p begin="2" end="3" itunes:key="LVerse" ttm:agent="v1">
          <span begin="2.0" end="2.4">Verse</span>
          <span begin="2.4" end="2.8">Line</span>
        </p>
      </div>
      <div begin="4" end="6" itunes:songPart="Chorus">
        <p begin="4" end="5" itunes:key="LChorus" ttm:agent="v1">
          <span begin="4.0" end="4.5">Chorus</span>
        </p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    #expect(paragraphs.count == 3)
    #expect(paragraphs.first?.songPart == "Intro")

    let verseParagraph = try #require(paragraphs.first(where: { $0.songPart == "Verse" }))
    let verseLine = try #require(verseParagraph.lines.first)

    #expect(verseLine.segments.count == 2)
    #expect(verseLine.segments.first?.text == "Verse")
    if let segment = verseLine.segments.first {
      #expect(abs(segment.startTime - 2.0) < 0.0001)
    }
  }

  // MARK: - Error Cases

  @Test
  func testParserHandlesEmptyInput() throws {
    let parser = LyricsParser()
    let paragraphs = parser.parse("")
    #expect(paragraphs.isEmpty)
  }

  @Test
  func testParserHandlesInvalidXML() throws {
    let invalidXML = "<not>valid</xml>"
    let parser = LyricsParser()
    let paragraphs = parser.parse(invalidXML)
    // Parser should handle gracefully and return empty or partial results
    #expect(paragraphs.isEmpty || paragraphs.allSatisfy { $0.lines.isEmpty })
  }

  @Test
  func testParserHandlesMalformedTTML() throws {
    let malformed = """
    <tt xmlns="http://www.w3.org/ns/ttml">
      <body>
        <div>
          <p>Unclosed tag
        </div>
      </body>
    </tt>
    """
    let parser = LyricsParser()
    let paragraphs = parser.parse(malformed)
    // Should handle gracefully
    #expect(paragraphs.isEmpty || paragraphs.allSatisfy { $0.lines.isEmpty })
  }

  @Test
  func testParserHandlesInvalidTimecodeFormat() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="invalid" end="also-invalid">Text</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    let segment = try #require(line.segments.first)
    // Invalid timecodes should default to 0 for start, end should match start
    #expect(segment.startTime == 0)
    #expect(segment.endTime == 0)
    #expect(segment.text == "Text")
  }

  @Test
  func testParserHandlesEmptyTimecode() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="" end="">Text</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    let segment = try #require(line.segments.first)
    // Empty timecodes should default to 0
    #expect(segment.startTime == 0)
    #expect(segment.endTime == 0)
  }

  @Test
  func testParserHandlesInvalidTimecodeWithCommas() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="1,2,3" end="4,5,6">Text</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    let segment = try #require(line.segments.first)
    // Should handle gracefully, defaults to 0
    #expect(segment.startTime == 0)
    #expect(segment.endTime == 0)
  }

  @Test
  func testParserHandlesTimecodeWithTooManyComponents() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="1:2:3:4" end="5:6:7:8">Text</span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    let segment = try #require(line.segments.first)
    // Should parse what it can, defaulting invalid parts to 0
    #expect(segment.text == "Text")
  }

  @Test
  func testParserHandlesEmptySpans() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="1.0" end="2.0"></span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    // Empty spans should not create segments
    #expect(line.segments.isEmpty)
  }

  @Test
  func testParserHandlesWhitespaceOnlySpans() throws {
    let ttml = wrapTTML(body: """
      <div>
        <p><span begin="1.0" end="2.0">   </span></p>
      </div>
      """)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let line = try #require(paragraphs.first?.lines.first)
    // Whitespace-only spans should not create segments
    #expect(line.segments.isEmpty)
  }

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
