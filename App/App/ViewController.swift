import MathCircleKit
import UIKit

class ViewController: UIViewController {
  var gameView: GameView!
  var history = [Game]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground

    let side: CGFloat = view.bounds.width
    let frame = CGRect(x: 0, y: 20, width: side, height: side)
    gameView = GameView(frame: frame)
    view.addSubview(gameView)
    gameView.completed = { game in
      self.history.append(game)
      print(game.answers)
      
      let alert = UIAlertController(title: "Done!", message: nil, preferredStyle: .actionSheet)
      alert.addAction(.init(title: "New", style: .default) { _ in
        self.newGame()
      })
      alert.addAction(.init(title: "Log", style: .default) { _ in
        
      })
      self.present(alert, animated: true)
    }

    newGame()
  }
  
  private func newGame() {
    let side: CGFloat = view.bounds.width
    let center = CGPoint(x: side*0.5, y: side*0.5)
    let count = 5

    let mathCircle = MathCircle(
      side: side-10,
      center: center,
      count: count,
      countOfCircles: 3
    )
    let factor = Int.random(in: 2...10)
    let game = Game(count: count, factor: factor)

    gameView.configure(mathCircle, game: game)
  }
}

