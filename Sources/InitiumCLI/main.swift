import ArgumentParser
import Foundation
import InitiumCore
import os.log

// MARK: - Main CLI Entry Point

@available(macOS 10.15, macCatalyst 13, iOS 13, tvOS 13, watchOS 6, *)
struct InitiumCLI: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "initium",
        abstract: "Initium - Intelligent macOS Development Environment Manager",
        version: InitiumCore.version,
        subcommands: [
            VersionCommand.self,
            InfoCommand.self,
            ConfigCommand.self,
            StatusCommand.self,
        ],
        defaultSubcommand: StatusCommand.self
    )

    @Flag(name: .shortAndLong, help: "Enable verbose output")
    var verbose = false

    @Flag(name: .long, help: "Suppress non-essential output")
    var quiet = false

    func run() async throws {
        // This should never be called since we have a default subcommand
        throw CleanExit.helpRequest(self)
    }
}

// MARK: - Version Command

struct VersionCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Display version information"
    )

    @Flag(name: .long, help: "Show detailed version information")
    var detailed = false

    func run() async throws {
        if detailed {
            print("Initium v\(InitiumCore.version) (\(InitiumCore.build))")
            print("Built for macOS 13.0+")

            let systemInfo = SystemInfo()
            print("Running on: \(systemInfo.macOSVersion)")
            print("Architecture: \(systemInfo.architecture)")
            print("Device: \(systemInfo.deviceModel)")
        } else {
            print(InitiumCore.version)
        }
    }
}

// MARK: - Info Command

struct InfoCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Display system and environment information"
    )

    @Flag(name: .shortAndLong, help: "Show system tools and their versions")
    var tools = false

    func run() async throws {
        InitiumCore.initialize()
        Logger.cli.info("Displaying system information")

        let systemInfo = SystemInfo()

        print("📊 System Information")
        print("┌─────────────────────────────────────────")
        print("│ macOS Version: \(systemInfo.macOSVersion)")
        print("│ Architecture:  \(systemInfo.architecture)")
        print("│ Device Model:  \(systemInfo.deviceModel)")
        print("│ Total Memory:  \(String(format: "%.1f", systemInfo.totalMemoryGB)) GB")
        print("└─────────────────────────────────────────")

        if tools {
            print("\n🛠️  Development Tools")
            print("┌─────────────────────────────────────────")

            let commonTools = [
                "brew", "git", "node", "npm", "yarn", "python3", "ruby",
                "swift", "xcodebuild", "pod", "fastlane", "carthage",
            ]

            for tool in commonTools {
                let isInstalled = SystemDetector.isToolInstalled(tool)
                let status = isInstalled ? "✅" : "❌"
                let version =
                    isInstalled ? SystemDetector.getToolVersion(tool) ?? "unknown" : "not installed"
                print(
                    "│ \(status) \(tool.padding(toLength: 12, withPad: " ", startingAt: 0)): \(version)"
                )
            }

            print("└─────────────────────────────────────────")
        }

        // Configuration status
        do {
            let config = try Configuration.load()
            print("\n⚙️  Configuration")
            print("┌─────────────────────────────────────────")
            print("│ Config Version: \(config.version)")
            print(
                "│ Analytics:      \(config.preferences.enableAnalytics ? "enabled" : "disabled")")
            print("│ Auto Backup:    \(config.preferences.autoBackup ? "enabled" : "disabled")")
            print("│ Verbose Logs:   \(config.preferences.verboseLogging ? "enabled" : "disabled")")
            print("└─────────────────────────────────────────")
        } catch {
            print("\n⚙️  Configuration: Using defaults (no config file found)")
        }
    }
}

// MARK: - Config Command

struct ConfigCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "config",
        abstract: "Manage Initium configuration",
        subcommands: [
            ConfigShow.self,
            ConfigSet.self,
            ConfigReset.self,
        ],
        defaultSubcommand: ConfigShow.self
    )
}

struct ConfigShow: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Display current configuration"
    )

    func run() async throws {
        do {
            let config = try Configuration.load()

            print("📋 Current Configuration")
            print("┌─────────────────────────────────────────")
            print("│ Version:         \(config.version)")
            print("│ Analytics:       \(config.preferences.enableAnalytics)")
            print("│ Auto Backup:     \(config.preferences.autoBackup)")
            print("│ Verbose Logging: \(config.preferences.verboseLogging)")
            print("│ Backup Provider: \(config.backupSettings.provider)")
            print("│ Retention Days:  \(config.backupSettings.retentionDays)")
            print("│ Compression:     \(config.backupSettings.compressionEnabled)")
            print("└─────────────────────────────────────────")

        } catch {
            print("⚠️  No configuration file found. Using defaults.")
            print("   Use 'initium config set' to configure options.")
        }
    }
}

struct ConfigSet: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set",
        abstract: "Set configuration values"
    )

    @Option(help: "Enable or disable analytics (true/false)")
    var analytics: Bool?

    @Option(help: "Enable or disable auto backup (true/false)")
    var autoBackup: Bool?

    @Option(help: "Enable or disable verbose logging (true/false)")
    var verboseLogging: Bool?

    @Option(help: "Set backup provider (local/icloud)")
    var backupProvider: String?

    @Option(help: "Set backup retention days")
    var retentionDays: Int?

    func run() async throws {
        var config = (try? Configuration.load()) ?? Configuration()
        var changed = false

        if let analytics = analytics {
            config.preferences.enableAnalytics = analytics
            print("✅ Set analytics to: \(analytics)")
            changed = true
        }

        if let autoBackup = autoBackup {
            config.preferences.autoBackup = autoBackup
            print("✅ Set auto backup to: \(autoBackup)")
            changed = true
        }

        if let verboseLogging = verboseLogging {
            config.preferences.verboseLogging = verboseLogging
            print("✅ Set verbose logging to: \(verboseLogging)")
            changed = true
        }

        if let backupProvider = backupProvider {
            guard ["local", "icloud"].contains(backupProvider.lowercased()) else {
                throw InitiumError.invalidInput("Backup provider must be 'local' or 'icloud'")
            }
            config.backupSettings.provider = backupProvider.lowercased()
            print("✅ Set backup provider to: \(backupProvider)")
            changed = true
        }

        if let retentionDays = retentionDays {
            guard retentionDays > 0 else {
                throw InitiumError.invalidInput("Retention days must be greater than 0")
            }
            config.backupSettings.retentionDays = retentionDays
            print("✅ Set retention days to: \(retentionDays)")
            changed = true
        }

        if changed {
            try config.save()
            print("💾 Configuration saved successfully")
        } else {
            print("ℹ️  No changes specified. Use --help to see available options.")
        }
    }
}

struct ConfigReset: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "reset",
        abstract: "Reset configuration to defaults"
    )

    @Flag(help: "Skip confirmation prompt")
    var force = false

    func run() async throws {
        if !force {
            print("⚠️  This will reset all configuration to defaults.")
            print("   Use --force to skip this confirmation.")
            return
        }

        let config = Configuration()
        try config.save()
        print("✅ Configuration reset to defaults")
    }
}

// MARK: - Status Command

struct StatusCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show system status overview (default command)"
    )

    func run() async throws {
        InitiumCore.initialize()

        print("🚀 Initium v\(InitiumCore.version)")
        print("   Intelligent macOS Development Environment Manager")
        print("")

        let systemInfo = SystemInfo()
        print("💻 System: \(systemInfo.deviceModel) running \(systemInfo.macOSVersion)")

        // Quick tool check
        let essentialTools = ["brew", "git", "swift"]
        let installedCount = essentialTools.filter(SystemDetector.isToolInstalled).count
        print("🛠️  Essential Tools: \(installedCount)/\(essentialTools.count) installed")

        // Configuration status
        let hasConfig = (try? Configuration.load()) != nil
        print("⚙️  Configuration: \(hasConfig ? "loaded" : "using defaults")")

        print("")
        print("📚 Available Commands:")
        print("   • initium info         - Detailed system information")
        print("   • initium info --tools - Show all development tools")
        print("   • initium config       - Manage configuration")
        print("   • initium version      - Show version information")
        print("   • initium --help       - Show detailed help")
        print("")
        print("🔮 This is the Foundation Phase - Core functionality ready!")
        print("   Future phases will add package management, backup, and intelligence.")
    }
}

// MARK: - Error Handling

extension InitiumError: @retroactive CustomStringConvertible {
    public var description: String {
        return errorDescription ?? "Unknown error"
    }
}

// MARK: - Main Entry Point

InitiumCLI.main()
