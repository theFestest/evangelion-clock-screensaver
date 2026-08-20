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
