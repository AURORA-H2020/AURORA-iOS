// swift-tools-version: 5.7

import PackageDescription

// MARK: - Package Targets

/// The Package Targets
let packageTargets = (
    app: Target.target(
        name: "App"
    ),
    localization: Target.target(
        name: "Localization",
        plugins: [
            .plugin(
                name: "SwiftGenPlugin"
            )
        ]
    ),
    kits: [Target]([
        .target(
            name: "FirebaseKit",
            dependencies: [
                .product(
                    name: "FirebaseAnalyticsSwift",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseAppCheck",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseAuth",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseFirestore",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseFirestoreSwift",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseFirestoreCombine-Community",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebaseFunctions",
                    package: "firebase-ios-sdk"
                ),
                .product(
                    name: "FirebasePerformance",
                    package: "firebase-ios-sdk"
                ),
            ]
        ),
        .target(
            name: "LocalNotificationKit"
        ),
        .target(
            name: "ModuleKit"
        )
    ]),
    modules: [Target]([
        .target(
            name: "AuthenticationModule"
        ),
        .target(
            name: "ConsumptionModule"
        ),
        .target(
            name: "SettingsModule"
        ),
        .target(
            name: "UserModule"
        )
    ]),
    binaries: [Target]([
        .binaryTarget(
            name: "swiftgen",
            url: "https://github.com/SwiftGen/SwiftGen/releases/download/6.6.2/swiftgen-6.6.2.artifactbundle.zip",
            checksum: "7586363e24edcf18c2da3ef90f379e9559c1453f48ef5e8fbc0b818fbbc3a045"
        ),
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.50.3/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "abe7c0bb505d26c232b565c3b1b4a01a8d1a38d86846e788c4d02f0b1042a904"
        )
    ]),
    plugins: [Target]([
        .plugin(
            name: "SwiftGenPlugin",
            capability: .buildTool(),
            dependencies: [
                "swiftgen"
            ]
        ),
        .plugin(
            name: "SwiftLintPlugin",
            capability: .buildTool(),
            dependencies: [
                "SwiftLintBinary"
            ]
        )
    ])
)

// MARK: - Package

/// The Package
let package = Package(
    name: "AURORAKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: packageTargets.app.name,
            targets: [
                packageTargets.app.name
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            exact: "10.3.0"
        )
    ],
    targets: {
        // Add Module Targets as Dependencies to App Target
        packageTargets.app.dependencies = packageTargets.modules.map(\.name).map(Target.Dependency.init)
        // Configure Kit Targets
        packageTargets.kits.forEach { kitTarget in
            // Set Path
            kitTarget.path = "Sources/Kits/\(kitTarget.name)"
        }
        // Configure Module Targets
        packageTargets.modules.forEach { moduleTarget in
            // Set Path
            moduleTarget.path = "Sources/Modules/\(moduleTarget.name)"
            // Add Kit Targets as Dependencies to Module Target
            moduleTarget.dependencies += packageTargets.kits.map(\.name).map(Target.Dependency.init)
        }
        // Initialize Targets
        var targets = [packageTargets.app] + packageTargets.kits + packageTargets.modules
        // Configure Targets
        targets.forEach { target in
            // Add Localization Target as Dependency
            target.dependencies += [.init(stringLiteral: packageTargets.localization.name)]
            // Add SwiftLintPlugin as Plugin
            target.plugins = (target.plugins ?? .init()) + [.plugin(name: "SwiftLintPlugin")]
        }
        // Add Localization, Binary and Plugin Targets
        targets += [packageTargets.localization] + packageTargets.binaries + packageTargets.plugins
        // Return Targets
        return targets
    }()
)
