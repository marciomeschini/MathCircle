import UIKit

public struct MathCircle {
  public let side: CGFloat // fix me, should be radius
  public let center: CGPoint
  public let count: Int
  public let countOfCircles: Int
  
  let values: [CGFloat]
  let circles: [Circle]
  let lines: [[Line]]
  let arcs: [[Arc]]
  let midPoints: [[MidPoint]]
  let slices: [[Drawing]]
  let paths: [[UIBezierPath]]
  
  public init(side: CGFloat, center: CGPoint, count: Int, countOfCircles: Int = 3) {
    self.side = side
    self.center = center
    self.count = count
    self.countOfCircles = countOfCircles
    let values = (0...count).map { 2 * π * CGFloat($0)/CGFloat(count) }
    self.values = values
    let single = side*0.5/(CGFloat(countOfCircles)+0.5)
    let widths = Array((0..<countOfCircles).map { CGFloat($0) * single }.reversed())
    let circles = widths.map { Circle(center: center, radius: side*0.5-$0, start: -π2) }
    self.circles = circles
    let lines = circles.tupledByTwo().map { c0, c1 in
      return values.map { Line(a: c0.point(at: $0), b: c1.point(at: $0)) }
    }
    self.lines = lines

    let tuples = values.tupledByTwo()
    arcs = circles.map { circle in tuples.map { Arc(circle, start: $0.0, end: $0.1) } }
    
    midPoints = arcs.tupledByTwo().map { a, b in zip(a, b).map { $0.0.mid(with: $0.1) } }
    
    slices = arcs.tupledByTwo().map { arc0, arc1 in
      return zip(arc0, arc1)
        .map { Slice(top: $0.0, bottom: $0.1) }
        .map { Drawing.slice($0) }
    }
    
    paths = slices.map { ring in ring.map { UIBezierPath($0) } }
  }
}

// MARK: -

struct Selection {
  let indexes: (circle: Int, slice: Int)
  let path: UIBezierPath
}

func selectedPath(from paths: [[UIBezierPath]], at point: CGPoint) -> Selection? {
  guard let indices = paths.indices(where: { return $0.contains(point) }) else {
    return nil
  }
  return Selection(indexes: indices, path: paths[indices.0][indices.1])
}

// MARK: -

func background(_ mathCircle: MathCircle) -> UIBezierPath {
  let path = UIBezierPath()
  mathCircle.circles.forEach { path.append(.circle($0)) }
//  path.append(.dot(mathCircle.center))
  mathCircle.lines.flatMap { $0 }.map { Drawing.line($0) }.forEach(path.append)
  return path
}
