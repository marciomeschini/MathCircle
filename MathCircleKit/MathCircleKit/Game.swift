import UIKit

public struct Game {
  public let count: Int
  public let factor: Int
  public let values0: [Int]
  public let values1: [Int]
  public let answers: [Answer]
    
  func updated(at index: Int, input: String?) -> Game {
    let expected = values1[index]
    var new = answers
    let answer = Game.Answer(value: input ?? "", expected: expected)
    new[index] = answer
    return Game(
      count: count,
      factor: factor,
      values0: values0,
      values1: values1,
      answers: new
    )
  }
}

extension Game {
  public enum Answer: Equatable {
    case correct
    case missing
    case wrong(Int)
  }
  
  public init(count: Int, factor: Int) {
    self.count = count
    self.factor = factor
    values0 = (1...count).map { $0 }.shuffled()
    values1 = values0.map { $0 * factor }
    answers = values1.map { _ in .missing }
  }
}

extension Game.Answer {
  init(value: String, expected: Int) {
    switch value {
    case "\(expected)": self = .correct
    case "":            self = .missing
    default:            self = .wrong(Int(value) ?? -1) // :-[
    }
  }
}
