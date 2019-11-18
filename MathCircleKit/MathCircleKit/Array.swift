import Foundation

extension Array {
  public func rotateLeft(offset: Int) -> [Element] {
    let properOffset = offset % self.count
    let result = self[properOffset...] + self[..<properOffset]
    return Array(result)
  }

  public func tupledByTwo() -> [(Element, Element)] {
    return zip(self, rotateLeft(offset: 1)).map { ($0.0, $0.1) }.dropLast()
  }
}
