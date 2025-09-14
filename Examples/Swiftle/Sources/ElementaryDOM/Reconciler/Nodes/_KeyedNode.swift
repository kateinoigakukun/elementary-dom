public struct _KeyedNode<ChildNode: _Reconcilable> {
    private var keys: [_ViewKey]
    private var children: [ChildNode?]

    init(keys: [_ViewKey], children: [ChildNode?]) {
        self.keys = keys
        self.children = children
    }

    init(_ value: some Sequence<(key: _ViewKey, node: ChildNode)>, context: inout _RenderContext) {
        self.init(keys: [], children: [])
    }

    init(key: _ViewKey, child: ChildNode, context: inout _RenderContext) {
        self.init(CollectionOfOne((key: key, node: child)), context: &context)
    }

    mutating func patch(
        key: _ViewKey,
        context: inout _RenderContext,
        makeOrPatchNode: (inout ChildNode?, inout _RenderContext) -> Void
    ) {}

    mutating func patch(
        _ newKeys: some BidirectionalCollection<_ViewKey>,
        context: inout _RenderContext,
        makeOrPatchNode: (Int, inout ChildNode?, inout _RenderContext) -> Void
    ) {
        // TODO: add fast-pass for empty key list
        let diff = newKeys.difference(from: keys).inferringMoves()
        keys = Array(newKeys)

        for change in diff {}
    }
}

extension _KeyedNode: _Reconcilable {
    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
    }
}

