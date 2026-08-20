// Posts the distributed notification legacyScreenSaver sends when the
// screensaver is stopping, for exercising the self-exit path without the
// real lock/unlock flow. Build: clang -fobjc-arc -framework Foundation
// -o post-willstop post-willstop.m
#import <Foundation/Foundation.h>

int main(void) {
	@autoreleasepool {
		[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.apple.screensaver.willstop"
						  object:nil
						userInfo:nil
			  deliverImmediately:YES];
		// Give the runloop a beat to actually send it before exiting.
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	}
	return 0;
}
