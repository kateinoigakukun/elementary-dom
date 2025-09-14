struct DOMEventListener {
    let event: String
    let handler: () -> Void
}

struct _DomEventListenerStorage {
    static var none: Self { _DomEventListenerStorage() }
    // TODO: fix typing
    var listeners: [DOMEventListener] = []

    func handleEvent() {
        for listener in listeners {
            listener.handler()
        }
    }
}
