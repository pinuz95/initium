import AppKit
import ComposableArchitecture
import InitiumCore
import SwiftUI
import os.log

// MARK: - App Entry Point

@main
struct InitiumMenuBarApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let store = Store(
        initialState: MenuBarFeature.State(),
        reducer: { MenuBarFeature() }
    )

    var body: some Scene {
        MenuBarExtra("Initium", systemImage: "gear.circle") {
            MenuBarView(store: store)
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        InitiumCore.initialize()
        Logger.menuBar.info("MenuBar app launched")

        // Hide dock icon for menu bar only app
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        Logger.menuBar.info("MenuBar app terminating")
    }
}

// MARK: - TCA Feature

@Reducer
struct MenuBarFeature {

    @ObservableState
    struct State: Equatable {
        var systemInfo: SystemInfo?
        var configuration: Configuration?
        var isLoading = true
        var essentialTools: [ToolStatus] = []
        var showingSettings = false
        var lastRefresh: Date?

        struct ToolStatus: Equatable, Identifiable {
            let id = UUID()
            let name: String
            let isInstalled: Bool
            let version: String?
        }
    }

    enum Action {
        case onAppear
        case refreshSystem
        case systemInfoLoaded(SystemInfo)
        case configurationLoaded(Configuration?)
        case toolsChecked([State.ToolStatus])
        case toggleSettings
        case openConfiguration
        case quit
    }

    @Dependency(\.continuousClock) var clock

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.refreshSystem)
                }

            case .refreshSystem:
                return .run { send in
                    // Load system information
                    let systemInfo = SystemInfo()
                    await send(.systemInfoLoaded(systemInfo))

                    // Load configuration
                    let config = try? Configuration.load()
                    await send(.configurationLoaded(config))

                    // Check essential tools
                    let essentialTools = ["brew", "git", "swift", "node", "python3"]
                    let toolStatuses = essentialTools.map { toolName in
                        let isInstalled = SystemDetector.isToolInstalled(toolName)
                        let version = isInstalled ? SystemDetector.getToolVersion(toolName) : nil
                        return State.ToolStatus(
                            name: toolName,
                            isInstalled: isInstalled,
                            version: version
                        )
                    }
                    await send(.toolsChecked(toolStatuses))
                }

            case let .systemInfoLoaded(systemInfo):
                state.systemInfo = systemInfo
                state.isLoading = false
                state.lastRefresh = Date()
                return .none

            case let .configurationLoaded(config):
                state.configuration = config
                return .none

            case let .toolsChecked(tools):
                state.essentialTools = tools
                return .none

            case .toggleSettings:
                state.showingSettings.toggle()
                return .none

            case .openConfiguration:
                return .run { _ in
                    // Open Terminal with config command
                    let process = Process()
                    process.launchPath = "/usr/bin/open"
                    process.arguments = ["-a", "Terminal", "-g"]
                    try? process.run()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let script = """
                                tell application "Terminal"
                                    do script "initium config show"
                                    activate
                                end tell
                            """
                        let appleScript = NSAppleScript(source: script)
                        appleScript?.executeAndReturnError(nil)
                    }
                }

            case .quit:
                return .run { _ in
                    await NSApplication.shared.terminate(nil)
                }
            }
        }
    }
}

// MARK: - MenuBar View

struct MenuBarView: View {
    let store: StoreOf<MenuBarFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HeaderView()

                Divider()

                if viewStore.isLoading {
                    LoadingView()
                } else {
                    // System Status
                    SystemStatusView(
                        systemInfo: viewStore.systemInfo,
                        tools: viewStore.essentialTools,
                        lastRefresh: viewStore.lastRefresh
                    )

                    Divider()

                    // Actions
                    ActionsView(
                        store: store,
                        hasConfiguration: viewStore.configuration != nil
                    )
                }
            }
            .frame(width: 280)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

// MARK: - Header View

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "gear.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)

            VStack(alignment: .leading, spacing: 0) {
                Text("Initium")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("v\(InitiumCore.version)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)

            Text("Loading system information...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - System Status View

struct SystemStatusView: View {
    let systemInfo: SystemInfo?
    let tools: [MenuBarFeature.State.ToolStatus]
    let lastRefresh: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // System Info
            if let systemInfo = systemInfo {
                VStack(alignment: .leading, spacing: 4) {
                    Label("System Status", systemImage: "desktopcomputer")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    VStack(alignment: .leading, spacing: 2) {
                        InfoRow(label: "Device", value: systemInfo.deviceModel)
                        InfoRow(label: "macOS", value: systemInfo.macOSVersion)
                        InfoRow(label: "Architecture", value: systemInfo.architecture)
                        InfoRow(
                            label: "Memory",
                            value: "\(String(format: "%.1f", systemInfo.totalMemoryGB)) GB")
                    }
                    .padding(.leading, 20)
                }
            }

            // Tools Status
            if !tools.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Development Tools", systemImage: "hammer")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(tools) { tool in
                            ToolRow(tool: tool)
                        }
                    }
                    .padding(.leading, 20)
                }
            }

            // Last refresh
            if let lastRefresh = lastRefresh {
                HStack {
                    Spacer()
                    Text("Updated \(lastRefresh, style: .relative) ago")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(.caption)
                .fontWeight(.medium)

            Spacer()
        }
    }
}

struct ToolRow: View {
    let tool: MenuBarFeature.State.ToolStatus

    var body: some View {
        HStack {
            Image(systemName: tool.isInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(tool.isInstalled ? .green : .red)
                .font(.caption)

            Text(tool.name)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .leading)

            if let version = tool.version {
                Text(version.prefix(20))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            } else {
                Text("not installed")
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            Spacer()
        }
    }
}

// MARK: - Actions View

struct ActionsView: View {
    let store: StoreOf<MenuBarFeature>
    let hasConfiguration: Bool

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                MenuButton(
                    title: "Refresh Status",
                    icon: "arrow.clockwise",
                    action: { viewStore.send(.refreshSystem) }
                )

                MenuButton(
                    title: "Open Configuration",
                    icon: "gear",
                    action: { viewStore.send(.openConfiguration) }
                )

                MenuButton(
                    title: "About Initium",
                    icon: "info.circle",
                    action: {
                        NSWorkspace.shared.open(
                            URL(string: "https://github.com/yourusername/initium")!)
                    }
                )

                Divider()
                    .padding(.vertical, 4)

                MenuButton(
                    title: "Quit Initium",
                    icon: "power",
                    action: { viewStore.send(.quit) },
                    isDestructive: true
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let isDestructive: Bool

    init(title: String, icon: String, action: @escaping () -> Void, isDestructive: Bool = false) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isDestructive = isDestructive
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 16)

                Text(title)
                    .font(.caption)
                    .foregroundColor(isDestructive ? .red : .primary)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.clear)
                .onHover { isHovered in
                    // Add hover effect if needed
                }
        )
    }
}

// MARK: - Preview

#Preview {
    MenuBarView(
        store: Store(
            initialState: MenuBarFeature.State(
                systemInfo: SystemInfo(),
                isLoading: false,
                essentialTools: [
                    .init(name: "brew", isInstalled: true, version: "4.0.0"),
                    .init(name: "git", isInstalled: true, version: "2.39.0"),
                    .init(name: "swift", isInstalled: true, version: "5.9.0"),
                    .init(name: "node", isInstalled: false, version: nil),
                    .init(name: "python3", isInstalled: true, version: "3.11.0"),
                ]
            ),
            reducer: { MenuBarFeature() }
        )
    )
}
