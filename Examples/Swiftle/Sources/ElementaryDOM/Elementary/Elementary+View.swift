// TODO: maybe this should not derive from HTML at all, or maybe HTML should already be "View" and _Mountable is an extra requirement for mounting?
// TODO: think about how the square MainActor-isolation with server side usage
public protocol View: HTML & _Mountable where Content: HTML & _Mountable {
}

public protocol _Mountable {
    associatedtype _MountedNode: _Reconcilable

    static func _makeNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        reconciler: inout _RenderContext
    ) -> _MountedNode

    static func _patchNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        node: inout _MountedNode,
        reconciler: inout _RenderContext
    )
}

public extension View where Content == Never {
    var content: Content {
        fatalError("This should never be called")
    }
}

extension Never: _Mountable {
    public typealias _MountedNode = _EmptyNode

    public static func _makeNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        reconciler: inout _RenderContext
    ) -> _MountedNode {
        fatalError("This should never be called")
    }

    public static func _patchNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        node: inout _MountedNode,
        reconciler: inout _RenderContext
    ) {}
}

// TODO: does this need to be extra?
public struct _ViewContext {
    // TODO: get red of this
    var eventListeners: _DomEventListenerStorage = .init()

    var modifiers: DOMElementModifiers = .init()

    mutating func takeListeners() -> _DomEventListenerStorage {
        let listeners = eventListeners
        eventListeners = .init()
        return listeners
    }

    mutating func takeModifiers() -> [any DOMElementModifier] {
        modifiers.takeModifiers()
    }

    public static var empty: Self {
        .init()
    }
}

extension HTMLElement: _Mountable, View where Content: _Mountable {
    public typealias _MountedNode = _StatefulNode<_AttributeModifier, _ElementNode<Content._MountedNode>>

    private static func makeValue(_ view: borrowing Self, context: inout _ViewContext) -> _ElementNode<Content._MountedNode>.Value {
        .init(
            tagName: Tag.name,
            listerners: context.takeListeners(),
            modifiers: context.takeModifiers()
        )
    }

    public static func _makeNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        reconciler: inout _RenderContext
    ) -> _MountedNode {
        let attributeModifier = _AttributeModifier(value: view._attributes, upstream: context.modifiers, &reconciler)
        context.modifiers[_AttributeModifier.key] = attributeModifier

        let value = makeValue(view, context: &context)
        assert(context.modifiers.isEmpty)

        return _MountedNode(
            state: attributeModifier,
            child: _ElementNode(
                value: value,
                context: &reconciler,
                makeChild: { [context] r in Content._makeNode(view.content, context: context, reconciler: &r) }
            )
        )
    }

    public static func _patchNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        node: inout _MountedNode,
        reconciler: inout _RenderContext
    ) {
        node.state.updateValue(view._attributes, &reconciler)
        context.modifiers[_AttributeModifier.key] = node.state

        let value = makeValue(view, context: &context)

        node.child.patch(
            value,
            context: &reconciler,
            patchChild: { [context] child, r in
                Content._patchNode(
                    view.content,
                    context: context,
                    node: &child,
                    reconciler: &r
                )
            }
        )
    }
}

extension HTMLText: _Mountable, View {
    public typealias _MountedNode = _TextNode

    public static func _makeNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        reconciler: inout _RenderContext
    ) -> _MountedNode {
        _MountedNode(view.text, context: &reconciler)
    }

    public static func _patchNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        node: inout _MountedNode,
        reconciler: inout _RenderContext
    ) {
        node.patch(view.text, context: &reconciler)
    }
}


extension _HTMLArray: _Mountable, View where Element: View {
    public typealias _MountedNode = _KeyedNode<Element._MountedNode>

    public static func _makeNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        reconciler: inout _RenderContext
    ) -> _MountedNode {
        _MountedNode(
            view.value.enumerated().map { [context] (index, element) in
                (
                    key: _ViewKey(String(index)),
                    node: Element._makeNode(element, context: context, reconciler: &reconciler)
                )
            },
            context: &reconciler
        )
    }

    public static func _patchNode(
        _ view: consuming Self,
        context: consuming _ViewContext,
        node: inout _MountedNode,
        reconciler: inout _RenderContext
    ) {
        // maybe we can optimize this
        // NOTE: written with cast for this https://github.com/swiftlang/swift/issues/83895
        let indexes = view.value.indices.map { _ViewKey(String($0 as Int)) }

        node.patch(
            indexes,
            context: &reconciler,
            makeOrPatchNode: { [context] index, node, r in
                if node == nil {
                    node = Element._makeNode(view.value[index], context: context, reconciler: &r)
                } else {
                    Element._patchNode(view.value[index], context: context, node: &node!, reconciler: &r)
                }
            }
        )

    }
}

public extension View {
    static func __applyContext(_ context: borrowing _ViewContext, to view: inout Self) {
        print("ERROR: Unsupported view type \(Self.self) encountered. Please make sure to use @View on all custom views.")
        fatalError("Unsuppored View type enountered. Please make sure to use @View on all custom views.")
    }
}
