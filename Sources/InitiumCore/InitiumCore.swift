import Foundation
import os.log

// MARK: - Core Exports

/// Main entry point for InitiumCore functionality
public struct InitiumCore {

    /// Current version of Initium
    public static let version = "0.1.0-dev"

    /// Build identifier
    public static let build = "foundation"

    /// Initialize InitiumCore with default configuration
    public static func initialize() {
        Logger.core.info("InitiumCore initialized - version \(version)")
    }
}

// MARK: - System Information

/// System information and detection capabilities
public struct SystemInfo: Equatable {

    /// Current macOS version
    public let macOSVersion: String

    /// System architecture (arm64, x86_64)
    public let architecture: String

    /// Device model identifier
    public let deviceModel: String

    /// Available memory in GB
    public let totalMemoryGB: Double

    public init() {
        let processInfo = ProcessInfo.processInfo
        self.macOSVersion = processInfo.operatingSystemVersionString

        #if arch(arm64)
            self.architecture = "arm64"
        #elseif arch(x86_64)
            self.architecture = "x86_64"
        #else
            self.architecture = "unknown"
        #endif

        // Get device model
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        self.deviceModel = String(cString: model)

        // Get total memory
        var memsize: UInt64 = 0
        var memsizeSize = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &memsize, &memsizeSize, nil, 0)
        self.totalMemoryGB = Double(memsize) / (1024 * 1024 * 1024)
    }
}

// MARK: - Configuration

/// Configuration management for Initium
public struct Configuration: Codable, Equatable {

    /// User preferences
    public struct Preferences: Codable, Equatable {
        public var enableAnalytics: Bool = true
        public var autoBackup: Bool = false
        public var verboseLogging: Bool = false

        public init() {}
    }

    /// Backup settings
    public struct BackupSettings: Codable, Equatable {
        public var provider: String = "local"
        public var retentionDays: Int = 30
        public var compressionEnabled: Bool = true

        public init() {}
    }

    public var preferences = Preferences()
    public var backupSettings = BackupSettings()
    public var version: String = InitiumCore.version

    public init() {}

    /// Load configuration from standard location
    public static func load() throws -> Configuration {
        let configURL = Self.configurationURL()

        guard FileManager.default.fileExists(atPath: configURL.path) else {
            Logger.core.info("No configuration file found, using defaults")
            return Configuration()
        }

        let data = try Data(contentsOf: configURL)
        let config = try JSONDecoder().decode(Configuration.self, from: data)
        Logger.core.info("Configuration loaded from \(configURL.path)")
        return config
    }

    /// Save configuration to standard location
    public func save() throws {
        let configURL = Self.configurationURL()

        // Ensure directory exists
        let configDir = configURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)

        let data = try JSONEncoder().encode(self)
        try data.write(to: configURL)
        Logger.core.info("Configuration saved to \(configURL.path)")
    }

    /// Standard configuration file location
    private static func configurationURL() -> URL {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent(".config/initium/config.json")
    }
}

// MARK: - Error Types

/// Core error types for Initium operations
public enum InitiumError: LocalizedError, Equatable {
    case configurationError(String)
    case systemDetectionFailed(String)
    case fileSystemError(String)
    case invalidInput(String)
    case operationCancelled
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .systemDetectionFailed(let message):
            return "System detection failed: \(message)"
        case .fileSystemError(let message):
            return "File system error: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .operationCancelled:
            return "Operation was cancelled"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Logging

/// Centralized logging for Initium
public struct Logger {

    /// Core module logger
    public static let core = os.Logger(subsystem: "com.initium.core", category: "core")

    /// CLI module logger
    public static let cli = os.Logger(subsystem: "com.initium.core", category: "cli")

    /// MenuBar module logger
    public static let menuBar = os.Logger(subsystem: "com.initium.core", category: "menubar")

    /// Backup module logger
    public static let backup = os.Logger(subsystem: "com.initium.core", category: "backup")

    /// Tracking module logger
    public static let tracking = os.Logger(subsystem: "com.initium.core", category: "tracking")

    /// Services module logger
    public static let services = os.Logger(subsystem: "com.initium.core", category: "services")
}

// MARK: - System Detection

/// Detect installed tools and system state
public struct SystemDetector {

    /// Check if a command-line tool is available
    public static func isToolInstalled(_ toolName: String) -> Bool {
        let process = Process()
        process.launchPath = "/usr/bin/which"
        process.arguments = [toolName]
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            Logger.core.error(
                "Failed to check if \(toolName) is installed: \(error.localizedDescription)")
            return false
        }
    }

    /// Get the version of an installed tool
    public static func getToolVersion(_ toolName: String, versionArg: String = "--version")
        -> String?
    {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = [toolName, versionArg]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(
                in: .whitespacesAndNewlines)

            return process.terminationStatus == 0 ? output : nil
        } catch {
            Logger.core.error(
                "Failed to get version for \(toolName): \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Result Extensions

extension Result {
    /// Convert Result to InitiumError
    public func mapToInitiumError() -> Result<Success, InitiumError> {
        return self.mapError { error in
            if let initiumError = error as? InitiumError {
                return initiumError
            }
            return InitiumError.unknown(error.localizedDescription)
        }
    }
}
