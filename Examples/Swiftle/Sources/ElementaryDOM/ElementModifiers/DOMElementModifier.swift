protocol DOMElementModifier: AnyObject {
    associatedtype Value

    static var key: DOMElementModifiers.Key<Self> { get }

    init(value: consuming Value, upstream: borrowing DOMElementModifiers, _ context: inout _RenderContext)
    func updateValue(_ value: consuming Value, _ context: inout _RenderContext)

    func mount(_ node: DOM.Node, _ context: inout _CommitContext)
}


extension DOMElementModifier {
    static var key: DOMElementModifiers.Key<Self> {
        DOMElementModifiers.Key(Self.self)
    }
}

struct DOMElementModifiers {
    struct Key<Directive: DOMElementModifier> {
        let typeID: ObjectIdentifier

        init(_: Directive.Type) {
            typeID = ObjectIdentifier(Directive.self)
        }
    }

    private var storage: [ObjectIdentifier: any DOMElementModifier] = [:]

    var isEmpty: Bool {
        storage.isEmpty
    }

    subscript<Directive: DOMElementModifier>(_ key: Key<Directive>) -> Directive? {
        get {
            storage[key.typeID] as? Directive
        }
        set {
            if let newValue = newValue {
                storage[key.typeID] = newValue
            } else {
                storage.removeValue(forKey: key.typeID)
            }
        }
    }

    mutating func takeModifiers() -> [any DOMElementModifier] {
        let directives = Array(storage.values)
        storage.removeAll()
        return directives
    }
}
