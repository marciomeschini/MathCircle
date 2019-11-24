//
//  ViewController.swift
//  App
//
//  Created by Marco Meschini on 18/11/2019.
//  Copyright © 2019 Marco Meschini. All rights reserved.
//
import MathCircleKit
import UIKit



class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white

    let side: CGFloat = view.bounds.width
    let frame = CGRect(x: 0, y: 20, width: side, height: side)
    let rootView = GameView(frame: frame)
    view.addSubview(rootView)

    
    let center = CGPoint(x: side*0.5, y: side*0.5)
    let count = 7

    let mathCircle = MathCircle(
      side: side-10,
      center: center,
      count: count,
      countOfCircles: 3
    )
    let game = Game(count: count, factor: 4)

    rootView.configure(mathCircle, game: game)
  }
}

