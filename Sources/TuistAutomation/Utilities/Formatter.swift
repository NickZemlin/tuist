import Foundation
import TuistCore
import TuistSupport
import XcbeautifyLib

protocol Formatting {
    func format(_ line: String) -> String?
}

final class Formatter: Formatting {
    private let formatter: XCBeautifier

    init() {
        formatter = XCBeautifier(
            colored: TuistContext.shared.environment.shouldOutputBeColoured,
            renderer: Self.renderer(),
            preserveUnbeautifiedLines: false,
            additionalLines: { nil }
        )
    }

    func format(_ line: String) -> String? {
        formatter.format(line: line)
    }

    private static func renderer() -> Renderer {
        if TuistContext.shared.environment.isGitHubActions {
            return .gitHubActions
        } else {
            return .terminal
        }
    }
}
