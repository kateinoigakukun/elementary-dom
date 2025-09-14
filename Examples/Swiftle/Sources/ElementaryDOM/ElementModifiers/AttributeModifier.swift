public final class _AttributeModifier: DOMElementModifier {
    typealias Value = _AttributeStorage

    let upstream: _AttributeModifier?
    private var lastValue: Value

    var value: Value {
        var combined = lastValue
        combined.append(upstream?.value ?? .none)
        return combined
    }

    init(value: consuming Value, upstream: borrowing DOMElementModifiers, _ context: inout _RenderContext) {
        self.lastValue = value
        self.upstream = upstream[_AttributeModifier.key]
    }

    func updateValue(_ value: consuming Value, _ context: inout _RenderContext) {
        if value != lastValue {
            lastValue = value
        }
    }

    func mount(_ node: DOM.Node, _ context: inout _CommitContext) {
        _ = MountedInstance(node, self, &context)
    }
}

extension _AttributeModifier {
    final class MountedInstance {
        let modifier: _AttributeModifier
        let node: DOM.Node

        var isDirty: Bool = false
        var previousValue: _AttributeStorage = .none

        init(_ node: DOM.Node, _ modifier: _AttributeModifier, _ context: inout _CommitContext) {
            self.node = node
            self.modifier = modifier
            updateDOMNode(&context)
        }

        func updateDOMNode(_ context: inout _CommitContext) {
            let newValue = modifier.value
            isDirty = false
            previousValue = newValue
        }
    }
}
