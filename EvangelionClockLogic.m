#import "EvangelionClockLogic.h"

NSString *EVAStyleHTMLPath(NSInteger styleOption) {
	switch (styleOption) {
		case 0:
			return @"/Webview/style-normal-3d.html";
		case 1:
			return @"/Webview/style-red-3d.html";
		case 2:
			return @"/Webview/style-normal.html";
		case 3:
			return @"/Webview/style-red.html";
		default:
			return @"/Webview/style-normal-3d.html";
	}
}

BOOL EVAShouldAttachToScreen(NSInteger screenDisplayOption,
							 BOOL isPreview,
							 CGFloat frameOriginX,
							 CGFloat primaryScreenOriginX,
							 CGFloat mainScreenOriginX) {
	if (isPreview) {
		return YES;
	}
	switch (screenDisplayOption) {
		case 0:
			return primaryScreenOriginX == frameOriginX;
		case 1:
			return mainScreenOriginX == frameOriginX;
		default:
			return YES;
	}
}

BOOL EVAShouldExitOnScreenSaverStop(BOOL isPreview, NSInteger osMajorVersion) {
	return !isPreview && osMajorVersion >= 14;
}
