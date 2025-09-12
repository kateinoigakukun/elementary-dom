import { JSDOM } from "jsdom"

const dom = new JSDOM()
globalThis.window = dom.window
globalThis.document = dom.window.document
globalThis.requestAnimationFrame = (callback) => {
    setTimeout(() => { callback(0) }, 10)
}

import { instantiate } from "./Public/lib/swiftle/instantiate.js"
import { defaultNodeSetup } from "./Public/lib/swiftle/platforms/node.js"

await instantiate(await defaultNodeSetup({}))