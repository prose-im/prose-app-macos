//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import XCTest

// Source: https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/

public extension XCTestCase {
  @discardableResult
  func await<T: Publisher>(
    _ publisher: T,
    timeout: TimeInterval = 1,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> T.Output {
    // This time, we use Swift's Result type to keep track
    // of the result of our Combine pipeline:
    var result: Result<T.Output, Error>?
    let expectation = self.expectation(description: "Awaiting publisher")

    let cancellable = publisher.sink(
      receiveCompletion: { completion in
        switch completion {
        case let .failure(error):
          result = .failure(error)
        case .finished:
          break
        }

        expectation.fulfill()
      },
      receiveValue: { value in
        result = .success(value)
      }
    )

    // Just like before, we await the expectation that we
    // created at the top of our test, and once done, we
    // also cancel our cancellable to avoid getting any
    // unused variable warnings:
    self.wait(for: [expectation], timeout: timeout)
    cancellable.cancel()

    // Here we pass the original file and line number that
    // our utility was called at, to tell XCTest to report
    // any encountered errors at that original call site:
    let unwrappedResult = try XCTUnwrap(
      result,
      "Awaited publisher did not produce any output",
      file: file,
      line: line
    )

    return try unwrappedResult.get()
  }
}

public extension XCTestCase {
  func await<T: Publisher>(
    _ publisher: T,
    timeout: TimeInterval = 1,
    file _: StaticString = #file,
    line _: UInt = #line
  ) throws where T.Output == Never {
    var result: Error?
    let expectation = self.expectation(description: "Awaiting publisher")

    let cancellable = publisher.sink(
      receiveCompletion: { completion in
        switch completion {
        case let .failure(error):
          result = error
        case .finished:
          break
        }

        expectation.fulfill()
      },
      receiveValue: { _ in }
    )

    // Just like before, we await the expectation that we
    // created at the top of our test, and once done, we
    // also cancel our cancellable to avoid getting any
    // unused variable warnings:
    self.wait(for: [expectation], timeout: timeout)
    cancellable.cancel()

    if let error = result {
      throw error
    }
  }
}
