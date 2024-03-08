import Foundation
import TSCBasic
import TuistKit
import TuistLoader
import TuistSupport

@main
@_documentation(visibility: private)
private enum TuistApp {
    static func main() async throws {
        if CommandLine.arguments.contains("--verbose") {
            try? ProcessEnv.setVar(Constants.EnvironmentVariables.verbose, value: "true")
        }

        TuistSupport.LogOutput.bootstrap()

        try TuistSupport.TuistContext.initializeSharedInstace()

        await TuistCommand.main()
    }
}
