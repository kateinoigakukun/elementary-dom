import { JSDOM } from "jsdom"
import { writeFileSync } from "fs"

const dom = new JSDOM(`<html><body></body></html>`);
globalThis.window = dom.window
globalThis.document = dom.window.document
globalThis.requestAnimationFrame = (callback) => {
    setTimeout(() => { callback(0) }, 10)
}

dom.window._virtualConsole.on("jsdomError", (error) => {
    console.error("JSDOM caught an error:", error.message);
    dumpMemory(new Uint8Array(instance.exports.memory.buffer), 0)
    process.exit(1)
});

import { instantiate } from "./Public/lib/swiftle-node/instantiate.js"
import { defaultNodeSetup } from "./Public/lib/swiftle-node/platforms/node.js"

Error.stackTraceLimit = 100

globalThis.handleClickEvent = () => {
    instance.exports.handleClickEvent()
}

function dumpMemory(bytes, start, length = 4096) {
    console.log(`Dumping memory ${start} to ${start + length}`)
    writeFileSync(`.build/memory-${start}-${length}.bin`, Buffer.from(bytes.slice(start, start + length)))
}

const options = await defaultNodeSetup({})
process.on("uncaughtException", (error) => {
    console.error(error)
    if (error instanceof WebAssembly.RuntimeError) {
        dumpMemory(new Uint8Array(instance.exports.memory.buffer), 0)
        process.exit(1)
    }
})
const { instance } = await instantiate({
    ...options,
    addToCoreImports(imports, { getInstance }) {
        imports.env = {
            queueMicrotask: () => {
                globalThis.queueMicrotask(() => {
                    getInstance().exports.handleNextMicrotask()
                })
            }
        }
    }
})
await new Promise(resolve => setTimeout(resolve, 100))

for (let i = 0; i < 200; i++) {
    instance.exports.handleClickEvent()
    await new Promise(resolve => resolve())
}

console.log("NOT REPRODUCIBLE")
dumpMemory(new Uint8Array(instance.exports.memory.buffer), 0)