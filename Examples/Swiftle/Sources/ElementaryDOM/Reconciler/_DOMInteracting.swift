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
        sink: DOM.EventSink
    ) {
        guard !(listers.listeners.isEmpty && replacing.listeners.isEmpty) else { return }

        var previous = replacing.listeners.map { $0.event }

        for event in listers.listeners.map({ $0.event }) {
            let previousIndex = previous.firstIndex { $0.utf8Equals(event) }
            if let previousIndex {
                previous.remove(at: previousIndex)
            } else {
                addEventListener(node, event: event, sink: sink)
            }
        }
    }
}
