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
    dumpMemory(0)
    process.exit(1)
});

import { instantiate } from "./Public/lib/swiftle-node/instantiate.js"
import { defaultNodeSetup } from "./Public/lib/swiftle-node/platforms/node.js"

Error.stackTraceLimit = 100

function dumpMemory(start, length = 4096) {
    const bytes = new Uint8Array(globalThis.INSTANCE.exports.memory.buffer)
    console.log(`Dumping memory ${start} to ${start + length}`)
    writeFileSync(`.build/memory-${start}-${length}.bin`, Buffer.from(bytes.slice(start, start + length)))
}

const options = await defaultNodeSetup({})
const { instance } = await instantiate({
    ...options,
    instrumentInstance(instance, { _swift }) {
        globalThis.INSTANCE = instance
        return instance
    },
    addToCoreImports(imports, { getInstance }) {
        imports["wasi_snapshot_preview1"]["proc_exit"] = (code) => {
            console.error("proc_exit", code, new Error().stack)
            dumpMemory(0)
            process.exit(1)
        };
    }
})

instance.exports.mount()