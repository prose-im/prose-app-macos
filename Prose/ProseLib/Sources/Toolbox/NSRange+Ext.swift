//
//  File.swift
//  
//
//  Created by Rémi Bardon on 30/08/2022.
//

import Foundation

public extension NSRange {
  func prose_withOffset(_ locationOffset: Int, in enclosingRange: NSRange) -> NSRange {
    let range = NSRange(location: self.location + locationOffset, length: self.length)
    assert(
      enclosingRange.lowerBound <= range.lowerBound,
      "\(enclosingRange.lowerBound) > \(range.lowerBound)"
    )
    assert(
      enclosingRange.upperBound >= range.upperBound,
      "\(enclosingRange.upperBound) < \(range.upperBound)"
    )
    return range
  }
  mutating func prose_offset(by locationOffset: Int, in enclosingRange: NSRange) {
    self = self.prose_withOffset(locationOffset, in: enclosingRange)
  }
  func prose_extended(by lengthOffset: Int, in enclosingRange: NSRange) -> NSRange {
    let range = NSRange(location: self.location, length: self.length + lengthOffset)
    assert(
      enclosingRange.lowerBound <= range.lowerBound,
      "\(enclosingRange.lowerBound) > \(range.lowerBound)"
    )
    assert(
      enclosingRange.upperBound >= range.upperBound,
      "\(enclosingRange.upperBound) < \(range.upperBound)"
    )
    return range
  }
  mutating func prose_extend(by lengthOffset: Int, in enclosingRange: NSRange) {
    self = self.prose_extended(by: lengthOffset, in: enclosingRange)
  }
}

public extension Optional where Wrapped == NSRange {
  func prose_withOffset(_ locationOffset: Int, in enclosingRange: NSRange) -> NSRange {
    self?.prose_withOffset(locationOffset, in: enclosingRange) ?? {
      if locationOffset < 0 {
        return NSRange(location: enclosingRange.upperBound + locationOffset, length: 0)
      } else {
        return NSRange(location: enclosingRange.lowerBound + locationOffset, length: 0)
      }
    }()
  }
  mutating func prose_offset(by locationOffset: Int, in enclosingRange: NSRange) {
    self = self.prose_withOffset(locationOffset, in: enclosingRange)
  }
  func prose_extended(by lengthOffset: Int, in enclosingRange: NSRange) -> NSRange {
    self?.prose_extended(by: lengthOffset, in: enclosingRange) ?? {
      if lengthOffset < 0 {
        return NSRange(location: enclosingRange.upperBound + lengthOffset, length: -lengthOffset)
      } else {
        return NSRange(location: enclosingRange.lowerBound, length: lengthOffset)
      }
    }()
  }
  mutating func prose_extend(by lengthOffset: Int, in enclosingRange: NSRange) {
    self = self.prose_extended(by: lengthOffset, in: enclosingRange)
  }
}
