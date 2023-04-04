//
//  MusanovaKitTests.swift
//  MusanovaKitTests
//
//  Created by Rudrank Riyam on 04/04/23.
//

@testable import MusanovaKit
import XCTest

final class MusanovaKitTests: XCTestCase {}

public func XCTAssertEqualEndpoint(_ endpoint: URL, _ url: String) {
  let url = URL(string: url)!
  XCTAssertEqual(endpoint, url)
}
