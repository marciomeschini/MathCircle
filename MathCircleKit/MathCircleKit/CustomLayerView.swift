import UIKit

class CustomLayerView<T: CALayer>: UIView {
  override class var layerClass: AnyClass { return T.self }
  var custom: T { return layer as! T }
}

extension CustomLayerView where T: CAShapeLayer {
  convenience init(
    shapeWithFrame frame: CGRect,
    stroke: UIColor = .black,
    fill: UIColor = .clear
  ) {
    self.init(frame: frame)
    custom.strokeColor = stroke.cgColor
    custom.fillColor = fill.cgColor
  }
}
