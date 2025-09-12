public extension HTMLAttribute where Tag: HTMLTrait.Attributes.Global {
    static func on(_ event: HTMLAttributeValue.MouseEvent, _ script: String) -> Self { .init(on: event, script: script) }
}

// TODO: window events, drag events, media events (more scoped)

public extension HTMLAttributeValue {
    struct MouseEvent: HTMLEventName {
        public var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static var click: Self { .init(rawValue: "click") }
    }
}

protocol HTMLEventName: RawRepresentable {}

extension HTMLAttribute {
    init(on eventName: some HTMLEventName, script: String) {
        self.init(name: "on\(eventName.rawValue)", value: script)
    }
}
