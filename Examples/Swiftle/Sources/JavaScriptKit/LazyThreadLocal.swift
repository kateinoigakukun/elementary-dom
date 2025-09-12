/// Simple replacement for LazyThreadLocal for reduced functionality
final class LazyThreadLocal<T> {
    private var _value: T?
    private let initialize: () -> T

    init(initialize: @escaping () -> T) {
        self.initialize = initialize
    }

    var wrappedValue: T {
        if let value = _value {
            return value
        }
        let value = initialize()
        _value = value
        return value
    }
}