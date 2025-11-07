//
//  MusanovaKit.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation
@_exported import MusadoraKit
@_exported import MusicKit

public struct MusanovaKit {}

public extension MusanovaKit {
  static var privilegedDeveloperToken: String? {
    let token = ProcessInfo.processInfo.environment["DEVELOPER_TOKEN"]
    return token?.isEmpty == false ? token : nil
  }
}
