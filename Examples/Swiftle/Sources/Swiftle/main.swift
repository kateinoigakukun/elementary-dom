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
    mutating func addLetter() {
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
    static func __applyContext(_ context: borrowing _ViewContext, to view: inout Self) {
    }
    static func __initializeState(from view: borrowing Self) -> _ViewStateStorage {
        let storage = _ViewStateStorage()
        view._game.__initializeState(storage: storage, index: 0)
        return storage
    }
    static func __restoreState(_ storage: _ViewStateStorage, in view: inout Self) {
        view._game.__restoreState(storage: storage, index: 0)
    }
}

extension GameView: __ViewEquatable {
    static func __arePropertiesEqual(a: Self, b: Self) -> Bool {
        return true

    }
}
struct KeyboardLetterView {
    var onKeyPressed: () -> Void

    @HTMLBuilder
    var content: some View {
        button {
            HTMLElement<HTMLTag.span, HTMLText> {
                "S"
            }
        }
        .onClick {
            onKeyPressed()
        }
    }
}

extension KeyboardLetterView: __FunctionView {
    static func __applyContext(_ context: borrowing _ViewContext, to view: inout Self) {

    }
    typealias __ViewState = Void
}

GameView().mount()
