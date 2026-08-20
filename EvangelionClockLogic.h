#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

// Resource path (relative to the bundle resource directory) of the webview
// HTML file for a style preference index. Unknown indices fall back to the
// default style.
NSString *EVAStyleHTMLPath(NSInteger styleOption);

// Whether the screensaver view for the screen whose frame starts at
// frameOriginX should show the clock, given the screen display preference.
// Option 0 targets the primary screen, option 1 the last focussed (main)
// screen, option 2 and unknown values every screen. Previews always show it.
BOOL EVAShouldAttachToScreen(NSInteger screenDisplayOption,
							 BOOL isPreview,
							 CGFloat frameOriginX,
							 CGFloat primaryScreenOriginX,
							 CGFloat mainScreenOriginX);

// Whether the hosting process should exit when the screensaver stops.
// Since macOS 14 the legacyScreenSaver host neither destroys
// ScreenSaverView instances nor reliably delivers stopAnimation, so
// instances (and their memory) pile up across activations; exiting lets
// macOS respawn a fresh host next time. Never exit in preview (that would
// kill System Settings' extension host), and keep stock behavior on
// systems whose host still stops correctly.
BOOL EVAShouldExitOnScreenSaverStop(BOOL isPreview, NSInteger osMajorVersion);
