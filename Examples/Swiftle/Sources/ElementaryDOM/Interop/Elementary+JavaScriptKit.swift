import Elementary
import JavaScriptKit

extension DOM.Node {
    init(_ node: JSObject) { self.init(ref: node) }
    var jsObject: JSObject { ref as! JSObject }
}

extension DOM.Event {
    init(_ event: JSObject) { self.init(ref: event) }
    var jsObject: JSObject { ref as! JSObject }
}

extension DOM.PropertyValue {
    var jsValue: JSValue {
        switch self {
        case let .string(value):
            return value.jsValue
        case let .number(value):
            return value.jsValue
        case let .boolean(value):
            return value.jsValue
        case let .stringArray(value):
            return value.jsValue
        case .null:
            return .null
        case .undefined:
            return .undefined
        }
    }

    init?(_ jsValue: JSValue) {
        switch jsValue {
        case let .string(value):
            self = .string(value.description)
        case let .number(value):
            self = .number(value)
        case let .boolean(value):
            self = .boolean(value)
        case .object:
            // JSArray removed, just return nil for objects
            return nil
        case .null:
            self = .null
        case .undefined:
            self = .undefined
        default:
            return nil
        }
    }
}

nonisolated(unsafe) var g_handleClickEvent: () -> Void = {}
@_expose(wasm, "handleClickEvent")
func handleClickEvent() {
    g_handleClickEvent()
}

final class JSKitDOMInteractor: DOM.Interactor {
    private let document = JSObject.global.document
    private let setTimeout = JSObject.global.setTimeout.function!

    let root: DOM.Node

    init(root: JSObject) {
        self.root = .init(root)
    }

    func makeEventSink(_ handler: @escaping () -> Void) -> DOM.EventSink {
        g_handleClickEvent = handler
        return .init(ref: JSObject.global.handleClickEvent)
    }

    func createText(_ text: String) -> DOM.Node {
        .init(document.createTextNode(text).object!)
    }

    func createElement(_ element: String) -> DOM.Node {
        .init(document.createElement(element).object!)
    }

    // Low-level DOM-like operations used by protocol extensions
    func setAttribute(_ node: DOM.Node, name: String, value: String?) {
        _ = node.jsObject.setAttribute!(name.jsValue, value.jsValue)
    }

    func removeAttribute(_ node: DOM.Node, name: String) {
        _ = node.jsObject.removeAttribute!(name)
    }

    func addEventListener(_ node: DOM.Node, event: String, sink: DOM.EventSink) {
        _ = node.jsObject.addEventListener!(event.jsValue, sink.ref)
    }

    func removeEventListener(_ node: DOM.Node, event: String, sink: DOM.EventSink) {
        _ = node.jsObject.removeEventListener!(event.jsValue, sink.ref)
    }

    func patchText(_ node: DOM.Node, with text: String) {
        _ = node.jsObject.textContent = text.jsValue
    }

    func replaceChildren(_ children: [DOM.Node], in parent: DOM.Node) {
        logTrace("setting \(children.count) children in \(parent)")
        let function = parent.jsObject.replaceChildren.function!
        function.callAsFunction(
            this: parent.jsObject,
            arguments: children.map { $0.jsObject.jsValue }
        )
    }

    func insertChild(_ child: DOM.Node, before sibling: DOM.Node?, in parent: DOM.Node) {
        if let s = sibling {
            _ = parent.jsObject.insertBefore!(child.jsObject.jsValue, s.jsObject.jsValue)
        } else {
            _ = parent.jsObject.appendChild!(child.jsObject.jsValue)
        }
    }

    func removeChild(_ child: DOM.Node, from parent: DOM.Node) {
        _ = parent.jsObject.removeChild!(child.jsObject.jsValue)
    }

    func requestAnimationFrame(_ callback: @escaping (Double) -> Void) {
        queueMicrotask {
            callback(0)
        }
    }

    func queueMicrotask(_ callback: @escaping () -> Void) {
        g_microtaskCallbacks.append(callback)
        _queueMicrotask()
    }
}

@_extern(c)
@_extern(wasm, module: "env", name: "queueMicrotask")
func _queueMicrotask()

nonisolated(unsafe) var g_microtaskCallbacks: [() -> Void] = []
@_expose(wasm, "handleNextMicrotask")
func handleNextMicrotask() {
    if let callback = g_microtaskCallbacks.first {
        g_microtaskCallbacks.removeFirst()
        callback()
    }
}