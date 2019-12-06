import MathCircleKit
import UIKit

class ViewController: UIViewController {
  var gameView: GameView!
  var history = [Game]()
  var count = 5
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground

    let side: CGFloat = view.bounds.width
    let frame = CGRect(x: 0, y: 30, width: side, height: side)
    gameView = GameView(frame: frame)
    view.addSubview(gameView)
    gameView.completed = { game in
      self.history.append(game)
      print(game.answers)
      
      let alert = UIAlertController(title: "Done!", message: nil, preferredStyle: .actionSheet)
      alert.addAction(.init(title: "New", style: .default) { _ in
        self.newGame()
        self.gameView.selectFirst()
      })
      alert.addAction(.init(title: "Settings", style: .default) { _ in
        self.presentSettings()
      })
      self.present(alert, animated: true)
    }

    newGame()
    gameView.selectFirst()
    
//    let button = UIButton(frame: CGRect(x: 10, y: 10, width: 60, height: 40))
//    button.backgroundColor = .red
//    button.addTarget(self, action: #selector(presentSettings), for: .touchUpInside)
//    view.addSubview(button)
  }
  
  @objc func presentSettings() {
    let settings = SettingsViewController(initial: count) {
      self.count = $0
      self.newGame()
    }
    settings.presentationController?.delegate = self
    self.present(settings, animated: true)
  }
  
  private func newGame() {
    let radius: CGFloat = gameView.bounds.width*0.5

    let mathCircle = MathCircle(
      radius: radius-5,
      count: count,
      countOfCircles: 3
    )
    let factor = Int.random(in: 2...count)
    let game = Game(count: count, factor: factor)

    gameView.configure(mathCircle, game: game)
  }
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    gameView.selectFirst()
  }
}

// select count [5, 12]
// select factor/random [2, 12]/ (yes, no)
// show history
