/// A type that represents HTML content that can be rendered.
///
/// You can create reusable HTML components by conforming to this protocol
/// and implementing the ``content`` property.
///
/// ```swift
/// struct FeatureList: HTML {
///   var features: [String]
///
///   var content: some HTML {
///     ul {
///       for feature in features {
///         li { feature }
///       }
///     }
///   }
/// }
/// ```
public protocol HTML<Tag> {
    /// The HTML tag this component represents, if any.
    ///
    /// The Tag type defines which attributes can be attached to an HTML element.
    /// If an element does not represent a specific HTML tag, the Tag type will
    /// be ``Swift/Never`` and the element cannot be attributed.
    associatedtype Tag: HTMLTagDefinition = Content.Tag

    /// The type of the HTML content this component represents.
    associatedtype Content: HTML = Never

    /// The HTML content of this component.
    @HTMLBuilder var content: Content { get }
}

/// A type that represents an HTML tag.
public protocol HTMLTagDefinition: Sendable {
    /// The name of the HTML tag as it is rendered in an HTML document.
    static var name: String { get }
}

extension Never: HTMLTagDefinition {
    public static var name: String { fatalError("HTMLTag.name was called on Never") }
}



