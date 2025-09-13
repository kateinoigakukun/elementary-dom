extension _HTMLTuple2: View where V0: View, V1: View {}
extension _HTMLTuple2: _Mountable where V0: _Mountable, V1: _Mountable {
    public typealias _MountedNode = _TupleNode2<V0._MountedNode, V1._MountedNode>

    public static func _makeNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        reconciler: inout _RenderContext
    ) -> _MountedNode {
        _MountedNode(
            V0._makeNode(view.v0, context: copy context, reconciler: &reconciler),
            V1._makeNode(view.v1, context: copy context, reconciler: &reconciler)
        )
    }

    public static func _patchNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        node: inout _MountedNode,
        reconciler: inout _RenderContext
    ) {
        V0._patchNode(view.v0, context: copy context, node: &node.value.0, reconciler: &reconciler)
        V1._patchNode(view.v1, context: copy context, node: &node.value.1, reconciler: &reconciler)
    }
}




// Removed generic variadic tuple support - not needed for crash reproduction