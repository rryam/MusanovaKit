#import "MusanovaKitPrivateSupport.h"

#import <dlfcn.h>
#import <objc/message.h>

static NSString * const MNKActionSignerErrorDomain = @"MusanovaKit.ActionSigner";

static BOOL MNKFail(NSError **error, NSInteger code, NSString *description) {
    if (error) {
        *error = [NSError errorWithDomain:MNKActionSignerErrorDomain
                                     code:code
                                 userInfo:@{NSLocalizedDescriptionKey: description}];
    }
    return NO;
}

BOOL MNKAddAppleMusicActionSignature(NSMutableURLRequest *request, NSError **error) {
    void *handle = dlopen(
        "/System/Library/PrivateFrameworks/AppleMediaServices.framework/AppleMediaServices",
        RTLD_LAZY | RTLD_LOCAL
    );
    if (!handle) {
        return MNKFail(error, 1, @"AppleMediaServices is unavailable on this system.");
    }

    Class mescalClass = NSClassFromString(@"AMSMescal");
    Class decorationClass = NSClassFromString(@"AMSURLRequestDecoration");
    SEL createBagSelector = NSSelectorFromString(@"createBagForSubProfile");
    SEL decorateSelector = NSSelectorFromString(@"addMescalHeaderToRequest:type:bag:logKey:");

    if (!mescalClass || !decorationClass ||
        ![mescalClass respondsToSelector:createBagSelector] ||
        ![decorationClass respondsToSelector:decorateSelector]) {
        return MNKFail(error, 2, @"Apple Music action signing is unavailable on this system.");
    }

    id (*sendNoArguments)(id, SEL) = (void *)objc_msgSend;
    id bag = sendNoArguments(mescalClass, createBagSelector);
    if (!bag) {
        return MNKFail(error, 3, @"Apple Music action signing could not load its configuration.");
    }

    id (*decorate)(id, SEL, id, NSInteger, id, id) = (void *)objc_msgSend;
    id promise = decorate(
        decorationClass,
        decorateSelector,
        request,
        1,
        bag,
        @"MusanovaKit"
    );

    SEL waitSelector = NSSelectorFromString(@"waitUntilFinishedWithTimeout:");
    if (promise && [promise respondsToSelector:waitSelector]) {
        void (*wait)(id, SEL, NSTimeInterval) = (void *)objc_msgSend;
        wait(promise, waitSelector, 30);
    }

    if (![request valueForHTTPHeaderField:@"X-Apple-ActionSignature"].length) {
        return MNKFail(error, 4, @"Apple Music did not produce an action signature.");
    }

    return YES;
}
