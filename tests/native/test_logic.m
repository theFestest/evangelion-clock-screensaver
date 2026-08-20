// Unit tests for the pure display-selection logic.
// Run via tests/native/run.sh; exits non-zero on any failure.
#import <Foundation/Foundation.h>
#import "EvangelionClockLogic.h"

static int failures = 0;

#define CHECK(cond, desc) do { \
	if (!(cond)) { \
		fprintf(stderr, "FAIL: %s\n", desc); \
		failures++; \
	} else { \
		fprintf(stdout, "ok: %s\n", desc); \
	} \
} while (0)

int main(void) {
	@autoreleasepool {
		// Style option -> webview HTML resource path.
		CHECK([EVAStyleHTMLPath(0) isEqualToString:@"/Webview/style-normal-3d.html"], "style 0 is normal 3d");
		CHECK([EVAStyleHTMLPath(1) isEqualToString:@"/Webview/style-red-3d.html"], "style 1 is red 3d");
		CHECK([EVAStyleHTMLPath(2) isEqualToString:@"/Webview/style-normal.html"], "style 2 is normal flat");
		CHECK([EVAStyleHTMLPath(3) isEqualToString:@"/Webview/style-red.html"], "style 3 is red flat");
		CHECK([EVAStyleHTMLPath(4) isEqualToString:@"/Webview/style-normal-3d.html"], "out-of-range style falls back to normal 3d");
		CHECK([EVAStyleHTMLPath(-1) isEqualToString:@"/Webview/style-normal-3d.html"], "negative style falls back to normal 3d");

		// Screen display option 0: primary screen only (or preview).
		CHECK(EVAShouldAttachToScreen(0, NO, 0, 0, 1440), "option 0 attaches on primary screen");
		CHECK(!EVAShouldAttachToScreen(0, NO, 1440, 0, 1440), "option 0 skips non-primary screen");
		CHECK(EVAShouldAttachToScreen(0, YES, 1440, 0, 1440), "option 0 always attaches in preview");

		// Screen display option 1: last focussed (main) screen only (or preview).
		CHECK(EVAShouldAttachToScreen(1, NO, 1440, 0, 1440), "option 1 attaches on main screen");
		CHECK(!EVAShouldAttachToScreen(1, NO, 0, 0, 1440), "option 1 skips non-main screen");
		CHECK(EVAShouldAttachToScreen(1, YES, 0, 0, 1440), "option 1 always attaches in preview");

		// Screen display option 2: all screens.
		CHECK(EVAShouldAttachToScreen(2, NO, 0, 0, 1440), "option 2 attaches on primary screen");
		CHECK(EVAShouldAttachToScreen(2, NO, 1440, 0, 1440), "option 2 attaches on secondary screen");

		// Unknown options attach everywhere.
		CHECK(EVAShouldAttachToScreen(99, NO, 1440, 0, 0), "unknown option attaches everywhere");

		// Self-exit on screensaver stop: works around legacyScreenSaver
		// (macOS 14+) never destroying instances. Never in preview; never
		// on systems where stopAnimation still works.
		CHECK(EVAShouldExitOnScreenSaverStop(NO, 14), "exits on stop on macOS 14");
		CHECK(EVAShouldExitOnScreenSaverStop(NO, 26), "exits on stop on macOS 26");
		CHECK(!EVAShouldExitOnScreenSaverStop(YES, 26), "never exits in preview");
		CHECK(!EVAShouldExitOnScreenSaverStop(NO, 13), "keeps stock behavior before macOS 14");

		if (failures) {
			fprintf(stderr, "%d test(s) failed\n", failures);
			return 1;
		}
		fprintf(stdout, "all tests passed\n");
		return 0;
	}
}
