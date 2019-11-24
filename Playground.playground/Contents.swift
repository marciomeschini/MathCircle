import MathCircleKit
import UIKit
import PlaygroundSupport

let vc = UIViewController()
PlaygroundPage.current.liveView = vc
vc.view.backgroundColor = .white

let side: CGFloat = 375
let frame = CGRect(x: 0, y: 150, width: side, height: side)
let rootView = GameView(frame: frame)
vc.view.addSubview(rootView)

// MARK: - SUT

let center = CGPoint(x: side*0.5, y: side*0.5)
let count = 12

let mathCircle = MathCircle(
  side: side-10,
  center: center,
  count: count,
  countOfCircles: 3
)
let game = Game(count: count, factor: 2)

// MARK: - Root
rootView.configure(mathCircle, game: game)
