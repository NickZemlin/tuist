import Foundation
import TuistAcceptanceTesting
import TuistSupport
import TuistSupportTesting
import XCTest

@testable import TuistKit
@testable import TuistServer

final class ShareAcceptanceTestIosAppWithFrameworks: ServerAcceptanceTestCase {
    func test_share_ios_app_with_frameworks() async throws {
        try await setUpFixture(.iosAppWithFrameworks)
        try await run(BuildCommand.self)
        try await run(ShareCommand.self)
        let shareLink = try shareLink()
        try await run(RunCommand.self, shareLink, "-destination", "iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "Installing and launching App on iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "App was successfully launched 📲")
    }
}

final class ShareAcceptanceTestMultiplatformAppWithExtension: ServerAcceptanceTestCase {
    func test_share_multiplatform_app_with_extension() async throws {
        try await setUpFixture(.multiplatformAppWithExtension)
        try await run(BuildCommand.self, "App", "--platform", "visionos")
        try await run(BuildCommand.self, "App", "--platform", "ios")
        try await run(ShareCommand.self, "App")
        let shareLink = try shareLink()
        try await run(RunCommand.self, shareLink, "-destination", "Apple Vision Pro")
        XCTAssertStandardOutput(pattern: "Installing and launching App on Apple Vision Pro")
        XCTAssertStandardOutput(pattern: "App was successfully launched 📲")
        TestingLogHandler.reset()
        try await run(RunCommand.self, shareLink, "-destination", "iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "Installing and launching App on iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "App was successfully launched 📲")
    }
}

final class ShareAcceptanceTestXcodeApp: ServerAcceptanceTestCase {
    func test_share_xcode_app() async throws {
        try await setUpFixture(.xcodeApp)
        try System.shared.runAndPrint(
            [
                "/usr/bin/xcrun",
                "xcodebuild",
                "clean",
                "build",
                "-project",
                fixturePath.appending(component: "App.xcodeproj").pathString,
                "-scheme",
                "App",
                "-sdk",
                "iphonesimulator",
                "-derivedDataPath",
                derivedDataPath.pathString,
            ]
        )
        try await run(ShareCommand.self, "App", "--platforms", "ios")
        try await run(RunCommand.self, try shareLink(), "-destination", "iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "Installing and launching App on iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "App was successfully launched 📲")
    }

    func test_share_xcode_app_files() async throws {
        try await setUpFixture(.xcodeApp)
        let buildDirectory = fixturePath.appending(component: "Build")
        try System.shared.runAndPrint(
            [
                "/usr/bin/xcrun",
                "xcodebuild",
                "clean",
                "build",
                "-project",
                fixturePath.appending(component: "App.xcodeproj").pathString,
                "-scheme",
                "App",
                "-sdk",
                "iphonesimulator",
                "-derivedDataPath",
                derivedDataPath.pathString,
                "CONFIGURATION_BUILD_DIR=\(buildDirectory)",
            ]
        )

        // Testing sharing `.app` file directly
        try await run(
            ShareCommand.self,
            buildDirectory.appending(component: "App.app").pathString,
            "--platforms", "ios"
        )
        try await run(RunCommand.self, try shareLink(), "-destination", "iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "Installing and launching App on iPhone 15 Pro")
        XCTAssertStandardOutput(pattern: "App was successfully launched 📲")
    }
}

extension ServerAcceptanceTestCase {
    fileprivate func shareLink() throws -> String {
        try XCTUnwrap(
            TestingLogHandler.collected[.notice, >=]
                .components(separatedBy: .newlines)
                .first(where: { $0.contains("App uploaded – share") })?
                .components(separatedBy: .whitespaces)
                .last
        )
    }
}
