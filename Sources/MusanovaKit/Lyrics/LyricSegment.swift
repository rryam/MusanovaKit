import Foundation

/// Represents a timed segment of a lyric line.
public struct LyricSegment: Identifiable {

  /// A unique identifier for the lyric segment.
  public let id = UUID()

  /// The text content associated with this segment.
  public let text: String

  /// The start time of the segment, in seconds.
  public let startTime: TimeInterval

  /// The end time of the segment, in seconds.
  public let endTime: TimeInterval

  /// Creates a new timed lyric segment.
  ///
  /// - Parameters:
  ///   - text: The displayed text for the segment.
  ///   - startTime: The start time for the segment, in seconds.
  ///   - endTime: The end time for the segment, in seconds.
  public init(text: String, startTime: TimeInterval, endTime: TimeInterval) {
    self.text = text
    self.startTime = startTime
    self.endTime = endTime
  }
}
