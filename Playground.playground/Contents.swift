import MathCircleKit
import UIKit
import PlaygroundSupport

let vc = UIViewController()
PlaygroundPage.current.liveView = vc
vc.view.backgroundColor = .white

let side: CGFloat = 375
let frame = CGRect(x: 0, y: 150, width: side, height: side)
let rootView = shapeLayerView(frame: frame)
vc.view.addSubview(rootView)
let stagingView = shapeLayerView(frame: frame, stroke: .red, fill: UIColor.blue.withAlphaComponent(0.2))
stagingView.customLayer.lineWidth = 2
vc.view.addSubview(stagingView)

// MARK: - SUT

let center = CGPoint(x: side*0.5, y: side*0.5)
let count = 12

struct MathCircle {
  let side: CGFloat
  let center: CGPoint
  let count: Int
  let inset: CGFloat = 10
  let values: [CGFloat]
  let countOfCircles = 3
  
  let circles: [Circle]
  let lines: [[Line]]
  let arcs: [[Arc]]
  let midPoints: [[CGPoint]]
  let slices: [[Drawing]]
  let paths: [[UIBezierPath]]
  
  init(side: CGFloat, center: CGPoint, count: Int) {
    self.side = side
    self.center = center
    self.count = count
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

let mathCircle = MathCircle(side: side-10, center: center, count: count)


// MARK: - Root

let path = UIBezierPath()

path.append(UIBezierPath(rect: rootView.bounds))
mathCircle.circles.forEach { path.append(.circle($0)) }
path.append(.dot(center))
mathCircle.lines.flatMap { $0 }.map { Drawing.line($0) }.forEach(path.append)

rootView.customLayer.path = path.cgPath

// MARK: - Staging

let staging = UIBezierPath()

//mathCircle.slices.flatMap { $0 }.forEach(staging.append)
//mathCircle.paths.flatMap { $0 }.forEach(staging.append)
//mathCircle.midPoints.flatMap { $0 }.map { Drawing.dot($0) }.forEach(staging.append)

// MARK: - Labels

let label: (CGPoint, Int) -> UILabel = { p, index in
  let label = UILabel(frame: CGRect(x: 0, y: 0, width: 28, height: 24))
  label.center = p
  label.text = "\(index)"
  label.textAlignment = .center
//  label.layer.borderWidth = 0.5
  return label
}

let labels2 = mathCircle.midPoints[1].enumerated().map { offset, p in
  return label(p, offset)
}
labels2.forEach(rootView.addSubview)

let labels1 = mathCircle.midPoints[0].enumerated().map { offset, p in
  return label(p, offset)
}
labels1.forEach(rootView.addSubview)

extension Array where Element : Collection, Element.Index == Int {
  func indices(where predicate: (Element.Iterator.Element) -> Bool) -> (Int, Int)? {
    for (i, row) in self.enumerated() {
      if let j = row.firstIndex(where: predicate) {
        return (i, j)
      }
    }
    return nil
  }
}

class Object {
  @objc func tap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: sender.view)
    let first = mathCircle.paths.flatMap { $0 }.first { path in
      return path.contains(point)
    }
    print(point)
    guard let found = first else { return }
    // find ring
    // find index
    let indices = mathCircle.paths.indices { $0.isEqual(found) }
    print(indices)
    
    let path = UIBezierPath(cgPath: stagingView.customLayer.path ?? UIBezierPath().cgPath)
    let new = UIBezierPath(cgPath: path.cgPath)
    new.append(found)
    stagingView.customLayer.path = new.cgPath
  }
}

let object = Object()
let gesture = UITapGestureRecognizer(target: object, action: #selector(Object.tap(_:)))
stagingView.addGestureRecognizer(gesture)

stagingView.customLayer.path = staging.cgPath

let values1 = (1...mathCircle.values.count).map { $0 }
zip(labels1, values1).forEach { $0.0.text = "\($0.1)" }

let values2 = values1.map { $0*2 }
zip(labels2, values2).forEach { $0.0.text = "\($0.1)" }
