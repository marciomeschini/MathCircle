import UIKit

public final class GameView: UIView {
  private(set) var mathCircle: MathCircle = MathCircle(side: 1, center: .zero, count: 1, countOfCircles: 1)
  private(set) var game: Game = Game(count: 1, factor: 1)
  let pathView: ShapeLayerView
  let coverView: ShapeLayerView
  let correctView: ShapeLayerView
  let errorView: ShapeLayerView
  let selectionView: ShapeLayerView
  let bitmapView = UIImageView()
  let label = UILabel()
  let textField = UITextField()
  private var selection: Selection?
  public var completed: (Game) -> Void = { _ in }
  
  public override init(frame: CGRect) {
    pathView = shapeLayerView(frame: CGRect(origin: .zero, size: frame.size))
    coverView = shapeLayerView(
      frame: CGRect(origin: .zero, size: frame.size),
      stroke: .black,
      fill: UIColor.white//.withAlphaComponent(0.75)
    )
    correctView = shapeLayerView(
      frame: CGRect(origin: .zero, size: frame.size),
      stroke: .black,
      fill: .green
    )
    errorView = shapeLayerView(
      frame: CGRect(origin: .zero, size: frame.size),
      stroke: .black,
      fill: .red
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
    [correctView, bitmapView, pathView, coverView, errorView, selectionView, textField].forEach(addSubview)
    
    let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
    addGestureRecognizer(gesture)
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  public func configure(_ mathCircle: MathCircle, game: Game) {
    self.mathCircle = mathCircle
    self.game = game
    selectionView.customLayer.path = nil
    
    let path = UIBezierPath()
    path.append(background(mathCircle))
    pathView.customLayer.path = path.cgPath
    
    bitmapView.image = makeBitmap(mathCircle: mathCircle, game: game, size: bounds.size)
    
    updateCovers()
    
    label.text = "\(game.factor)"
    label.sizeToFit()
    textField.frame = CGRect(x: 0, y: 0, width: 130, height: 40)
    textField.center = CGPoint(x: bounds.midX, y: bounds.midY)
//    [textField, label].forEach { $0.layer.borderWidth = 1 }
    
    let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(next(_:)))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    toolbar.items = [space, nextButton]
    textField.inputAccessoryView = toolbar
    
    selectFirst()
  }
  
  private func updateSelection(_ selection: Selection) {
    let factor = game.values0[selection.indexes.slice]
    label.text = "\(game.factor) x \(factor) ="
    label.sizeToFit()
    let expected = game.values1[selection.indexes.slice]
    print("Expected: \(expected)")
    
    let path = UIBezierPath()
    let new = UIBezierPath(cgPath: path.cgPath)
    new.append(selection.path)
    selectionView.customLayer.path = new.cgPath
    
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
  
  private func updateCovers() {
    let filter: (Game.Answer) -> [Drawing] = { filter in
      return zip(self.mathCircle.slices[1], self.game.answers).filter { $0.1 == filter }.map { $0.0 }
    }
    
    let missings = UIBezierPath()
    filter(.missing).map(UIBezierPath.init).forEach(missings.append)
    coverView.customLayer.path = missings.cgPath
    
    let errors = UIBezierPath()
    let wrong = zip(self.mathCircle.slices[1], self.game.answers).filter { tuple in
      if case .wrong = tuple.1 { return true }
      return false
    }.map { $0.0 }
    wrong.forEach(errors.append)
    errorView.customLayer.path = errors.cgPath
    
    let correct = UIBezierPath()
    filter(.correct).map(UIBezierPath.init).forEach(correct.append)
    correctView.customLayer.path = correct.cgPath
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
      let expected = game.values1[index]
      print("Expected: \(expected)")
      print("Input: \(textField.text ?? "")")
      let answer = Game.Answer(value: textField.text ?? "", expected: expected)
      game.answers[index] = answer
      print(answer)
    }
    
    updateCovers()
    
    if isFinished() {
      print("isFinished!")
      completed(game)
      return
    }
    
    var nextSliceIndex = selection.indexes.slice + 1
    if nextSliceIndex >= mathCircle.count {
      nextSliceIndex = 0
    }
    let slice = mathCircle.slices[selection.indexes.circle][nextSliceIndex]
    let path = UIBezierPath(slice)
    let newSelection = Selection(indexes: (selection.indexes.circle, nextSliceIndex), path: path)

    updateSelection(newSelection)
  }
  
  private func selectFirst() {
    let slice = mathCircle.slices[1][0]
    let path = UIBezierPath(slice)
    let newSelection = Selection(indexes: (1, 0), path: path)

    updateSelection(newSelection)
  }
}
