@testable import MathCircleKit
import XCTest

class CircleEquationTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func test_p() {
    print(CircleEquation(radius: 1, t: π2).p)
//    XCTAssertEqual(CircleEquation(radius: 1, t: π2).p, .init(x: 6.12, y: 1))
  }

}
