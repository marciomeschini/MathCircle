import UIKit

public class CustomLayerView<T: CALayer>: UIView {
  override public class var layerClass: AnyClass { return T.self }
  public var customLayer: T { return layer as! T }
}

public typealias ShapeLayerView = CustomLayerView<CAShapeLayer>

public func shapeLayerView(
  frame: CGRect,
  stroke: UIColor = .black,
  fill: UIColor = .clear
) -> ShapeLayerView {
  let rootView = ShapeLayerView(frame: frame)
  rootView.customLayer.strokeColor = stroke.cgColor
  rootView.customLayer.fillColor = fill.cgColor
  return rootView
}
