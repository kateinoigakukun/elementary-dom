struct AnyFunctionNode {
    let identifier: ObjectIdentifier
    let depthInTree: Int
    let runUpdate: (inout _RenderContext) -> Void
}

struct CommitAction {
    // TODO: is there a way to make this allocation-free?
    let run: (inout _CommitContext) -> Void
}

public struct _RenderContext: ~Copyable {
    let scheduler: Scheduler
    var commitPlan: CommitPlan

    private(set) var pendingFunctions: PendingFunctionQueue
    var depth: Int = 0

    init(
        scheduler: Scheduler,
        commitPlan: consuming CommitPlan,
        pendingFunctions: consuming PendingFunctionQueue = .init()
    ) {
        self.pendingFunctions = pendingFunctions
        self.scheduler = scheduler
        self.commitPlan = commitPlan

        depth = 0
    }

    mutating func addFunction(_ function: AnyFunctionNode) {
        pendingFunctions.registerFunctionForUpdate(function)
    }

    mutating func withCurrentLayoutContainer(_ block: (inout Self) -> Void) {
        block(&self)
    }

    consuming func drain() -> CommitPlan {
        while let next = pendingFunctions.next() {
            next.runUpdate(&self)
        }

        return commitPlan
    }

    // TODO: init with assert, but would need to make commitplan optional
}

public struct _CommitContext: ~Copyable {
    let dom: JSKitDOMInteractor

    private var prePaintActions: [() -> Void] = []
    private var postPaintActions: [() -> Void] = []

    init(dom: JSKitDOMInteractor) {
        self.dom = dom
    }

    mutating func addPrePaintAction(_ action: @escaping () -> Void) {
        prePaintActions.append(action)
    }

    mutating func addPostPaintAction(_ action: @escaping () -> Void) {
        postPaintActions.append(action)
    }

    consuming func drain() {
        for action in prePaintActions {
            action()
        }
        prePaintActions.removeAll()

        // TODO: make this better, clearer scheduling
        dom.runNext { [postPaintActions] in
            for action in consume postPaintActions {
                action()
            }
        }
    }
}

struct PendingFunctionQueue: ~Copyable {
    private var functionsToRun: [AnyFunctionNode] = []

    var isEmpty: Bool { functionsToRun.isEmpty }

    mutating func registerFunctionForUpdate(_ node: AnyFunctionNode) {
        // sorted insert by depth in reverse order, avoiding duplicates
        var inserted = false

        for index in functionsToRun.indices {
            let existingNode = functionsToRun[index]
            if existingNode.identifier == node.identifier {
                inserted = true
                break
            }
            if node.depthInTree > existingNode.depthInTree {
                functionsToRun.insert(node, at: index)
                inserted = true
                break
            }
        }
        if !inserted {
            functionsToRun.append(node)
        }
    }

    mutating func next() -> AnyFunctionNode? {
        functionsToRun.popLast()
    }
}

struct CommitPlan: ~Copyable {
    private var nodes: [CommitAction] = []

    mutating func addNodeAction(_ action: CommitAction) {
        nodes.append(action)
    }

    consuming func flush(dom: inout JSKitDOMInteractor) {
        var context = _CommitContext(dom: dom)
        for node in nodes {
            node.run(&context)
        }
        nodes.removeAll()
        context.drain()
    }
}

// TODO: move to a better place, maybe use a span with lifecycle stuff
public struct ContainerLayoutPass: ~Copyable {
    struct Entry {
        enum Status {
            case unchanged
            case added
            case removed
            case moved
        }
    }
}


struct ManagedDOMReference: ~Copyable {
    let reference: DOM.Node
}
