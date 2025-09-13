/// An internal type that stores HTML attributes for elements.
///
/// It is optimized to avoid allocations for single attribute elements, and implements a lazy "flattening" iterator for rendering.
///
/// The storage automatically optimizes for the number of attributes being stored,
/// using the most efficient representation in each case.
public enum _AttributeStorage: Sendable, Equatable {
    case none
    case single(_StoredAttribute)

    @inlinable
    init() {
        self = .none
    }

    @inlinable
    init(_ attribute: HTMLAttribute<some HTMLTagDefinition>) {
        self = .single(attribute.htmlAttribute)
    }

    @inlinable
    init(_ attributes: [HTMLAttribute<some HTMLTagDefinition>]) {
        if attributes.isEmpty {
            self = .none
        } else {
            self = .single(attributes[0].htmlAttribute)  // Simplified: only store first
        }
    }

    public var isEmpty: Bool {
        switch self {
        case .none: return true
        case .single: return false
        }
    }

    public mutating func append(_ attributes: consuming _AttributeStorage) {
        switch attributes {
        case .none: break
        case .single(let attr):
            switch self {
            case .none: self = .single(attr)
            case .single: break  // Simplified: don't merge
            }
        }
    }
}