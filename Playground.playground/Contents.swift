import MathCircleKit
import UIKit
import PlaygroundSupport

let vc = UIViewController()
PlaygroundPage.current.liveView = vc
vc.view.backgroundColor = .white

let side: CGFloat = 375
let frame = CGRect(x: 0, y: 150, width: side, height: side)
let rootView = shapeLayerView(frame: frame)
vc.view.addSubview(rootView)
let stagingView = shapeLayerView(frame: frame, stroke: .red, fill: UIColor.blue.withAlphaComponent(0.2))
stagingView.customLayer.lineWidth = 2
vc.view.addSubview(stagingView)

// MARK: - SUT

let center = CGPoint(x: side*0.5, y: side*0.5)
let count = 12

let mathCircle = MathCircle(
  side: side-10,
  center: center,
  count: count,
  countOfCircles: 3
)

// MARK: - Root

let path = UIBezierPath()
path.append(UIBezierPath(rect: rootView.bounds))
path.append(background(mathCircle))
rootView.customLayer.path = path.cgPath

// MARK: - Staging

let staging = UIBezierPath()

//mathCircle.slices.flatMap { $0 }.forEach(staging.append)
//mathCircle.paths.flatMap { $0 }.forEach(staging.append)
//mathCircle.midPoints.flatMap { $0 }.map { Drawing.dot($0) }.forEach(staging.append)

// MARK: - Labels

let label: (MidPoint, Int) -> UILabel = { mp, index in
  let label = UILabel(frame: CGRect(x: 0, y: 0, width: 28, height: 24))
  label.center = mp.point
  label.text = "\(index)"
  label.textAlignment = .center
  label.transform = .init(rotationAngle: mp.t)
//  label.layer.borderWidth = 0.5
  return label
}

let labels = mathCircle.midPoints.map { midPoint in
  return midPoint.enumerated().map { offset, p in
    return label(p, offset)
  }
}
labels.forEach { $0.forEach(rootView.addSubview) }

let values1 = (1...mathCircle.values.count).map { $0 }
//labels.enumerated().forEach { offset, ring in
//  let values2 = values1.map { $0*(offset+1) }
//  zip(ring, values2).forEach { $0.0.text = "\($0.1)" }
//}
zip(labels[0], values1).forEach { $0.0.text = "\($0.1)" }

let values2 = values1.map { $0*3 }
zip(labels[1], values2).forEach { $0.0.text = "\($0.1)" }
labels[1].forEach { $0.isHidden = true }

let mainLabel = label(MidPoint(point: center, t: 0), 3)
mainLabel.font = UIFont.boldSystemFont(ofSize: 40)
mainLabel.sizeToFit()
mainLabel.center = center
rootView.addSubview(mainLabel)



class Object {
  @objc func tap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: sender.view)
    print(point)
    guard let selection = selectedPath(from: mathCircle.paths, at: point) else {
      return
    }
    print(selection)

    let path = UIBezierPath(cgPath: stagingView.customLayer.path ?? UIBezierPath().cgPath)
    let new = UIBezierPath(cgPath: path.cgPath)
    new.append(selection.path)
    stagingView.customLayer.path = new.cgPath
    
    if selection.indexes.circle != 0 {
      labels[selection.indexes.circle][selection.indexes.slice].isHidden = false
    }
  }
}

let object = Object()
let gesture = UITapGestureRecognizer(target: object, action: #selector(Object.tap(_:)))
stagingView.addGestureRecognizer(gesture)

stagingView.customLayer.path = staging.cgPath


