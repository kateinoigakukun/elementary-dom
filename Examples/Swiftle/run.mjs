import { JSDOM } from "jsdom"

const dom = new JSDOM(`<html><body></body></html>`);
globalThis.window = dom.window
globalThis.document = dom.window.document
globalThis.requestAnimationFrame = (callback) => {
    setTimeout(() => { callback(0) }, 10)
}

import { instantiate } from "./Public/lib/swiftle-node/instantiate.js"
import { defaultNodeSetup } from "./Public/lib/swiftle-node/platforms/node.js"

await instantiate(await defaultNodeSetup({}))

const document = dom.window.document

await new Promise(resolve => setTimeout(resolve, 100))

const buttons = {}
for (const button of document.getElementsByTagName("button")) {
    buttons[button.children[0].textContent] = button
}

while (true) {
    buttons["S"].click()
    await new Promise(resolve => setTimeout(resolve, 100))
}