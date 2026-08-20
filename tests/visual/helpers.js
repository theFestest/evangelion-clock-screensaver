"use strict";

const path = require("path");
const { pathToFileURL } = require("url");

// A time of day on a fixed date, in UTC to match the pinned timezoneId.
function utcTime(hours, minutes, seconds) {
	return new Date(Date.UTC(2015, 8, 13, hours, minutes, seconds));
}

// Freeze the clock at `time`, load a generated webview variant, and wait for
// fonts and a paint so the render is stable.
async function loadStyle(page, style, time) {
	await page.clock.install({ time });
	const file = path.resolve(__dirname, "../../Resources/Webview", style + ".html");
	await page.goto(pathToFileURL(file).href + "?screensaver=1");
	await page.evaluate(() => document.fonts.ready);
	await page.evaluate(() => new Promise(requestAnimationFrame));
}

module.exports = { loadStyle, utcTime };
