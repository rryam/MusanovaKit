#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Adds Apple's Mescal action signature to a mutable Apple Music request.
FOUNDATION_EXPORT BOOL MNKAddAppleMusicActionSignature(
    NSMutableURLRequest *request,
    NSError * _Nullable * _Nullable error
);

NS_ASSUME_NONNULL_END
