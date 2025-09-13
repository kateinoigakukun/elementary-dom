/// An HTML attribute that can be applied to an HTML element of the associated tag.
public struct HTMLAttribute<Tag: HTMLTagDefinition>: Sendable {
    @usableFromInline
    var htmlAttribute: _StoredAttribute

    /// The name of the attribute.
    public var name: String { htmlAttribute.name }

    /// The value of the attribute.
    public var value: String? { htmlAttribute.value }
}

/// The action to take when merging an attribute with the same name.
public struct HTMLAttributeMergeAction: Sendable {
    @usableFromInline
    var mergeMode: _StoredAttribute.MergeMode

    init(mergeMode: _StoredAttribute.MergeMode) {
        self.mergeMode = mergeMode
    }

    /// Replaces the value of the existing attribute with the new value.
    public static var replacing: Self { .init(mergeMode: .replaceValue) }

    /// Ignores the new value if the attribute already exists.
    public static var ignoring: Self { .init(mergeMode: .ignoreIfSet) }

    /// Appends the new value to the existing value, separated by the specified string.
    public static func appending(separatedBy: String) -> Self { .init(mergeMode: .appendValue(separatedBy)) }
}

