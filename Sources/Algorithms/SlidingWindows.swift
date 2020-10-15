//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// slidingWindows(ofCount:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// A collection for all contiguous windows of length size, the
  /// windows overlap.
  ///
  /// - Complexity: O(*1*) if the collection conforms to
  /// `RandomAccessCollection`, otherwise O(*k*) where `k` is `count`.
  /// Access to the next window is O(*1*).
  ///
  /// - Parameter count: The number of elements in each window subsequence.
  ///
  /// - Returns: If the collection is shorter than `size` the resulting
  /// SlidingWindows collection will be empty.
  public func slidingWindows(ofCount count: Int) -> SlidingWindows<Self> {
    SlidingWindows(base: self, size: count)
  }
}

public struct SlidingWindows<Base: Collection> {
  
  public let base: Base
  public let size: Int
  
  private var firstUpperBound: Base.Index?

  init(base: Base, size: Int) {
    precondition(size > 0, "SlidingWindows size must be greater than zero")
    self.base = base
    self.size = size
    self.firstUpperBound = base.index(base.startIndex, offsetBy: size, limitedBy: base.endIndex)
  }
}

extension SlidingWindows: Collection {
  
  public struct Index: Comparable {
    internal var lowerBound: Base.Index
    internal var upperBound: Base.Index
    public static func == (lhs: Index, rhs: Index) -> Bool {
      lhs.lowerBound == rhs.lowerBound
    }
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.lowerBound < rhs.lowerBound
    }
  }
  
  public var startIndex: Index {
    if let upperBound = firstUpperBound {
      return Index(lowerBound: base.startIndex, upperBound: upperBound)
    } else {
      return endIndex
    }
  }
  
  public var endIndex: Index {
    Index(lowerBound: base.endIndex, upperBound: base.endIndex)
  }
  
  public subscript(index: Index) -> Base.SubSequence {
    precondition(index.lowerBound != index.upperBound, "SlidingWindows index is out of range")
    return base[index.lowerBound..<index.upperBound]
  }
  
  public func index(after index: Index) -> Index {
    precondition(index < endIndex, "Advancing past end index")
    guard index.upperBound < base.endIndex else { return endIndex }
    return Index(
      lowerBound: base.index(after: index.lowerBound),
      upperBound: base.index(after: index.upperBound)
    )
  }
  
  // TODO: Implement distance(from:to:), index(_:offsetBy:) and
  // index(_:offsetBy:limitedBy:)

}

extension SlidingWindows: BidirectionalCollection where Base: BidirectionalCollection {
  public func index(before index: Index) -> Index {
    precondition(index > startIndex, "Incrementing past start index")
    if index == endIndex {
      return Index(
        lowerBound: base.index(index.lowerBound, offsetBy: -size),
        upperBound: index.upperBound
      )
    } else {
      return Index(
        lowerBound: base.index(before: index.lowerBound),
        upperBound: base.index(before: index.upperBound)
      )
    }
  }
}

extension SlidingWindows: RandomAccessCollection where Base: RandomAccessCollection {}
extension SlidingWindows: Equatable where Base: Equatable {}
extension SlidingWindows: Hashable where Base: Hashable, Base.Index: Hashable {}
extension SlidingWindows.Index: Hashable where Base.Index: Hashable {}
