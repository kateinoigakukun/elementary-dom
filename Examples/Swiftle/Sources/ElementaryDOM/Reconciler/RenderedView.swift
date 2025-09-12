import Elementary

public enum _LifecycleHook {
    case onMount(() -> Void)
    case onUnmount(() -> Void)
    case onMountReturningCancelFunction(() -> () -> Void)
    case __none
}

struct DOMEventListener {
    let event: String
    let handler: () -> Void
}

struct _DomEventListenerStorage {
    static var none: Self { _DomEventListenerStorage() }
    // TODO: fix typing
    var listeners: [DOMEventListener] = []

    // TODO: figure out how to a) do not use runtime reflection, b) do not drag JSKit dependency into app code, and c) provide extensible but typed event handling system
    func handleEvent() {
        for listener in listeners {
            listener.handler()
        }
    }
}

public struct _DomTranstionHooks {

}
