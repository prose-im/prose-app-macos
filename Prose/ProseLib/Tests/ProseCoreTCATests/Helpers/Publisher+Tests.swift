import Combine
import Foundation
import XCTest

extension Publisher where Output: Equatable {
    func collectInto(
        sink: TestSink<Output>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> AnyCancellable {
        self.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    XCTFail(error.localizedDescription, file: file, line: line)
                }
            },
            receiveValue: { value in
                sink.values.append(value)
            }
        )
    }
}

final class TestSink<T: Equatable> {
    fileprivate(set) var values = [T]()
}
