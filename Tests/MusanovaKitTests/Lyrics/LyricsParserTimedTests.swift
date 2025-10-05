@testable import MusanovaKit
import Foundation
import Testing

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
