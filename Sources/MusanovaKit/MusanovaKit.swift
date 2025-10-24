//
//  MusanovaKit.swift
//  MusanovaKit
//
//  Created by Rudrank Riyam on 04/04/23.
//

import Foundation
@_exported import MusicKit
@_exported import MusadoraKit

public struct MusanovaKit {}

extension MusanovaKit {
  public static var privilegedDeveloperToken: String? {
    ProcessInfo.processInfo.environment["DEVELOPER_TOKEN"]
  }
}
