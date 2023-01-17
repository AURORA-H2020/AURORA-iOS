import Foundation
import PackagePlugin

// MARK: - SwiftGenPlugin

/// A SwiftGen Plugin
@main
struct SwiftGenPlugin {}

// MARK: - BuildToolPlugin

extension SwiftGenPlugin: PackagePlugin.BuildToolPlugin {
    
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
        let swiftGenExecutable = try context.tool(named: "swiftgen")
        return [
            context.package.directory.removingLastComponent(),
            context.package.directory,
            target.directory
        ]
        .map { $0.appending("swiftgen.yml") }
        .map(\.string)
        .filter(FileManager.default.fileExists)
        .map { configurationPath in
            .prebuildCommand(
                displayName: "Running SwiftGen for \(target.name) using \(configurationPath)",
                executable: swiftGenExecutable.path,
                arguments: [
                    "config",
                    "run",
                    "--config",
                    configurationPath
                ],
                environment: [
                    "PROJECT_DIR": context.package.directory.string,
                    "TARGET_NAME": target.name,
                    "DERIVED_SOURCES_DIR": context.pluginWorkDirectory.string
                ],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        }
    }
    
}
