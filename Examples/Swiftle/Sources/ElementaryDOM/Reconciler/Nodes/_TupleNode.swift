public struct _TupleNode<each N: _Reconcilable>: _Reconcilable {
    var value: (repeat each N)

    init(_ value: repeat each N) {
        self.value = (repeat each value)
    }

    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
        for var value in repeat each value {
            value.apply(op, &reconciler)
        }
    }
}

public struct _TupleNode2<N0: _Reconcilable, N1: _Reconcilable>: _Reconcilable {
    var value: (N0, N1)

    init(_ n0: N0, _ n1: N1) {
        self.value = (n0, n1)
    }

    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
        value.0.apply(op, &reconciler)
        value.1.apply(op, &reconciler)
    }
}


