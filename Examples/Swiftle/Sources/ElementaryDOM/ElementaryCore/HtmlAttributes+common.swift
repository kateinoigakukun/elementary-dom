// Basic global attributes that might be needed
public extension HTMLAttribute {
    static func id(_ value: String) -> Self {
        HTMLAttribute(name: "id", value: value)
    }

    static func `class`(_ value: String) -> Self {
        HTMLAttribute(name: "class", value: value)
    }
}
