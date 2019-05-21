
// Volume 2 – Section 1 – Video 3: Delegation with protocols

struct Player {
    // ...
}

// A delegate for GameLogic that gets called upon certain game logic events occuring.
protocol GameLogicActionDelegate : class {
    func gameDidStart(sender: GameLogic)
    func playerDidMove(sender: GameLogic, player: Player)
    func gameWillEnd(sender: GameLogic)
}

extension GameLogicActionDelegate {
    // can provide empty default implementations if conforming types
    // don't necessarily need to be notified upon it happening.
    func gameDidStart(sender: GameLogic) {}
}

// The game logic for some kind of game.
class GameLogic {
    
    weak var actionDelegate: GameLogicActionDelegate?
    
    func startGame() {
        // ...
        actionDelegate?.gameDidStart(sender: self)
    }
    
    func playerDidWin(_ player: Player) {
        actionDelegate?.gameWillEnd(sender: self)
        // ...
    }
}

class ViewController {
    
    var gameLogic = GameLogic()
    
    init() {
        // set the delegate to the ViewController instance.
        // therefore we will get notified upon game events happening.
        gameLogic.actionDelegate = self
    }
}

// implementations of GameLogicActionDelegate's requirements.
extension ViewController : GameLogicActionDelegate {
    
    func gameDidStart(sender: GameLogic) {
        // ...
    }
    
    func gameWillEnd(sender: GameLogic) {
        // ...
    }
    
    func playerDidMove(sender: GameLogic, player: Player) {
        // ...
    }
}

class AnotherViewController {
    
    var gameLogic = GameLogic()
    
    init() {
        gameLogic.actionDelegate = self // this wouldn't compile if actionDelegate was coupled to ViewController only.
    }
}

extension AnotherViewController : GameLogicActionDelegate {
    
    func gameDidStart(sender: GameLogic) {
        // ...
    }
    
    func gameWillEnd(sender: GameLogic) {
        // ...
    }
    
    func playerDidMove(sender: GameLogic, player: Player) {
        // ...
    }
}


class Button {
    
    // using a closure over a formal delegate.
    // (so, a function that takes a sender as input, and returns Void).
    var didPressAction: (_ sender: Button) -> Void = { _ in }
    
    func recievedTouch() {
        didPressAction(self)
    }
}

class View {
    
    let button = Button()
    
    init() {
        // make sure to capture self as weak in order to avoid retain cycles.
        button.didPressAction = { [weak self] button in
            print("button was pressed!")
            self?.doSomething()
        }
    }
    
    func doSomething() {
        
    }
}


