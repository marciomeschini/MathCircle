@testable import MathCircleKit
import XCTest

class DrawingTests: XCTestCase {
  
  func test_init_arc() {
    let expected = UIBezierPath()
    expected.addArc(withCenter: .zero, radius: 1, startAngle: 0, endAngle: 1, clockwise: true)
    let arc = Arc(Circle(center: .zero, radius: 1), start: 0, end: 1)
    
    XCTAssertEqual(UIBezierPath(.arc(arc)), expected)
  }
  
  func test_init_circle() {
    let expected = UIBezierPath()
    expected.move(to: .init(x: 1, y: 0))
    expected.addArc(
      withCenter: .zero,
      radius: 1,
      startAngle: 0,
      endAngle: 2 * π,
      clockwise: true
    )
    let circle = Circle(center: .zero, radius: 1)
    
    XCTAssertEqual(UIBezierPath(.circle(circle)), expected)
  }
}
