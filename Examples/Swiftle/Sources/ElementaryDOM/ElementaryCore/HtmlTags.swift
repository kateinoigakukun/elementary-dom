/// A namespace for HTML tag definitions.
public enum HTMLTag {}

/// A namespace for trait protocols that control the behavior a capabilities of HTML elements.
public enum HTMLTrait {
    /// A marker that indicates that an HTML tag is paired.
    public protocol Paired: HTMLTagDefinition {}
}

public extension HTMLTag {
    enum button: HTMLTrait.Paired { public static let name = "button" }
}

