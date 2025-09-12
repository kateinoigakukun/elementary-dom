/// A type that represents a full HTML document.
///
/// Provides a simple structure to model top-level HTML types.
/// A default ``HTML/content`` implementation takes your ``title``, ``head``, ``body``
/// and renders them into a full HTML document.
/// Optionally properties for ``lang`` and ``dir`` can be provided.
///
/// ```swift
/// struct MyPage: HTMLDocument {
///   var title = "Hello, World!"
///   var lang = "en"
///
///   var head: some HTML {
///     meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
///   }
///
///   var body: some HTML {
///     h1 { "Hello, World!" }
///     p { "This is a simple HTML document." }
///   }
/// }
/// ```
public protocol HTMLDocument: HTML {
    associatedtype HTMLHead: HTML
    associatedtype HTMLBody: HTML

    /// The title of the HTML document.
    var title: String { get }


    @HTMLBuilder var head: HTMLHead { get }
    @HTMLBuilder var body: HTMLBody { get }
}

public extension HTMLDocument {
    @HTMLBuilder var content: some HTML {
        HTMLRaw("<!DOCTYPE html>")
        html {
            ElementaryDOM.head {
                ElementaryDOM.title { self.title }
                self.head
            }
            ElementaryDOM.body { self.body }
        }
    }
}
