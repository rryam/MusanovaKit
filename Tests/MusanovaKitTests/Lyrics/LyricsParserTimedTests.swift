@testable import MusanovaKit
import Foundation
import Testing

struct LyricsParserTimedTests {

  @Test
  func testParserProducesTimedSegments() throws {
    let data = try loadFixture(named: "lyricsTimedResponse", withExtension: "json")
    let response = try JSONDecoder().decode(MusicLyricsResponse.self, from: data)

    let ttml = try #require(response.data.first?.attributes.ttml)
    let parser = LyricsParser()
    let paragraphs = parser.parse(ttml)

    let firstParagraph = try #require(paragraphs.first)
    let firstLine = try #require(firstParagraph.lines.first)
    let firstSegment = try #require(firstLine.segments.first)

    #expect(!firstLine.segments.isEmpty)
    #expect(firstSegment.text == "I")
    #expect(abs(firstSegment.startTime - 15.417) < 0.0001)
    #expect(abs(firstSegment.endTime - 15.671) < 0.0001)
  }

  private func loadFixture(named name: String, withExtension ext: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: ext))
    return try Data(contentsOf: url)
  }
}
