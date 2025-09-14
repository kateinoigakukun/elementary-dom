/// A result builder for building HTML components.
@resultBuilder public struct HTMLBuilder {
    @inlinable
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: HTML {
        content
    }

    @inlinable
    public static func buildBlock<Content>(_ content: Content) -> Content where Content: HTML {
        content
    }

    @inlinable
    public static func buildBlock() -> HTMLText {
        HTMLText("")
    }

    @inlinable
    public static func buildArray<Element: HTML>(_ components: [Element]) -> _HTMLArray<Element> {
        _HTMLArray(components)
    }
}

public extension HTML where Content == Never {
    var content: Never {
        fatalError("content cannot be called on \(Self.self)")
    }
}

extension Never: HTML {
    public typealias Tag = Never
    public typealias Content = Never
    public var content: Never { fatalError() }
}


/// A type that represents text content in an HTML document.
///
/// The text will be escaped when rendered.
public struct HTMLText: HTML, Sendable {
    /// The text content.
    public var text: String

    /// Creates a new text content with the specified text.
    @inlinable
    public init(_ text: String) {
        self.text = text
    }


}


public struct _HTMLArray<Element: HTML>: HTML {
    public let value: [Element]

    @inlinable
    public init(_ value: [Element]) {
        self.value = value
    }


}
