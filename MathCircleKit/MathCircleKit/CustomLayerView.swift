import UIKit

public class CustomLayerView<T: CALayer>: UIView {
  override public class var layerClass: AnyClass { return T.self }
  public var customLayer: T { return layer as! T }
}

extension CustomLayerView where T: CAShapeLayer {
  public convenience init(
    shapeWithFrame frame: CGRect,
    stroke: UIColor = .black,
    fill: UIColor = .clear
  ) {
    self.init(frame: frame)
    customLayer.strokeColor = stroke.cgColor
    customLayer.fillColor = fill.cgColor
  }
}
