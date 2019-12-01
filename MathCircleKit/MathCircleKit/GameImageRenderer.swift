import UIKit

struct GameImageRenderer {
  let mathCircle: MathCircle
  let game: Game
  let size: CGSize
  
  var image: UIImage {
    struct Item {
      let circleIndex: Int
      let index: Int
      let midPoint: MidPoint
      let value: String
    }
    
    return UIGraphicsImageRenderer(size: size).image { context in
      let font = UIFont.systemFont(ofSize: 30)
      
      let label: (Item) -> Void = { item in
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
}
