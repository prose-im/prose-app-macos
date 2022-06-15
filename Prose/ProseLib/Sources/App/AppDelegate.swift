//
//  AppDelegate.swift
//  Prose
//
//  Created by Rémi Bardon on 09/06/2022.
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}
