public extension View {
    func onClick(_ handler: @escaping () -> Void) -> _EventHandlingView<Self> {
        on("click", handler: handler)
    }
}
