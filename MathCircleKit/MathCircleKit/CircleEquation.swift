import UIKit

struct CircleEquation: Equatable {
  /// x = a + r cos t
  /// y = b + r sin t
  /// t is a parametric variable in the range 0 to 2π, interpreted geometrically as the angle that the ray from (a, b) to (x, y) makes with the positive x-axis.
  let center: CGPoint
  let radius: CGFloat
  let t: CGFloat
  let p: CGPoint
  
  init(center: CGPoint = .zero, radius: CGFloat, t: CGFloat) {
    self.center = center
    self.radius = radius
    self.t = t
    p = CGPoint(x: center.x + radius * cos(t), y: center.y + radius * sin(t))
  }
}

