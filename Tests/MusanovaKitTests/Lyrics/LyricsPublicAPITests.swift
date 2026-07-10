import MusanovaKit
import MusicKit
import Testing

struct LyricsPublicAPITests {
  @Test
  func responseExposesRawTTMLAndPlaybackMetadata() throws {
    let playParams = PlayParams(
      id: "song-id",
      kind: "song",
      catalogId: "catalog-id",
      displayType: 1
    )
    let attributes = LyricsAttributes(ttml: "<tt></tt>", playParams: playParams)
    let lyricsData = LyricsData(id: "lyrics-id", type: "syllable-lyrics", attributes: attributes)
    let response = MusicLyricsResponse(data: [lyricsData])

    #expect(response.rawTTML == "<tt></tt>")
    #expect(response.data.first?.id == "lyrics-id")
    #expect(response.data.first?.attributes.playParams.catalogId == "catalog-id")
  }

  @Test
  func parserAndTimedSegmentsAreAvailableWithoutTestableImport() throws {
    let ttml = """
      <tt xmlns="http://www.w3.org/ns/ttml">
        <body>
          <div>
            <p><span begin="0.2" end="0.5">Hello</span></p>
          </div>
        </body>
      </tt>
      """

    let paragraphs = try LyricsParser().parseValidating(ttml)

    #expect(paragraphs.first?.lines.first?.text == "Hello")
    #expect(paragraphs.timedSegments.map(\.text) == ["Hello"])
  }

  @Test
  func validatingParserRejectsMalformedTTML() {
    #expect(throws: MusanovaKitError.self) {
      try LyricsParser().parseValidating("<tt><body></tt>")
    }
  }

  @Test
  func directRequestRejectsAnEmptyToken() {
    #expect(throws: MusanovaKitError.self) {
      try MusicLyricsRequest(songID: MusicItemID("song-id"), developerToken: "")
    }
  }
}
