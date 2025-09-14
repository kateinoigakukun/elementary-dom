// hand-rolled tuples types for embedded support (variadic generics are not supported in Embedded ATM)
// unfortunately variadic generics perform significantly worse than the hand-rolled tuples,
// so we can just use them for normal HTML rendering as well

public extension HTMLBuilder {
    @inlinable
    static func buildBlock<V0: HTML, V1: HTML>(_ v0: V0, _ v1: V1) -> _HTMLTuple2<V0, V1> {
        _HTMLTuple2(v0: v0, v1: v1)
    }


    // Removed 5-element buildBlock - not needed for crash reproduction

    // Removed 6-element buildBlock - not needed for crash reproduction

    // variadic generics currently not supported in embedded
    // Removed generic buildBlock - not needed for crash reproduction
}

public struct _HTMLTuple2<V0: HTML, V1: HTML>: HTML {
    public let v0: V0
    public let v1: V1

    @inlinable
    public init(v0: V0, v1: V1) {
        self.v0 = v0
        self.v1 = v1
    }


}


// Removed _HTMLTuple5 - not needed for crash reproduction

// Removed _HTMLTuple6 - not needed for crash reproduction

// Removed generic variadic _HTMLTuple - not needed for crash reproduction
