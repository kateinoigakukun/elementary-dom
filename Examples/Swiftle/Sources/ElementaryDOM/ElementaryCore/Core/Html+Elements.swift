/// An HTML element that can contain content.
public struct HTMLElement<Tag: HTMLTagDefinition, Content: HTML>: HTML where Tag: HTMLTrait.Paired {
    /// The type of the HTML tag this element represents.
    public typealias Tag = Tag
    public var _attributes: _AttributeStorage

    // The content of the element.
    public var content: Content

    /// Creates a new HTML element with the specified content.
    /// - Parameter content: The content of the element.
    @inlinable
    public init(@HTMLBuilder content: () -> Content) {
        _attributes = .init()
        self.content = content()
    }

    /// Creates a new HTML element with the specified attribute and content.
    /// - Parameters:
    ///   - attribute: The attribute to apply to the element.
    ///   - content: The content of the element.
    @inlinable
    public init(_ attribute: HTMLAttribute<Tag>, @HTMLBuilder content: () -> Content) {
        _attributes = .init(attribute)
        self.content = content()
    }

    /// Creates a new HTML element with the specified attributes and content.
    /// - Parameters:
    ///  - attributes: The attributes to apply to the element.
    ///  - content: The content of the element.
    @inlinable
    public init(_ attributes: HTMLAttribute<Tag>..., @HTMLBuilder content: () -> Content) {
        _attributes = .init(attributes)
        self.content = content()
    }

    /// Creates a new HTML element with the specified attributes and content.
    /// - Parameters:
    ///  - attributes: The attributes to apply to the element as an array.
    ///  - content: The content of the element.
    @inlinable
    public init(attributes: [HTMLAttribute<Tag>], @HTMLBuilder content: () -> Content) {
        _attributes = .init(attributes)
        self.content = content()
    }


}

extension HTMLElement: Sendable where Content: Sendable {}

