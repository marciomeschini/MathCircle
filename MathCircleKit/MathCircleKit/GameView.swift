import UIKit

public final class GameView: UIView {
  private(set) var mathCircle: MathCircle = MathCircle(radius: 1, count: 1, countOfCircles: 1)
  private(set) var game: Game = Game(count: 1, factor: 1)
  let pathView: CustomLayerView<CAShapeLayer>
  let coverView: CustomLayerView<CAShapeLayer>
  let correctView: CustomLayerView<CAShapeLayer>
  let errorView: CustomLayerView<CAShapeLayer>
  let selectionView: CustomLayerView<CAShapeLayer>
  let bitmapView = UIImageView()
  let label = UILabel()
  let textField = UITextField()
  private var selection: Selection?
  public var completed: (Game) -> Void = { _ in }
  
  public override init(frame: CGRect) {
    let shapeFrame = CGRect(origin: .zero, size: frame.size)
    pathView = CustomLayerView(shapeWithFrame: shapeFrame)
    coverView = CustomLayerView(shapeWithFrame: shapeFrame, fill: .white)
    correctView = CustomLayerView(shapeWithFrame: shapeFrame, fill: .green)
    errorView = CustomLayerView(shapeWithFrame: shapeFrame, fill: .red)
    selectionView = CustomLayerView(shapeWithFrame: shapeFrame, fill: UIColor.blue.withAlphaComponent(0.2))
    selectionView.custom.lineWidth = 2
    super.init(frame: frame)
    bitmapView.frame = bounds

    textField.leftView = label
    textField.leftViewMode = .always
    textField.keyboardType = .numberPad
    let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(next(_:)))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    toolbar.items = [space, nextButton]
    textField.inputAccessoryView = toolbar
    
    [correctView, bitmapView, pathView, coverView, errorView, selectionView, textField].forEach(addSubview)
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  public func configure(_ mathCircle: MathCircle, game: Game) {
    self.mathCircle = mathCircle
    self.game = game
    
    selectionView.custom.path = nil
    pathView.custom.path = background(mathCircle).cgPath
    let values = [game.values0.map(String.init), game.values1.map(String.init)]
    bitmapView.image = MidPointsImageRenderer(midPoints: mathCircle.midPoints, size: bounds.size, values: values, shouldRotate: false).image
    
    updateSlices()
    
    label.text = "\(game.factor)"
    label.sizeToFit()
    textField.frame = CGRect(x: 0, y: 0, width: 130, height: 40)
    textField.center = CGPoint(x: bounds.midX, y: bounds.midY)
  }
  
  private func updateSelection(_ selection: Selection) {
    let factor = game.values0[selection.indexes.slice]
    label.text = "\(game.factor) x \(factor) ="
    label.sizeToFit()
    let expected = game.values1[selection.indexes.slice]
    print("Expected: \(expected)")
    
    selectionView.custom.path = selection.path.cgPath
    
    let answer = game.answers[selection.indexes.slice]
    if answer == .missing {
      textField.becomeFirstResponder()
      textField.text = nil
    }
    
    self.selection = selection
  }
  
  private func isFinished() -> Bool {
    let filter: (Game.Answer) -> [Drawing] = { filter in
      return zip(self.mathCircle.slices[1], self.game.answers).filter { $0.1 == filter }.map { $0.0 }
    }
    return filter(.missing).count == 0
  }
  
  private func updateSlices() {
    // ((Drawing, Answer) -> ((Answer) -> Bool) -> [Drawing]
    let makeFilter: ([Drawing], [Game.Answer]) -> ((Game.Answer) -> Bool) -> [Drawing] = { drawings, answers in
      { f in zip(drawings, answers).filter { f($0.1) }.map { $0.0 } }
    }
    let filter = makeFilter(self.mathCircle.slices[1], self.game.answers)
    
    let missings = UIBezierPath()
    filter { $0 == .missing }.map(UIBezierPath.init).forEach(missings.append)
    coverView.custom.path = missings.cgPath
    
    let errors = UIBezierPath()
    filter {
      if case .wrong = $0 { return true }
      return false
    }.map(UIBezierPath.init).forEach(errors.append)
    errorView.custom.path = errors.cgPath
    
    let correct = UIBezierPath()
    filter { $0 == .correct }.map(UIBezierPath.init).forEach(correct.append)
    correctView.custom.path = correct.cgPath
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
    let index = selection.indexes.slice
    let answer = game.answers[index]
    if answer == .missing {
      game = game.updated(at: index, input: textField.text)
    }
    
    updateSlices()
    
    if isFinished() {
      selectionView.custom.path = nil
      completed(game)
      return
    }
    
    var nextSliceIndex = selection.indexes.slice + 1
    if nextSliceIndex >= mathCircle.count {
      nextSliceIndex = 0
    }
    let path = mathCircle.paths[selection.indexes.circle][nextSliceIndex]
    let newSelection = Selection(indexes: (selection.indexes.circle, nextSliceIndex), path: path)
    updateSelection(newSelection)
  }
  
  public func selectFirst() {
    let newSelection = Selection(indexes: (1, 0), path: mathCircle.paths[1][0])
    updateSelection(newSelection)
  }
}
