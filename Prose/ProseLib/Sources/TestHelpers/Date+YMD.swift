//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation

public extension Date {
  static func ymd(
    _ year: Int,
    _ month: Int,
    _ day: Int,
    _ hour: Int = 0,
    _ minute: Int = 0,
    _ second: Int = 0,
    timeZone: TimeZone? = nil
  ) -> Date {
    let components = DateComponents(
      timeZone: timeZone,
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second
    )
    return Calendar.current.date(from: components)!
  }
}
