# <picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/prose-im/prose-app-macos/assets/1451907/56f003ff-e435-4168-8970-225bcc9e84f8" /><img src="https://github.com/prose-im/prose-app-macos/assets/1451907/15585d71-b496-4ecc-b25e-902d1fb1f079" alt="prose-app-macos" width="150" height="60" /></picture>

**Prose macOS application. Built in Swift / SwiftUI.**

The Prose project was originally announced in a blog post: [Introducing Prose, Decentralized Team Messaging in an Era of Centralized SaaS](https://prose.org/blog/introducing-prose/). This project is the macOS implementation of the Prose app.

Copyright 2022, Prose Foundation - Released under the [Mozilla Public License 2.0](./LICENSE.md).

_Tested at Swift version: `5.5.2` and Xcode version: `13.2`._

## Architecture

The Prose macOS app consists mostly of SwiftUI views, bound to core libraries, the [client](https://github.com/prose-im/prose-core-client) and the [views](https://github.com/prose-im/prose-core-views), that are common to all platforms Prose runs on.

The app uses the core client library to connect to XMPP. It calls programmatic methods in order to interact with its internal database and the network. It binds as well to an event bus to receive network events, or update events from the store. Messages are shown in their own view, which is provided by the core views library.

This decoupling makes things extremely clean, and enables common code sharing between platforms (eg. macOS, iOS, etc.).

## Design

![Prose login screen](https://user-images.githubusercontent.com/1451907/174249620-53466954-c782-4c91-b276-953aa7cca491.jpg)

![Prose main view](https://user-images.githubusercontent.com/1451907/174249677-d6c2f027-4a2a-4600-9186-45bc52b6095e.jpg)

_👉 The Prose macOS app reference design [can be found there](https://github.com/prose-im/prose-medley/blob/master/designs/app/prose-app-macos.sketch)._

## License

Licensing information can be found in the [LICENSE.md](./LICENSE.md) document.

## :fire: Report A Vulnerability

If you find a vulnerability in any Prose system, you are more than welcome to report it directly to Prose Security by sending an encrypted email to [security@prose.org](mailto:security@prose.org). Do not report vulnerabilities in public GitHub issues, as they may be exploited by malicious people to target production systems running an unpatched version.

**:warning: You must encrypt your email using Prose Security GPG public key: [:key:57A5B260.pub.asc](https://files.prose.org/public/keys/gpg/57A5B260.pub.asc).**
