struct Context {
    var value = 1
    func doSomething() {}
}

protocol P {
    associatedtype Content
    var content: Content { get }
    static func _makeNode(_ view: Self)
}

struct EmptyElement: P {
    var content: Void {}
    static func _makeNode(_ view: Self) {}
}

struct KeyboardLetterView: P {
    var onKeyPressed: () -> Void
    var content: EmptyElement {
        EmptyElement()
    }
    static func _makeNode(_ view: Self) {}
}

final class _FunctionNode<Value> where Value: P, Value.Content: P {
    let value: Value?

    init(value: Value) {
        self.value = value
    }

    func runFunction() {
        if let value = value {
            Value.Content._makeNode(value.content)
        }
    }
}

public func entry() {
    let context = Context()
    let childNode = _FunctionNode(
        value: KeyboardLetterView(onKeyPressed: context.doSomething),
    )
    childNode.runFunction()
    childNode.runFunction()
}

@_expose(wasm, "mount")
@_cdecl("mount")
func mount() {
    entry()
}
