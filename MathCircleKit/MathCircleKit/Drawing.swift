import UIKit

let π = CGFloat.pi
let π2 = π/2
let π4 = π/4

// MARK: -

enum Drawing {
  case arc(Arc)
  case circle(Circle)
  case dot(CGPoint)
  case line(Line)
  case slice(Slice)
}

extension UIBezierPath {
  convenience init(_ drawing: Drawing) {
    self.init()
    append(drawing)
  }
  
  func append(_ drawing: Drawing) {
    switch drawing {
    case let .arc(a):
      addArc(
        withCenter: a.circle.center,
        radius: a.circle.radius,
        startAngle: a.start + a.circle.start,
        endAngle: a.end + a.circle.start,
        clockwise: a.clockwise
      )
    case let .circle(c):
      move(to: c.center.applying(.init(translationX: c.radius, y: 0)))
      addArc(withCenter: c.center, radius: c.radius, startAngle: 0, endAngle: 2 * π, clockwise: true)
    case let .dot(p):
      append(.circle(Circle(center: p, radius: 1)))
    case let .line(line):
      move(to: line.a)
      addLine(to: line.b)
    case let .slice(slice):
      let s = slice.top.circle.point(at: slice.top.start)
      move(to: s)
      append(.arc(slice.top))
      addLine(to: slice.bottom.circle.point(at: slice.bottom.end))
      append(.arc(slice.bottom.flipped))
      addLine(to: s)
    }
  }
}

// MARK: -

struct Arc {
  let circle: Circle
  let start: CGFloat
  let end: CGFloat
  let clockwise: Bool
  
  init(_ circle: Circle, start: CGFloat, end: CGFloat, clockwise: Bool = true) {
    self.circle = circle
    self.start = start
    self.end = end
    self.clockwise = clockwise
  }
}

extension Arc {
  var flipped: Arc {
    return .init(circle, start: end, end: start, clockwise: !clockwise)
  }
  
  func mid(with arc: Arc) -> MidPoint {
    let dt = end - start
    let t = start + dt*0.5
    let dr = circle.radius - arc.circle.radius
    let r = arc.circle.radius + dr*0.5
    let p = Circle(center: circle.center, radius: r, start: circle.start).point(at: t)
    return MidPoint(point: p, t: t)
  }
}

// MARK: -

struct MidPoint {
  let point: CGPoint
  let t: CGFloat
  
  init(point: CGPoint, t: CGFloat) {
    self.point = point
    self.t = t
  }
}

// MARK: -

struct Circle {
  let center: CGPoint
  let radius: CGFloat
  let start: CGFloat
  
  init(center: CGPoint, radius: CGFloat, start: CGFloat = 0) {
    self.center = center
    self.radius = radius
    self.start = start
  }
  
  func point(at t: CGFloat) -> CGPoint {
    return CircleEquation(center: center, radius: radius, t: t + start).p
  }
}

// MARK: -

struct Line {
  let a: CGPoint
  let b: CGPoint
  
  init(a: CGPoint, b: CGPoint) {
    self.a = a
    self.b = b
  }
}

// MARK: -

struct Slice {
  let top: Arc
  let bottom: Arc
  
  init(top: Arc, bottom: Arc) {
    self.top = top
    self.bottom = bottom
  }
}

// MARK: -
