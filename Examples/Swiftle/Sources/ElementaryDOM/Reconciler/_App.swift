// TODO: main-actor stuff very unclear at the moment, ideally not needed at all
final class App {
    private var root: AnyParentElememnt?
    private var scheduler: Scheduler

    // TODO: rethink this whole API - maybe once usage of async is clearer
    // there should probably be a way to "unmount" the app
    init(dom: JSKitDOMInteractor) {
        self.scheduler = Scheduler(dom: dom)
        self.root = nil
    }

    // generic initializers must be convenience on final classes for embedded
    // https://github.com/swiftlang/swift/issues/78150
    convenience init<RootView: View>(dom: JSKitDOMInteractor, root rootView: consuming RootView) {
        self.init(dom: dom)

        let function = AnyFunctionNode(
            identifier: ObjectIdentifier(self),
            depthInTree: 0,
            runUpdate: { [self, rootView] context in
                self.root =
                    _ElementNode(
                        root: dom.root,
                        context: &context,
                        makeChild: { [rootView] context in
                            RootView._makeNode(
                                rootView,
                                context: _ViewContext(),
                                reconciler: &context
                            )
                        }
                    )
                    .asParentRef
            }
        )
        scheduler.pendingFunctionsQueue.registerFunctionForUpdate(function)
        self.scheduler.reconcile()
    }
}

// TODO: this ain't such a great shape...
final class Scheduler {
    private var dom: JSKitDOMInteractor
    var pendingFunctionsQueue: PendingFunctionQueue = .init()
    private var commitPlan: CommitPlan = .init()

    init(dom: JSKitDOMInteractor) {
        self.dom = dom
    }

    func scheduleFunction(_ function: AnyFunctionNode) {
        if pendingFunctionsQueue.isEmpty {
            dom.queueMicrotask { [self] in
                self.reconcile()
            }
        }
        pendingFunctionsQueue.registerFunctionForUpdate(function)
    }

    func reconcile() {
        var functions = PendingFunctionQueue()
        var plan = CommitPlan()
        swap(&pendingFunctionsQueue, &functions)
        swap(&plan, &self.commitPlan)

        self.commitPlan = _RenderContext(
            scheduler: self,
            commitPlan: consume plan,
            pendingFunctions: consume functions,
        ).drain()

        requestFramePaint()
    }

    private func requestFramePaint() {
        dom.requestAnimationFrame { [self] _ in
            flushCommitPlan()
        }
    }

    private func flushCommitPlan() {
        var plan = CommitPlan()
        swap(&plan, &self.commitPlan)
        plan.flush(dom: &dom)
    }
}
