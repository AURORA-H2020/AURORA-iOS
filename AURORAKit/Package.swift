// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AURORAKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "App",
            targets: [
                "App"
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            exact: "10.3.0"
        )
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "FirebaseKit",
                "AuthenticationModule",
                "ConsumptionModule",
                "SettingsModule",
                "UserModule"
            ]
        ),
        .target(
            name: "FirebaseKit",
            dependencies: [
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
                )
            ],
            path: "Sources/Kits/FirebaseKit"
        ),
        .target(
            name: "ModuleKit",
            path: "Sources/Kits/ModuleKit"
        ),
        .target(
            name: "AuthenticationModule",
            dependencies: [
                "FirebaseKit",
                "ModuleKit"
            ],
            path: "Sources/Modules/AuthenticationModule"
        ),
        .target(
            name: "ConsumptionModule",
            dependencies: [
                "FirebaseKit"
            ],
            path: "Sources/Modules/ConsumptionModule"
        ),
        .target(
            name: "SettingsModule",
            dependencies: [
                "FirebaseKit"
            ],
            path: "Sources/Modules/SettingsModule"
        ),
        .target(
            name: "UserModule",
            dependencies: [
                "FirebaseKit",
                "ModuleKit"
            ],
            path: "Sources/Modules/UserModule"
        )
    ]
)
