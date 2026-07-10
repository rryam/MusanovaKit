//
//  MusicPrivilegedDataRequestTests.swift
//  MusanovaKitTests
//

import Foundation
import Testing

@testable import MusanovaKit

@Suite
struct MusicPrivilegedDataRequestTests {
  @Test
  func buildsRequestWithMethodHeadersAndBody() throws {
    let url = try #require(URL(string: "https://amp-api.music.apple.com/v1/me/test"))
    let body = Data(#"{"name":"Mix"}"#.utf8)
    let request = MusicPrivilegedDataRequest(
      url: url,
      developerToken: "developer-token",
      method: .patch,
      headers: [
        "Content-Type": "application/json",
        "X-Test": "value"
      ],
      body: body
    ).makeURLRequest()

    #expect(request.url == url)
    #expect(request.httpMethod == "PATCH")
    #expect(request.httpBody == body)
    #expect(request.value(forHTTPHeaderField: "Origin") == "https://music.apple.com")
    #expect(request.value(forHTTPHeaderField: "Host") == "amp-api.music.apple.com")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(request.value(forHTTPHeaderField: "X-Test") == "value")
  }

  @Test
  func keepsExistingDefaults() throws {
    let url = try #require(URL(string: "https://amp-api.music.apple.com/v1/test"))
    let request = MusicPrivilegedDataRequest(
      url: url,
      developerToken: "developer-token"
    ).makeURLRequest()

    #expect(request.httpMethod == "GET")
    #expect(request.httpBody == nil)
  }
}
