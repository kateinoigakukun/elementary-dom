// FIXME:NONCOPYABLE tuples currently do not support ~Copyable
public struct _TupleNode<each N: _Reconcilable>: _Reconcilable {
    var value: (repeat each N)

    init(_ value: repeat each N) {
        self.value = (repeat each value)
    }

    public mutating func collectChildren(_ ops: inout ContainerLayoutPass, _ context: inout _CommitContext) {
        for var value in repeat each value {
            value.collectChildren(&ops, &context)
        }
    }

    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
        for var value in repeat each value {
            value.apply(op, &reconciler)
        }
    }

    public consuming func unmount(_ context: inout _CommitContext) {
        for value in repeat each value {
            value.unmount(&context)
        }
    }
}

public struct _TupleNode2<N0: _Reconcilable, N1: _Reconcilable>: _Reconcilable {
    var value: (N0, N1)

    init(_ n0: N0, _ n1: N1) {
        self.value = (n0, n1)
    }

    public mutating func collectChildren(_ ops: inout ContainerLayoutPass, _ context: inout _CommitContext) {
        value.0.collectChildren(&ops, &context)
        value.1.collectChildren(&ops, &context)
    }

    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
        value.0.apply(op, &reconciler)
        value.1.apply(op, &reconciler)
    }

    public consuming func unmount(_ context: inout _CommitContext) {
        value.0.unmount(&context)
        value.1.unmount(&context)
    }
}


