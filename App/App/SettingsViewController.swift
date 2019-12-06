import MathCircleKit
import UIKit

final class SettingsViewController: UIViewController {
  let initial: Int
  let select: (Int) -> Void
  
  init(initial: Int, select: @escaping (Int) -> Void) {
    self.initial = initial
    self.select = select
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground
    
    let side: CGFloat = view.bounds.width
    let frame = CGRect(x: 0, y: 30, width: side, height: side)
    
    let settings = SettingsView(frame: frame, select: select)
    view.addSubview(settings)
    let mc = MathCircle(radius: frame.width*0.5, count: 10, countOfCircles: 2)
    settings.configure(mc, updateTo: initial)
  }
}
