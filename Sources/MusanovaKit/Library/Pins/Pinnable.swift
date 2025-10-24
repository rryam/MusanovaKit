//  MusanovaKit
//
//  Created by Rudrank Riyam on 25/10/25.
//

import Foundation

/// A protocol that represents a music item that can be pinned to the user's Apple Music library.
///
/// This protocol includes the requirement that items must be music items that can be identified
/// and pinned through Apple's private API endpoints.
public protocol Pinnable: MusicItem {}

/// An extension of `Album` that makes it pinnable to the user's Apple Music library.
extension Album: Pinnable {}

/// An extension of `Song` that makes it pinnable to the user's Apple Music library.
extension Song: Pinnable {}

/// An extension of `Playlist` that makes it pinnable to the user's Apple Music library.
extension Playlist: Pinnable {}

/// An extension of `Artist` that makes it pinnable to the user's Apple Music library.
extension Artist: Pinnable {}
