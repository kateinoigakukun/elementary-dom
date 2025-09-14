// TODO: figure this out
enum _ThreadLocal {
    nonisolated(unsafe) static var value: UnsafeMutableRawPointer?
}

final class MutexBox<State>: @unchecked Sendable {
    private var state: State

    init(_ state: sending State) {
        self.state = state
    }

    func withLock<Result>(_ body: (inout sending State) -> sending Result) -> sending Result {
        body(&state)
    }

    var id: ObjectIdentifier { ObjectIdentifier(self) }
}