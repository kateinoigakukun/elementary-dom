public final class _ElementNode<ChildNode>: _Reconcilable where ChildNode: _Reconcilable & ~Copyable {
    public struct Value {
        let tagName: String
        var listerners: _DomEventListenerStorage
        var modifiers: [any DOMElementModifier]
    }

    var value: Value
    var child: ChildNode!

    var domNode: ManagedDOMReference?

    var eventSink: DOM.EventSink?

    let scheduler: Scheduler  // TODO: maybe find a way to not hold on to this

    init(value: Value, context: inout _RenderContext, makeChild: (inout _RenderContext) -> ChildNode) {
        self.value = value
        self.scheduler = context.scheduler

        context.commitPlan.addNodeAction(CommitAction(run: createDOMNode(_:)))
        context.withCurrentLayoutContainer {
            self.child = makeChild(&$0)
        }
    }

    init(
        root: DOM.Node,
        context: inout _RenderContext,
        makeChild: (inout _RenderContext) -> ChildNode
    ) {
        self.domNode = .init(reference: root)
        self.value = .init(tagName: "<root>", listerners: .none, modifiers: .init())
        self.eventSink = nil
        self.scheduler = context.scheduler

        context.withCurrentLayoutContainer { context in
            self.child = makeChild(&context)
        }
    }

    func patch(_ newValue: Value, context: inout _RenderContext, patchChild: (inout ChildNode, inout _RenderContext) -> Void) {
        guard let ref = domNode?.reference else {
            preconditionFailure("unitialized element in patch - maybe this can be fine?")
        }

        let oldValue = value

        context.commitPlan.addNodeAction(
            CommitAction { [ref, oldValue, eventSink] context in

                if let eventSink {
                    context.dom.patchEventListeners(
                        ref,
                        with: newValue.listerners,
                        replacing: oldValue.listerners,
                    )
                }
            }
        )

        self.value = newValue
    }

    func createDOMNode(_ context: inout _CommitContext) {
        let ref = context.dom.createElement(value.tagName)
        self.domNode = ManagedDOMReference(reference: ref)

        g_handleClickEvent = { [weak self] in
            self?.value.listerners.handleEvent()
        }
    }

    public func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {}
}
