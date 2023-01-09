import Foundation
import PackagePlugin

// MARK: - SwiftGenPlugin

/// A SwiftGen Plugin
@main
struct SwiftGenPlugin {}

// MARK: - Call-as-Function

extension SwiftGenPlugin {
    
    /// Call `SwiftGenPlugin` as function to receive a PackagePlugin Command.
    /// - Parameters:
    ///   - executable: A closure providing an executable Tool by a name.
    ///   - targetName: The name of the target.
    ///   - directories: An array of directory paths.
    ///   - pluginWorkDirectory: The work directory path of the plugin.
    ///   - packageDirectory: The directory path of the package.
    ///   - fileManager: The file manager. Default value `.default`
    /// - Returns: A PackagePlugin Command.
    func callAsFunction(
        executable: (String) throws -> PackagePlugin.PluginContext.Tool,
        targetName: String,
        directories: [PackagePlugin.Path],
        pluginWorkDirectory: PackagePlugin.Path,
        packageDirectory: PackagePlugin.Path,
        fileManager: FileManager = .default
    ) throws -> [PackagePlugin.Command] {
        let swiftGenExecutable = try executable("swiftgen")
        return directories
            .map { $0.appending("swiftgen.yml") }
            .map(\.string)
            .filter(fileManager.fileExists)
            .map { configurationPath in
                .prebuildCommand(
                    displayName: "Running SwiftGen for \(targetName) using \(configurationPath)",
                    executable: swiftGenExecutable.path,
                    arguments: [
                        "config",
                        "run",
                        "--config",
                        configurationPath
                    ],
                    environment: [
                        "PROJECT_DIR": packageDirectory.string,
                        "TARGET_NAME": targetName,
                        "DERIVED_SOURCES_DIR": pluginWorkDirectory.string
                    ],
                    outputFilesDirectory: pluginWorkDirectory
                )
            }
    }
    
}

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
        try self(
            executable: context.tool,
            targetName: target.name,
            directories: [
                context.package.directory.removingLastComponent(),
                context.package.directory,
                target.directory
            ],
            pluginWorkDirectory: context.pluginWorkDirectory,
            packageDirectory: context.package.directory
        )
    }
    
}
