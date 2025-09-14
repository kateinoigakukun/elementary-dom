public protocol _Reconcilable: ~Copyable {
    mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext)
}

public enum _ReconcileOp {
    case startRemoval
}

public struct _EmptyNode: _Reconcilable {
    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {}
}
