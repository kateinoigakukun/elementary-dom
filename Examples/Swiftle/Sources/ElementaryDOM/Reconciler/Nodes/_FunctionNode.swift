public final class _FunctionNode<Value, ChildNode>
where Value: __FunctionView, ChildNode: _Reconcilable, ChildNode == Value.Content._MountedNode {
    private var state: Value.__ViewState?
    private var value: Value?
    private var context: _ViewContext?

    public var depthInTree: Int

    var asFunctionNode: AnyFunctionNode!

    var child: Value.Content._MountedNode?

    init(
        value: consuming Value,
        context: consuming _ViewContext,
        reconciler: inout _RenderContext
    ) {
        self.depthInTree = reconciler.depth

        // TODO: track environment access
        self.state = Value.__initializeState(from: value)
        Value.__applyContext(context, to: &value)
        Value.__restoreState(state!, in: &value)
        self.value = value
        self.context = context

        self.asFunctionNode = AnyFunctionNode(self)

        // we need to break here for scoped reactivity tracking
        reconciler.addFunction(asFunctionNode)
    }

    func patch(_ value: consuming Value, _ viewContext: consuming _ViewContext, context: inout _RenderContext) {
        let needsRerender = !Value.__areEqual(a: value, b: self.value!)

        // NOTE: the idea is that way always store a "wired-up" value, so that we can re-run the function for free
        Value.__applyContext(viewContext, to: &value)
        Value.__restoreState(state!, in: &value)
        self.value = value
        self.context = viewContext

        if needsRerender {
            context.addFunction(asFunctionNode)
        }
    }

    func runFunction(reconciler: inout _RenderContext) {
        reconciler.depth = depthInTree + 1
        reconciler.withCurrentLayoutContainer { reconciler in
            withReactiveTracking {
                if child == nil {
                    self.child = Value.Content._makeNode(self.value!.content, context: context!, reconciler: &reconciler)
                } else {
                    Value.Content._patchNode(self.value!.content, context: context!, node: &child!, reconciler: &reconciler)
                }
            } onChange: { [scheduler = reconciler.scheduler, asFunctionNode = asFunctionNode!] in
                scheduler.scheduleFunction(asFunctionNode)
            }
        }
    }
}

extension _FunctionNode: _Reconcilable {

    public func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
        child?.apply(op, &reconciler)
    }
}

extension AnyFunctionNode {
    init(_ function: _FunctionNode<some __FunctionView, some _Reconcilable>) {
        self.identifier = ObjectIdentifier(function)
        self.depthInTree = function.depthInTree
        self.runUpdate = function.runFunction
    }
}
