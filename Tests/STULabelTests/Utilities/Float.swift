//
//  Untitled.swift
//  STULabel
//
//  Created by Jesse Halley on 25/8/2026.
//

import Testing

func expectApproximatelyEqual<T: BinaryFloatingPoint>(
  _ lhs: T, _ rhs: T, tolerance: T, sourceLocation: SourceLocation = #_sourceLocation
) {
  #expect(abs(lhs - rhs) <= tolerance, sourceLocation: sourceLocation)
}
