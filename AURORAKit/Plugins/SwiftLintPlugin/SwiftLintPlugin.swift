import Foundation
import PackagePlugin

// MARK: - SwiftLintPlugin

/// A SwiftLint Plugin
@main
struct SwiftLintPlugin {}

// MARK: - Call-as-Function

extension SwiftLintPlugin {
    
    /// Call `SwiftLintPlugin` as function to receive a PackagePlugin Command.
    /// - Parameters:
    ///   - executable: A closure providing an executable Tool by a name.
    ///   - targetName: The name of the target.
    ///   - targetDirectory: The directory path of the target.
    ///   - pluginWorkDirectory: The work directory path of the plugin.
    ///   - packageDirectory: The directory path of the package.
    ///   - fileManager: The file manager. Default value `.default`
    /// - Returns: A PackagePlugin Command.
    func callAsFunction(
        executable: (String) throws -> PackagePlugin.PluginContext.Tool,
        targetName: String,
        targetDirectory: PackagePlugin.Path,
        pluginWorkDirectory: PackagePlugin.Path,
        packageDirectory: PackagePlugin.Path,
        fileManager: FileManager = .default
    ) throws -> PackagePlugin.Command {
        .buildCommand(
            displayName: "Running SwiftLint for \(targetName)",
            executable: try executable("swiftlint").path,
            arguments: {
                var arguments = [String]()
                arguments.append(
                    contentsOf: [
                        "lint",
                        targetDirectory.string
                    ]
                )
                arguments.append(
                    contentsOf: [
                        "--cache-path",
                        pluginWorkDirectory.appending("cache").string
                    ]
                )
                let configurationFileName = ".swiftlint.yml"
                let configurationPathCandidates = [
                    packageDirectory.appending(configurationFileName),
                    packageDirectory.removingLastComponent().appending(configurationFileName)
                ]
                for configurationPathCandidate in configurationPathCandidates {
                    if fileManager.fileExists(atPath: configurationPathCandidate.string) {
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
    }
    
}

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
        [
            try self(
                executable: context.tool,
                targetName: target.name,
                targetDirectory: target.directory,
                pluginWorkDirectory: context.pluginWorkDirectory,
                packageDirectory: context.package.directory
            )
        ]
    }
    
}
