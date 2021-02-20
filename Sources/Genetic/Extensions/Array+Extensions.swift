//
//  Array+Extensions.swift
//  Nameley
//
//  Created by William Vabrinskas on 12/23/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

public extension Collection where Element: Equatable, Index == Int {
  
  func halve() -> [[Self.Element]] {
    let half = self.count / 2
    let leftHalf = Array(self[0..<half])
    let rightHalf = Array(self[half..<self.count])
    return [leftHalf, rightHalf]
  }
  
  func slice(into num: Int) -> [[Self.Element]] {
    guard num <= self.count else {
      return []
    }
    
    var slices: [[Element]] = []

    let strideBy = Int(self.count / num)
    stride(from: 0, to: count, by: strideBy).forEach { (result) in
      if result + strideBy >= count {
        if var lastSlice = slices.last {
          lastSlice.append(contentsOf: Array(self[result..<count]))
          slices.removeLast()
          slices.append(lastSlice)
        }
      } else {
        let slice = Array(self[result..<Swift.min(result + strideBy, count)])
        slices.append(slice)
      }
    }
    return slices
  }
  
  func batched(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
  /// Get a copy of self but with randomized data indexes
  /// - Returns: Returns Self but with the data randomized
  func randomize() -> [Self.Element] {
    let arrayCopy = self
    var randomArray: [Element] = []
    
    for _ in 0..<self.count {
      guard let element = arrayCopy.randomElement() else {
        break
      }
      
      if !randomArray.contains(where: { $0 == element }) {
        randomArray.append(element)
      }

    }
    
    return randomArray
  }

}
