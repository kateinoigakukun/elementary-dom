import JavaScriptKit


public extension View {
    consuming func mount() {
        let interactor = JSKitDOMInteractor(root: JSObject.global.document.body.object!)
        _ = App(dom: interactor, root: self)
    }
}
