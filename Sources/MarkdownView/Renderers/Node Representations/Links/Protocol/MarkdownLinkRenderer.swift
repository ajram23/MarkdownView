//
//  MarkdownLinkRenderer.swift
//  MarkdownView
//
//  Orbit fork addition. Mirrors `MarkdownImageRenderer` so consumers can
//  inject a custom view for inline links (e.g. favicon + URL hover tooltip).
//

import SwiftUI

/// A type that renders inline markdown links.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a
/// separate view instead.
@preconcurrency
@MainActor
public protocol MarkdownLinkRenderer {
    /// A type that represents the link.
    associatedtype Body: View

    /// Creates a view that represents the link.
    /// - parameter configuration: The properties of a markdown link, including
    ///   the destination `URL` and the already-styled default `label` view
    ///   (text + inline images + inline code as the library would render it).
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// The properties of a markdown link.
    typealias Configuration = MarkdownLinkRendererConfiguration
}

/// The properties of a markdown link.
///
/// NOT `Sendable` — `label: AnyView` cannot be. Apple explicitly marks
/// `AnyView: Sendable` as `@available(*, unavailable)` in
/// `SwiftUICore.swiftinterface`. The image renderer's equivalent
/// (`MarkdownImageRendererConfiguration`) is `Sendable` only because its
/// fields are `URL + String?`. The renderer protocol above is
/// `@preconcurrency @MainActor` so the configuration never crosses an actor
/// boundary — `Sendable` isn't required.
public struct MarkdownLinkRendererConfiguration {
    /// The destination URL of the link.
    public var url: URL
    /// The already-styled default link contents (text, inline images,
    /// inline code, etc.) as the library would render them without a
    /// custom renderer. Wrap this in your custom view to preserve the
    /// surrounding inline formatting.
    public var label: AnyView
}

// MARK: - Type Erasure

/// A type-erasure for type conforms to `MarkdownLinkRenderer`.
public struct AnyMarkdownLinkRenderer: MarkdownLinkRenderer {
    public typealias Body = AnyView

    private let _makeBody: (Configuration) -> Body

    public init<D: MarkdownLinkRenderer>(erasing renderer: D) {
        _makeBody = {
            renderer
                .makeBody(configuration: $0)
                .erasedToAnyView()
        }
    }

    public init<D: MarkdownLinkRenderer>(_ renderer: D) {
        _makeBody = {
            renderer
                .makeBody(configuration: $0)
                .erasedToAnyView()
        }
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}
