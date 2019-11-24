import UIKit

public final class GameView: UIView {
  private(set) var mathCircle: MathCircle = MathCircle(side: 1, center: .zero, count: 1, countOfCircles: 1)
  private(set) var game: Game = Game(count: 1, factor: 1)
  let pathView: ShapeLayerView
  let coverView: ShapeLayerView
  let selectionView: ShapeLayerView
  let bitmapView = UIImageView()
  let label = UILabel()
  let textField = UITextField()
  private var selection: Selection?
  
  public override init(frame: CGRect) {
    pathView = shapeLayerView(frame: CGRect(origin: .zero, size: frame.size))
    coverView = shapeLayerView(
      frame: CGRect(origin: .zero, size: frame.size),
      stroke: .black,
      fill: UIColor.white.withAlphaComponent(0.75)
    )
    selectionView = shapeLayerView(
      frame: CGRect(origin: .zero, size: frame.size),
      stroke: .red,
      fill: UIColor.blue.withAlphaComponent(0.2)
    )
    selectionView.customLayer.lineWidth = 2
    super.init(frame: frame)
    bitmapView.frame = bounds

    textField.leftView = label
    textField.leftViewMode = .always
    textField.keyboardType = .numberPad
    [bitmapView, pathView, coverView, selectionView, textField].forEach(addSubview)
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
    addGestureRecognizer(gesture)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  public func configure(_ mathCircle: MathCircle, game: Game) {
    self.mathCircle = mathCircle
    self.game = game
    
    let path = UIBezierPath()
    path.append(UIBezierPath(rect: bounds))
    path.append(background(mathCircle))
    pathView.customLayer.path = path.cgPath
    
    bitmapView.image = makeBitmap(mathCircle: mathCircle, game: game, size: bounds.size)
    
    let slices = mathCircle.slices[1]
    let paths = slices.map(UIBezierPath.init)
    let merged = UIBezierPath()
    paths.forEach(merged.append)
    coverView.customLayer.path = merged.cgPath
    
    label.text = "\(game.factor)"
    label.sizeToFit()
    textField.frame = CGRect(x: 0, y: 0, width: 130, height: 40)
    textField.center = CGPoint(x: bounds.midX, y: bounds.midY)
    [textField, label].forEach { $0.layer.borderWidth = 1 }
//    label.center = CGPoint(x: bounds.midX, y: bounds.midY)
    
    let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(next(_:)))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    toolbar.items = [space, nextButton]
    textField.inputAccessoryView = toolbar
  }
  
  private func updateSelection(_ selection: Selection) {
//    guard let selection = self.selection else { return }
    let factor = game.values0[selection.indexes.slice]
    label.text = "\(game.factor) x \(factor) ="
    label.sizeToFit()
    let expected = game.values1[selection.indexes.slice]
    print("Expected: \(expected)")
    
    let path = UIBezierPath()
    let new = UIBezierPath(cgPath: path.cgPath)
    new.append(selection.path)
    selectionView.customLayer.path = new.cgPath
    
    textField.becomeFirstResponder()
    textField.text = nil
    
    self.selection = selection
  }
  
  @objc func tap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: sender.view)
    print(point)
    guard let selection = selectedPath(from: mathCircle.paths, at: point) else {
      return
    }
    print(selection.indexes)
    
    guard selection.indexes.circle == 1 else { return }
    updateSelection(selection)
  }
  
  @objc func next(_ sender: UIBarButtonItem) {
    guard let selection = self.selection else { return }
    // evaluate current answer
    let expected = game.values1[selection.indexes.slice]
    print("Expected: \(expected)")
    print("Input: \(textField.text ?? "")")
    
    var nextSliceIndex = selection.indexes.slice + 1
    if nextSliceIndex >= mathCircle.count {
      nextSliceIndex = 0
    }
    let slice = mathCircle.slices[selection.indexes.circle][nextSliceIndex]
    let path = UIBezierPath(slice)
    let newSelection = Selection(indexes: (selection.indexes.circle, nextSliceIndex), path: path)
//    self.selection = newSelection
    updateSelection(newSelection)
  }
}
