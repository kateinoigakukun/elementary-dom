// FIXME:NONCOPYABLE this should be ~Copyable once associatedtype is supported (will be fun to implement a noncopyable version of this ; )
public struct _KeyedNode<ChildNode: _Reconcilable> {
    private var keys: [_ViewKey]
    private var children: [ChildNode?]

    init(keys: [_ViewKey], children: [ChildNode?]) {
        assert(keys.count == children.count)
        self.keys = keys
        self.children = children
    }

    init(_ value: some Sequence<(key: _ViewKey, node: ChildNode)>, context: inout _RenderContext) {
        var keys = [_ViewKey]()
        var children = [ChildNode?]()

        keys.reserveCapacity(value.underestimatedCount)
        children.reserveCapacity(value.underestimatedCount)

        for entry in value {
            keys.append(entry.key)
            children.append(entry.node)
        }

        self.init(keys: keys, children: children)
    }

    init(key: _ViewKey, child: ChildNode, context: inout _RenderContext) {
        self.init(CollectionOfOne((key: key, node: child)), context: &context)
    }

    mutating func patch(
        key: _ViewKey,
        context: inout _RenderContext,
        makeOrPatchNode: (inout ChildNode?, inout _RenderContext) -> Void
    ) {
        patch(
            CollectionOfOne(key),
            context: &context,
            makeOrPatchNode: { _, node, r in makeOrPatchNode(&node, &r) }
        )
    }

    mutating func patch(
        _ newKeys: some BidirectionalCollection<_ViewKey>,
        context: inout _RenderContext,
        makeOrPatchNode: (Int, inout ChildNode?, inout _RenderContext) -> Void
    ) {
        // TODO: add fast-pass for empty key list
        let diff = newKeys.difference(from: keys).inferringMoves()
        keys = Array(newKeys)

        if !diff.isEmpty {
            var moversCache: [Int: ChildNode] = [:]

            // is there a way to completely do this in-place?
            // is there a way to do this more sub-rangy?
            // anyway, this way the "move" case is a bit worse, but the rest is in place

            for change in diff {
                switch change {
                case let .remove(offset, element: _, associatedWith: movedTo):
                    guard var node = children.remove(at: offset) else {
                        fatalError("unexpected nil child on collection")
                    }

                    if movedTo != nil {
                        node.apply(.markAsMoved, &context)
                        moversCache[offset] = consume node
                    } else {
                        node.apply(.startRemoval, &context)
                        context.parentElement?.reportChangedChildren(.elementChanged, &context)
                    }
                case let .insert(offset, element: key, associatedWith: movedFrom):
                    var node: ChildNode? = nil

                    if let movedFrom {
                        logTrace("move \(key) from \(movedFrom) to \(offset)")
                        node = moversCache.removeValue(forKey: movedFrom)
                        precondition(node != nil, "mover not found in cache")
                    }

                    children.insert(node, at: offset)
                }
            }
            precondition(moversCache.isEmpty, "mover cache is not empty")
        }

        // run update / patch functions on all nodes
        for index in children.indices {
            makeOrPatchNode(index, &children[index], &context)
            assert(children[index] != nil, "unexpected nil child on collection")
        }
    }
}

extension _KeyedNode: _Reconcilable {
    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
        for index in children.indices {
            children[index]?.apply(op, &reconciler)
        }
    }

    public mutating func collectChildren(_ ops: inout ContainerLayoutPass, _ context: inout _CommitContext) {
        for cIndex in children.indices {
            precondition(children[cIndex] != nil, "unexpected nil child on collection")
            children[cIndex]!.collectChildren(&ops, &context)
        }
    }

    public consuming func unmount(_ context: inout _CommitContext) {
        for index in children.indices {
            children[index]?.unmount(&context)
        }

        children.removeAll()
    }
}

