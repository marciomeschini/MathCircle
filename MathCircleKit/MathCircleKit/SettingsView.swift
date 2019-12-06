import UIKit

public final class SettingsView: UIView {
  private(set) var mathCircle: MathCircle = MathCircle(radius: 1, count: 1, countOfCircles: 1)
  let pathView: CustomLayerView<CAShapeLayer>
  let selectionView: CustomLayerView<CAShapeLayer>
  let bitmapView = UIImageView()
  private var selection: Selection?
  let delta = 3
  let select: (Int) -> Void
  
  public init(frame: CGRect, select: @escaping (Int) -> Void) {
    self.select = select
    let shapeFrame = CGRect(origin: .zero, size: frame.size)
    pathView = CustomLayerView(shapeWithFrame: shapeFrame)
    selectionView = CustomLayerView(shapeWithFrame: shapeFrame, fill: UIColor.blue.withAlphaComponent(0.2))
    bitmapView.frame = shapeFrame
    super.init(frame: frame)
    [bitmapView, pathView, selectionView].forEach(addSubview)
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  public func configure(_ mathCircle: MathCircle, updateTo index: Int) {
    self.mathCircle = mathCircle
    
    selectionView.custom.path = nil
    pathView.custom.path = background(mathCircle).cgPath
    let values = [(0...mathCircle.count).map { "\($0+delta)" }]
    bitmapView.image = MidPointsImageRenderer(midPoints: mathCircle.midPoints, size: bounds.size, values: values, shouldRotate: true).image
    updateTo(index-delta)
  }
  
  @objc func tap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: sender.view)
    print(point)
    guard let selection = selectedPath(from: mathCircle.paths, at: point) else {
      return
    }
    updateTo(selection.indexes.slice)
    self.selection = selection
    select(selection.indexes.slice + delta)
  }
  
  private func updateTo(_ index: Int) {
    let path = UIBezierPath()
    (0...index).forEach {
      path.append(mathCircle.paths[0][$0])
    }
    selectionView.custom.path = path.cgPath
  }
}
