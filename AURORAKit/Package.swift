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
                "FirebaseKit"
            ]
        ),
        .target(
            name: "FirebaseKit",
            dependencies: [
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
                )
            ],
            path: "Sources/Kits/FirebaseKit"
        ),
        .target(
            name: "AuthenticationModule",
            path: "Sources/Modules/AuthenticationModule"
        )
    ]
)
