import Foundation
import PackagePlugin

// MARK: - SwiftLintPlugin

/// A SwiftLint Plugin
@main
struct SwiftLintPlugin {}

// MARK: - BuildToolPlugin

extension SwiftLintPlugin: PackagePlugin.BuildToolPlugin {
    
    /// Invoked by SwiftPM to create build commands for a particular target.
    /// The context parameter contains information about the package and its
    /// dependencies, as well as other environmental inputs.
    ///
    /// This function should create and return build commands or prebuild
    /// commands, configured based on the information in the context. Note
    /// that it does not directly run those commands.
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        let swiftLintExecutable = try context.tool(named: "swiftlint")
        return [
            .buildCommand(
                displayName: "Running SwiftLint for \(target.name)",
                executable: swiftLintExecutable.path,
                arguments: {
                    var arguments = [String]()
                    arguments.append(
                        contentsOf: [
                            "lint",
                            target.directory.string
                        ]
                    )
                    arguments.append(
                        contentsOf: [
                            "--cache-path",
                            context.pluginWorkDirectory.appending("cache").string
                        ]
                    )
                    let configurationFileName = ".swiftlint.yml"
                    let configurationPathCandidates = [
                        context.package.directory.appending(configurationFileName),
                        context.package.directory.removingLastComponent().appending(configurationFileName)
                    ]
                    for configurationPathCandidate in configurationPathCandidates {
                        if FileManager.default.fileExists(atPath: configurationPathCandidate.string) {
                            arguments.append(
                                contentsOf: [
                                    "--config",
                                    configurationPathCandidate.string
                                ]
                            )
                            break
                        }
                    }
                    return arguments
                }()
            )
        ]
    }
    
}
