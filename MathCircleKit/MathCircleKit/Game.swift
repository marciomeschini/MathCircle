import UIKit

public struct Game {
  public let count: Int
  public let factor: Int
  public let values0: [Int]
  public let values1: [Int]
  public var answers: [Answer]
  
  public init(count: Int, factor: Int) {
    self.count = count
    self.factor = factor
    values0 = (1...count).map { $0 }.shuffled()
    values1 = values0.map { $0*factor }
    answers = values1.map { _ in .missing }
  }
}

extension Game {
  public enum Answer {
    case correct
    case missing
    case wrong
  }
}

struct Item {
  let circleIndex: Int
  let index: Int
  let midPoint: MidPoint
  let value: String
}

func makeBitmap(mathCircle: MathCircle, game: Game, size: CGSize) -> UIImage {
  return UIGraphicsImageRenderer(size: size).image { context in
    let font = UIFont.systemFont(ofSize: 30)
    
    let label: (Item) -> Void = { item in
      //    guard item.circleIndex == 0 else { return }
      context.cgContext.saveGState()
      context.cgContext.translateBy(x: item.midPoint.point.x, y: item.midPoint.point.y)
      context.cgContext.rotate(by: 0)//item.midPoint.t)
      let string = NSAttributedString(string: item.value, attributes: [.font: font])
      let size = string.size()
      string.draw(at: .init(x: -size.width*0.5, y: -size.height*0.5))
      context.cgContext.restoreGState()
    }
    
    let items = mathCircle.midPoints.enumerated().map { circleIndex, current in
      current.enumerated().map { index, p in
        return Item(circleIndex: circleIndex, index: index, midPoint: p, value: "")
      }
    }
    let evaluated = zip(items, [game.values0, game.values1]).map { current, values in
      zip(current, values).map { item, value in
        return Item(circleIndex: item.circleIndex, index: item.index, midPoint: item.midPoint, value: "\(value)")
      }
    }
    
    evaluated.flatMap { $0 }.forEach { label($0)}
  }
}
