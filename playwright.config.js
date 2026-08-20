const { defineConfig } = require("@playwright/test");

module.exports = defineConfig({
	testDir: "tests/visual",
	fullyParallel: true,
	use: {
		viewport: { width: 1280, height: 800 },
		deviceScaleFactor: 2,
		// Frozen test times are constructed with Date.UTC; pinning the
		// browser timezone makes the rendered digits machine-independent.
		timezoneId: "UTC"
	},
	expect: {
		toHaveScreenshot: {
			maxDiffPixelRatio: 0.002,
			animations: "disabled"
		}
	}
});
