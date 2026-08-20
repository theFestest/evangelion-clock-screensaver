"use strict";

const { test, expect } = require("@playwright/test");
const { loadStyle, utcTime } = require("./helpers");

// Every generated variant: both colorways x both perspectives.
const STYLES = [
	"style-normal",
	"style-normal-3d",
	"style-red",
	"style-red-3d"
];

// Frozen clock so the digits are deterministic: renders as 20:15:00.
const FIXED_TIME = utcTime(20, 15, 0);

for (const style of STYLES) {
	test(style, async ({ page }) => {
		await loadStyle(page, style, FIXED_TIME);
		await expect(page).toHaveScreenshot(style + ".png");
	});
}

// The canonical time only renders the glyphs 0, 1, 2 and 5. These two times
// cover all ten DS-Digital digit glyphs between them, so a font or SVG text
// regression on any glyph shape shows up in a golden.
const GLYPH_TIMES = [
	{ name: "glyphs-08-04-37", time: utcTime(8, 4, 37) },
	{ name: "glyphs-16-29-45", time: utcTime(16, 29, 45) }
];

for (const { name, time } of GLYPH_TIMES) {
	test(name, async ({ page }) => {
		await loadStyle(page, "style-normal", time);
		await expect(page).toHaveScreenshot(name + ".png");
	});
}

// The default goldens are 16:10; this pins the scaling/letterboxing CSS at a
// different aspect ratio.
test.describe("wide viewport", () => {
	test.use({ viewport: { width: 1920, height: 1080 } });

	test("style-normal-3d-wide", async ({ page }) => {
		await loadStyle(page, "style-normal-3d", FIXED_TIME);
		await expect(page).toHaveScreenshot("style-normal-3d-wide.png");
	});
});
