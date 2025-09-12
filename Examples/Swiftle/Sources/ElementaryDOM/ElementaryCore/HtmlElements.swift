// Minimal HTML elements for button functionality only

// Essential elements used in our crash reproducer
public typealias button<Content: HTML> = HTMLElement<HTMLTag.button, Content>
public typealias span<Content: HTML> = HTMLElement<HTMLTag.span, Content>

// Basic container elements that might be needed
public typealias div<Content: HTML> = HTMLElement<HTMLTag.div, Content>
public typealias body<Content: HTML> = HTMLElement<HTMLTag.body, Content>

// Document structure elements needed by HtmlDocument
public typealias html<Content: HTML> = HTMLElement<HTMLTag.html, Content>
public typealias head<Content: HTML> = HTMLElement<HTMLTag.head, Content>
public typealias title<Content: HTML> = HTMLElement<HTMLTag.title, Content>

// Additional elements needed by ElementModifiers
public typealias p<Content: HTML> = HTMLElement<HTMLTag.p, Content>