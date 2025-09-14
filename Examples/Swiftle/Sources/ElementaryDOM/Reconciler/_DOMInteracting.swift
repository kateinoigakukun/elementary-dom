import JavaScriptKit

// Type-erased node reference
public enum DOM {
    public struct Node {
        let ref: AnyObject
    }

    public struct Event {
        let ref: AnyObject
    }

    public struct EventSink {
        let ref: JSValue
    }
}

extension JSKitDOMInteractor {
    func runNext(_ callback: @escaping () -> Void) {
        queueMicrotask(callback)
    }

    func patchEventListeners(
        _ node: DOM.Node,
        with listers: _DomEventListenerStorage,
        replacing: _DomEventListenerStorage,
    ) {
    }
}
