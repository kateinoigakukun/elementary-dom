import ElementaryDOM

final class Game {
    var guesses: [Guess] {
        get {
            _$reactivity.access(Self.propertyID_guesses)
            return _guesses
        }
        set {
            _$reactivity.willSet(Self.propertyID_guesses)
            defer {
                _$reactivity.didSet(Self.propertyID_guesses)
            }
            _guesses = newValue
        }
    }
    private var _guesses: [Guess] = [Guess()]
    private static let propertyID_guesses = PropertyID("guesses")

    func handleKey() {
        guesses[0].addLetter()
    }
    private let _$reactivity = ReactivityRegistrar()
}

struct Guess {
    var count = 0
    mutating func addLetter() {
        count += 1
    }
}

struct GameView {
    @State var game = Game()

    func onKeyPressed() {
        game.handleKey()
    }

    @HTMLBuilder
    var content: some View {
        for _ in game.guesses {}

        KeyboardLetterView(onKeyPressed: onKeyPressed)
    }
}

extension GameView: __FunctionView {
    static func __applyContext(_ context: borrowing _ViewContext, to view: inout Self) {}
    static func __initializeState(from view: borrowing Self) -> _ViewStateStorage {
        let storage = _ViewStateStorage()
        view._game.__initializeState(storage: storage, index: 0)
        return storage
    }
    static func __restoreState(_ storage: _ViewStateStorage, in view: inout Self) {
        view._game.__restoreState(storage: storage, index: 0)
    }
}
struct KeyboardLetterView {
    var onKeyPressed: () -> Void

    var content: some View {
        button {}
        .onClick {
            onKeyPressed()
        }
    }
}

extension KeyboardLetterView: __FunctionView {
    static func __applyContext(_ context: borrowing _ViewContext, to view: inout Self) {}
    typealias __ViewState = Void
}

GameView().mount()
