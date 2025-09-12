import JavaScriptKit


public extension View {
    consuming func mount() {
        _ = App(dom: JSKitDOMInteractor(root: JSObject.global.document.body.object!), root: self)
    }
}
