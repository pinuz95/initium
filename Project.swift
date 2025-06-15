import ProjectDescription

let project = Project(
    name: "Initium",
    organizationName: "Initium",
    options: .options(
        automaticSchemesOptions: .enabled(
            targetSchemesGrouping: .singleScheme,
            codeCoverageEnabled: true,
            testingOptions: [.parallelizable]
        ),
        disableBundleAccessors: false,
        disableShowEnvironmentVarsInScriptPhases: true
    ),
    packages: [
        .remote(
            url: "https://github.com/apple/swift-argument-parser",
            requirement: .upToNextMajor(from: "1.3.0")),
        .remote(
            url: "https://github.com/stephencelis/SQLite.swift",
            requirement: .upToNextMajor(from: "0.14.1")),
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .upToNextMajor(from: "1.20.2")),
    ],
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "",
            "CODE_SIGN_STYLE": "Automatic",
            "MACOSX_DEPLOYMENT_TARGET": "13.0",
            "SWIFT_VERSION": "5.9",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        // MARK: - Core Framework
        .target(
            name: "InitiumCore",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.initium.core",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Sources/InitiumCore/**"],
            resources: [],
            dependencies: [],
            settings: .settings(
                base: [
                    "ENABLE_HARDENED_RUNTIME": "YES",
                    "ENABLE_APP_SANDBOX": "NO",
                ]
            )
        ),

        // MARK: - Backup Module
        .target(
            name: "InitiumBackup",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.initium.backup",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Sources/InitiumBackup/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumCore"),
                .sdk(name: "CloudKit", type: .framework),
            ],
            settings: .settings(
                base: [
                    "ENABLE_HARDENED_RUNTIME": "YES"
                ]
            )
        ),

        // MARK: - Tracking Module
        .target(
            name: "InitiumTracking",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.initium.tracking",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Sources/InitiumTracking/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumCore")
            ],
            settings: .settings(
                base: [
                    "ENABLE_HARDENED_RUNTIME": "YES"
                ]
            )
        ),

        // MARK: - Services Module
        .target(
            name: "InitiumServices",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.initium.services",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Sources/InitiumServices/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumCore")
            ],
            settings: .settings(
                base: [
                    "ENABLE_HARDENED_RUNTIME": "YES"
                ]
            )
        ),

        // MARK: - CLI Application
        .target(
            name: "InitiumCLI",
            destinations: .macOS,
            product: .commandLineTool,
            bundleId: "com.initium.cli",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Sources/InitiumCLI/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumCore"),
                .target(name: "InitiumBackup"),
                .target(name: "InitiumTracking"),
                .target(name: "InitiumServices"),
                .package(product: "ArgumentParser"),
            ],
            settings: .settings(
                base: [
                    "ENABLE_HARDENED_RUNTIME": "YES",
                    "ENABLE_APP_SANDBOX": "NO",
                    "PRODUCT_NAME": "initium",
                ]
            )
        ),

        // MARK: - Menu Bar Application
        .target(
            name: "InitiumMenuBar",
            destinations: .macOS,
            product: .app,
            bundleId: "com.initium.menubar",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Initium",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                    "LSMinimumSystemVersion": "13.0",
                    "LSUIElement": true,  // Makes it a menu bar only app
                    "NSHumanReadableCopyright": "© 2024 Initium. All rights reserved.",
                    "ITSAppUsesNonExemptEncryption": false,
                    "NSAppleEventsUsageDescription":
                        "Initium needs AppleScript access to automate system settings and manage your development environment.",
                    "NSSystemAdministrationUsageDescription":
                        "Initium needs admin privileges to install packages and modify system settings.",
                    "com.apple.developer.system-extension.install": true,
                ]
            ),
            sources: ["Sources/InitiumMenuBar/**"],
            resources: [
                "Resources/MenuBar/**"
            ],
            dependencies: [
                .target(name: "InitiumCore"),
                .target(name: "InitiumBackup"),
                .target(name: "InitiumTracking"),
                .target(name: "InitiumServices"),
                .package(product: "ComposableArchitecture"),
                .sdk(name: "SwiftUI", type: .framework),
                .sdk(name: "AppKit", type: .framework),
                .sdk(name: "UserNotifications", type: .framework),
            ],
            settings: .settings(
                base: [
                    "ENABLE_HARDENED_RUNTIME": "YES",
                    "ENABLE_APP_SANDBOX": "NO",  // Needs system access
                    "PRODUCT_NAME": "Initium",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "COMBINE_HIDPI_IMAGES": "YES",
                ]
            )
        ),

        // MARK: - Tests
        .target(
            name: "InitiumCoreTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.initium.core.tests",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Tests/InitiumCoreTests/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumCore")
            ]
        ),

        .target(
            name: "InitiumBackupTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.initium.backup.tests",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Tests/InitiumBackupTests/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumBackup"),
                .target(name: "InitiumCore"),
            ]
        ),

        .target(
            name: "InitiumTrackingTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.initium.tracking.tests",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Tests/InitiumTrackingTests/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumTracking"),
                .target(name: "InitiumCore"),
            ]
        ),

        .target(
            name: "InitiumServicesTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.initium.services.tests",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Tests/InitiumServicesTests/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumServices"),
                .target(name: "InitiumCore"),
            ]
        ),

        .target(
            name: "InitiumCLITests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.initium.cli.tests",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Tests/InitiumCLITests/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumCore")
            ]
        ),

        .target(
            name: "InitiumMenuBarTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.initium.menubar.tests",
            deploymentTargets: .macOS("13.0"),
            infoPlist: .default,
            sources: ["Tests/InitiumMenuBarTests/**"],
            resources: [],
            dependencies: [
                .target(name: "InitiumMenuBar")
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "InitiumCLI",
            shared: true,
            buildAction: .buildAction(targets: ["InitiumCLI"]),
            testAction: .targets(
                ["InitiumCoreTests"],
                configuration: .debug,
                options: .options(coverage: true)
            ),
            runAction: .runAction(
                configuration: .debug,
                executable: "InitiumCLI"
            ),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        ),

        .scheme(
            name: "InitiumMenuBar",
            shared: true,
            buildAction: .buildAction(targets: ["InitiumMenuBar"]),
            testAction: .targets(
                [
                    "InitiumCoreTests", "InitiumBackupTests", "InitiumTrackingTests",
                    "InitiumServicesTests", "InitiumMenuBarTests",
                ],
                configuration: .debug,
                options: .options(coverage: true)
            ),
            runAction: .runAction(
                configuration: .debug,
                executable: "InitiumMenuBar"
            ),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        ),

        .scheme(
            name: "Initium-All",
            shared: true,
            buildAction: .buildAction(targets: ["InitiumCLI", "InitiumMenuBar"]),
            testAction: .targets(
                [
                    "InitiumCoreTests", "InitiumBackupTests", "InitiumTrackingTests",
                    "InitiumServicesTests", "InitiumMenuBarTests",
                ],
                configuration: .debug,
                options: .options(coverage: true)
            )
        ),
    ]
)
