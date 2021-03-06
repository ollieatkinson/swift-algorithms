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

import XCTest
@testable import Algorithms

final class ChainTests: XCTestCase {
  // intentionally does not depend on `Chain.index(_:offsetBy:)` in order to
  // avoid making assumptions about the code being tested
  func index<A, B>(atOffset offset: Int, in chain: Chain<A, B>) -> Chain<A, B>.Index {
    offset < chain.base1.count
      ? .init(first: chain.base1.index(chain.base1.startIndex, offsetBy: offset))
      : .init(second: chain.base2.index(chain.base2.startIndex, offsetBy: offset - chain.base1.count))
  }
  
  func testChainSequences() {
    let run = (1...).prefix(10).chained(with: 20...)
    XCTAssertEqualSequences(run.prefix(20), Array(1...10) + (20..<30))
  }
  
  func testChainForwardCollection() {
    let s1 = Set(0...10)
    let s2 = Set(20...30)
    let c = s1.chained(with: s2)
    XCTAssertEqualSequences(c, Array(s1) + Array(s2))
  }
  
  func testChainBidirectionalCollection() {
    let s1 = "ABCDEFGHIJ"
    let s2 = "klmnopqrstuv"
    let c = s1.chained(with: s2)
    
    XCTAssertEqualSequences(c, "ABCDEFGHIJklmnopqrstuv")
    XCTAssertEqualSequences(c.reversed(), "ABCDEFGHIJklmnopqrstuv".reversed())
    XCTAssertEqualSequences(s1.reversed().chained(with: s2), "JIHGFEDCBAklmnopqrstuv")
  }
  
  // TODO: Add tests that check index(offsetBy:)
  
  func testChainDistanceFromTo() {
    let s1 = "abcde"
    let s2 = "VWXYZ"
    let chain = s1.chained(with: s2)
    
    XCTAssertEqual(chain.count, s1.count + s2.count)
    
    for (startOffset, endOffset) in product(0...chain.count, 0...chain.count) {
      let start = index(atOffset: startOffset, in: chain)
      let end = index(atOffset: endOffset, in: chain)
      let distance = endOffset - startOffset
      XCTAssertEqual(chain.distance(from: start, to: end), distance)
    }
  }
}
