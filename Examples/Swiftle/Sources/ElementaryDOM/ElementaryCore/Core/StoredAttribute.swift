/// An internal type representing a type-erased HTML attribute.
///
/// This type is used to store HTML attributes and their values of an element. It supports different types of values
/// like plain strings, styles, and classes, and provides different merge strategies when combining attributes.
///
/// The merge strategies control how attributes with the same name are combined:
/// - `.appendValue`: Appends values with a separator (default is space)
/// - `.replaceValue`: Replaces any existing value
/// - `.ignoreIfSet`: Keeps the existing value if present
public struct _StoredAttribute: Equatable, Sendable {
    @usableFromInline
    enum MergeMode: Equatable, Sendable {
        case replaceValue
    }

    @usableFromInline
    enum Value: Equatable, Sendable {
        case empty
        case plain(String)

        @usableFromInline
        static func == (lhs: Value, rhs: Value) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty): return true
            case let (.plain(lhsValue), .plain(rhsValue)): return lhsValue.utf8Equals(rhsValue)
            default: return false
            }
        }
    }

    public var name: String
    @usableFromInline
    var _value: Value

    public var value: String? {
        get {
            switch _value {
            case .empty: return nil
            case let .plain(value): return value
            }
        }
        set {
            _value = newValue.map { .plain($0) } ?? .empty
        }
    }

    @usableFromInline
    var mergeMode: MergeMode = .replaceValue

    @usableFromInline
    init(name: String, value: String? = nil, mergeMode: MergeMode = .replaceValue) {
        self.name = name
        self._value = value.map { .plain($0) } ?? .empty
        self.mergeMode = mergeMode
    }


    mutating func mergeWith(_ attribute: consuming _StoredAttribute) {
        _value = attribute._value
    }

    @inlinable
    public static func == (lhs: _StoredAttribute, rhs: _StoredAttribute) -> Bool {
        lhs.name.utf8Equals(rhs.name) && lhs._value == rhs._value && lhs.mergeMode == rhs.mergeMode
    }
}


extension String {
    @inline(__always)
    @usableFromInline
    func utf8Equals(_ other: borrowing String) -> Bool {
        // for embedded support
        utf8.elementsEqual(other.utf8)
    }

    fileprivate static func utf8Equals(_ lhs: borrowing String, _ rhs: borrowing String) -> Bool {
        lhs.utf8.elementsEqual(rhs.utf8)
    }
}
