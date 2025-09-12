// style and class attributes
public extension HTMLAttribute where Tag: HTMLTrait.Attributes.Global {
    static func `class`(_ value: String) -> Self {
        HTMLAttribute(name: "class", value: value, mergedBy: .appending(separatedBy: " "))
    }

    static func style(_ value: String) -> Self {
        HTMLAttribute(name: "style", value: value, mergedBy: .appending(separatedBy: ";"))
    }

    @inlinable
    static func `class`(_ values: some Sequence<String>) -> Self {
        HTMLAttribute(classes: .init(values))
    }

    @inlinable
    static func style(_ values: KeyValuePairs<String, String>) -> Self {
        HTMLAttribute(styles: .init(values))
    }

    @inlinable
    @_disfavoredOverload
    static func style(_ values: some Sequence<(key: String, value: String)>) -> Self {
        HTMLAttribute(styles: .init(values))
    }
}

/// A namespace for value types used in attributes.
public enum HTMLAttributeValue {}
