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

extension Array where Element : Collection, Element.Index == Int {
  public func indices(where predicate: (Element.Iterator.Element) -> Bool) -> (Int, Int)? {
    for (i, row) in self.enumerated() {
      if let j = row.firstIndex(where: predicate) {
        return (i, j)
      }
    }
    return nil
  }
}
