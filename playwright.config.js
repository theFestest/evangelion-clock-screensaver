const { defineConfig } = require("@playwright/test");

module.exports = defineConfig({
	testDir: "tests/visual",
	fullyParallel: true,
	use: {
		viewport: { width: 1280, height: 800 },
		deviceScaleFactor: 2
	},
	expect: {
		toHaveScreenshot: {
			maxDiffPixelRatio: 0.002,
			animations: "disabled"
		}
	}
});
