//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import Foundation

public typealias JSEvaluator = (
  _ javaScriptString: String,
  _ completionHandler: @escaping ((Any?, Error?) -> Void)
) -> Void

enum JSEvaluationError: Error {
  case typeMismatch
}

@dynamicMemberLookup
struct JSClass {
  private let name: String
  private let evaluator: JSEvaluator

  init(name: String, evaluator: @escaping JSEvaluator) {
    self.name = name
    self.evaluator = evaluator
  }

  subscript<F: JSFunc>(dynamicMember funcName: String) -> F {
    F(caller: .init(funcName: "\(self.name).\(funcName)", evaluator: self.evaluator))
  }
}

public struct JSFunc1<A1: Encodable, Output>: JSFunc {
  private let caller: JSCaller

  init(caller: JSCaller) {
    self.caller = caller
  }

  @discardableResult
  public func callAsFunction(_ a1: A1) -> Future<Output, Error> {
    self.caller(self.enc(a1))
  }
}

/// A JS function that accepts a [rest parameter](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters)
public struct JSRestFunc1<A1: Encodable, Output>: JSFunc {
  private let caller: JSCaller

  init(caller: JSCaller) {
    self.caller = caller
  }

  @discardableResult
  public func callAsFunction(_ a1: A1) -> Future<Output, Error> {
    self.caller("...\(self.enc(a1))")
  }
}

public struct JSFunc2<A1: Encodable, A2: Encodable, Output>: JSFunc {
  private let caller: JSCaller

  init(caller: JSCaller) {
    self.caller = caller
  }

  @discardableResult
  public func callAsFunction(_ a1: A1, _ a2: A2) -> Future<Output, Error> {
    self.caller(self.enc(a1), self.enc(a2))
  }
}

public struct JSFunc3<A1: Encodable, A2: Encodable, A3: Encodable, Output>: JSFunc {
  private let caller: JSCaller

  init(caller: JSCaller) {
    self.caller = caller
  }

  @discardableResult
  public func callAsFunction(_ a1: A1, _ a2: A2, _ a3: A3) -> Future<Output, Error> {
    self.caller(self.enc(a1), self.enc(a2), self.enc(a3))
  }
}

protocol JSFunc {
  init(caller: JSCaller)
}

private extension JSFunc {
  func enc<T: Encodable>(_ object: T) -> String {
    let jsonData: Data
    do {
      jsonData = try JSONEncoder().encode(object)
    } catch {
      fatalError("\(object) could not be encoded to JSON")
    }
    guard let json = String(data: jsonData, encoding: .utf8) else {
      fatalError("\(object) could not be converted to String")
    }
    return json
  }
}

@dynamicCallable
struct JSCaller {
  private let funcName: String
  private let evaluator: JSEvaluator

  init(funcName: String, evaluator: @escaping JSEvaluator) {
    self.funcName = funcName
    self.evaluator = evaluator
  }

  func dynamicallyCall<T>(withArguments args: [String]) -> Future<T, Error> {
    Future { promise in
      self.evaluator("\(self.funcName)(\(args.joined(separator: ", ")))") { output, error in
        if let error = error {
          return promise(.failure(error))
        }

        guard let value = output as? T else {
          return promise(.failure(JSEvaluationError.typeMismatch))
        }

        promise(.success(value))
      }
    }
  }
}
