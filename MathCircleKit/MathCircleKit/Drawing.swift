import UIKit

public let π = CGFloat.pi
public let π2 = π/2
public let π4 = π/4

// MARK: -

public enum Drawing {
  case arc(Arc)
  case circle(Circle)
  case dot(CGPoint)
  case line(Line)
  case slice(Slice)
}

extension UIBezierPath {
  public convenience init(_ drawing: Drawing) {
    self.init()
    append(drawing)
  }
  
  public func append(_ drawing: Drawing) {
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

public struct Arc {
  public let circle: Circle
  public let start: CGFloat
  public let end: CGFloat
  public let clockwise: Bool
  
  public init(_ circle: Circle, start: CGFloat, end: CGFloat, clockwise: Bool = true) {
    self.circle = circle
    self.start = start
    self.end = end
    self.clockwise = clockwise
  }
}

extension Arc {
  public var flipped: Arc {
    return .init(circle, start: end, end: start, clockwise: !clockwise)
  }
  
  public func mid(with arc: Arc) -> MidPoint {
    let dt = end - start
    let t = start + dt*0.5
    let dr = circle.radius - arc.circle.radius
    let r = arc.circle.radius + dr*0.5
    let p = Circle(center: circle.center, radius: r, start: circle.start).point(at: t)
    return MidPoint(point: p, t: t)
  }
}

// MARK: -

public struct MidPoint {
  public let point: CGPoint
  public let t: CGFloat
  
  public init(point: CGPoint, t: CGFloat) {
    self.point = point
    self.t = t
  }
}

// MARK: -

public struct Circle {
  public let center: CGPoint
  public let radius: CGFloat
  public let start: CGFloat
  
  public init(center: CGPoint, radius: CGFloat, start: CGFloat = 0) {
    self.center = center
    self.radius = radius
    self.start = start
  }
  
  public func point(at t: CGFloat) -> CGPoint {
    return CircleEquation(center: center, radius: radius, t: t + start).p
  }
}

// MARK: -

public struct Line {
  public let a: CGPoint
  public let b: CGPoint
  
  public init(a: CGPoint, b: CGPoint) {
    self.a = a
    self.b = b
  }
}

// MARK: -

public struct Slice {
  public let top: Arc
  public let bottom: Arc
  
  public init(top: Arc, bottom: Arc) {
    self.top = top
    self.bottom = bottom
  }
}

// MARK: -
