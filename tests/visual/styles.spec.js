"use strict";

const { test, expect } = require("@playwright/test");
const path = require("path");

// Every generated variant: both colorways x both perspectives.
const STYLES = [
	"style-normal",
	"style-normal-3d",
	"style-red",
	"style-red-3d"
];

// Frozen clock so the digits are deterministic: renders as 20:15:00.
const FIXED_TIME = new Date(2015, 8, 13, 20, 15, 0);

for (const style of STYLES) {
	test(style, async ({ page }) => {
		await page.clock.install({ time: FIXED_TIME });
		const file = path.resolve(__dirname, "../../Resources/Webview", style + ".html");
		await page.goto("file://" + file + "?screensaver=1");
		await page.evaluate(() => document.fonts.ready);
		await page.evaluate(() => new Promise(requestAnimationFrame));
		await expect(page).toHaveScreenshot(style + ".png");
	});
}
