//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import OSLog

internal let logger = Logger(subsystem: "org.prose.app", category: "conversation")
internal let jsLogger = Logger(subsystem: "org.prose.app", category: "js-ffi")
internal let signposter = OSSignposter(logger: logger)
