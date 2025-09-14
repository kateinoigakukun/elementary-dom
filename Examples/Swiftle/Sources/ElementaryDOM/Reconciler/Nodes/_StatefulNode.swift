public struct _StatefulNode<State, Child: _Reconcilable> {
    var state: State
    var child: Child
    var onUnmount: ((inout _CommitContext) -> Void)?

    init(state: State, child: Child) {
        self.state = state
        self.child = child
    }

}

extension _StatefulNode: _Reconcilable {
    public mutating func apply(_ op: _ReconcileOp, _ reconciler: inout _RenderContext) {
        child.apply(op, &reconciler)
    }
}
