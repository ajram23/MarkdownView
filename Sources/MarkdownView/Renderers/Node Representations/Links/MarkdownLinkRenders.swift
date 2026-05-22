//
//  MarkdownLinkRenders.swift
//  MarkdownView
//
//  Orbit fork addition. Singleton registry of link renderers keyed by URL
//  scheme. Mirrors `MarkdownImageRenders` but adds a `"*"` wildcard lookup
//  so a single renderer can handle every URL scheme without enumeration.
//

import SwiftUI

class MarkdownLinkRenders: @unchecked Sendable {
    static let shared: MarkdownLinkRenders = .init()

    private init() { }

    /// All the renderers that have been added.
    private(set) var renderers: [String: any MarkdownLinkRenderer] = [:]

    /// Add custom renderer for link rendering.
    /// - Parameters:
    ///   - renderer: A link renderer that builds a view from a URL + label.
    ///   - urlScheme: The url scheme to use the renderer. Use `"*"` to
    ///     register a wildcard renderer that handles every scheme.
    func addRenderer(
        _ renderer: some MarkdownLinkRenderer, forURLScheme urlScheme: String
    ) {
        self.renderers[urlScheme] = renderer
    }

    /// Lookup order: exact scheme → lowercased scheme → `"*"` wildcard.
    static func named(_ name: String) -> (any MarkdownLinkRenderer)? {
        let store = MarkdownLinkRenders.shared
        if let renderer = store.renderers[name] {
            return renderer
        }

        let lowercaseName = name.lowercased()
        if let renderer = store.renderers
            .first(where: { $0.key.lowercased() == lowercaseName })?
            .value
        {
            return renderer
        }

        return store.renderers["*"]
    }
}
