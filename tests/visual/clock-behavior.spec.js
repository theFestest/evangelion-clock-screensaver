"use strict";

const { test, expect } = require("@playwright/test");
const { loadStyle, utcTime } = require("./helpers");

// DOM-level checks of the digit mapping: no screenshots, so times are cheap.
// Together the cases exercise every glyph 0-9, every zero-padding branch
// (hour, minute, second), and the day boundaries.
const CASES = [
	{ name: "midnight", time: utcTime(0, 0, 0), digits: "000000" },
	{ name: "all positions padded", time: utcTime(9, 5, 3), digits: "090503" },
	{ name: "end of day", time: utcTime(23, 59, 59), digits: "235959" },
	{ name: "ascending digits", time: utcTime(12, 34, 56), digits: "123456" },
	{ name: "remaining glyphs", time: utcTime(17, 48, 8), digits: "174808" }
];

async function expectDigits(page, digits) {
	for (let i = 0; i < 6; i++) {
		await expect(page.locator(`#clock-digit-${i + 1} tspan`)).toHaveText(digits[i]);
	}
}

for (const { name, time, digits } of CASES) {
	test(`shows ${digits} at ${name}`, async ({ page }) => {
		await loadStyle(page, "style-normal", time);
		await expectDigits(page, digits);
	});
}

test("ticks across a minute rollover", async ({ page }) => {
	await loadStyle(page, "style-normal", utcTime(20, 15, 59));
	await expectDigits(page, "201559");
	await page.clock.runFor(1000);
	await expectDigits(page, "201600");
});
