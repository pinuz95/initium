# Initium

**The intelligent macOS development environment manager with evolution tracking**

Initium goes beyond simple dotfiles and package management. It's a comprehensive system that sets up, tracks, and optimizes your Mac's development environment while learning how changes affect your system's performance over time.

## 🌟 Why Initium?

Most Mac setup tools are static - they install things once and forget about them. Initium is **evolutionary**:

- 📊 **Tracks your system's evolution** - See how installations affect performance
- 🎯 **Dual interface** - Powerful CLI for developers + beautiful SwiftUI menu bar app for everyone
- 🧠 **Intelligent recommendations** - Suggests optimizations based on your usage patterns
- ☁️ **Seamless backup** - CloudKit integration for effortless multi-device sync
- 🔄 **Complete automation** - From fresh Mac to fully configured in under 30 minutes

## ✨ Features

### Core System Management
- **Homebrew Integration** - Install, update, and manage packages with dependency resolution
- **Dotfiles Management** - Intelligent sync with conflict resolution and templates
- **System Settings** - Automate macOS preferences (Dock, Finder, keyboard, etc.)
- **Developer Tools** - Xcode, command line tools, and development environment setup
- **GitHub Integration** - SSH keys, repository cloning, and project organization

### Intelligence & Evolution Tracking
- **Performance Monitoring** - Track boot times, app launch speeds, and system responsiveness
- **Change Impact Analysis** - See how each installation affects your system's performance
- **Visual Timeline** - Beautiful SwiftUI interface showing your system's evolution
- **Smart Recommendations** - AI-powered suggestions for optimizations and cleanup
- **Rollback Points** - Easily revert problematic changes

### Backup & Sync
- **CloudKit Integration** - Encrypted, automatic backups to iCloud
- **Multi-Device Sync** - Keep configurations synchronized across all your Macs
- **Export/Import** - Portable configuration files for offline backup
- **Incremental Backups** - Smart, space-efficient backup system

## 🖥️ Dual Interface

### Command Line Interface
Perfect for developers, scripts, and automation:
```bash
# Quick system status
initium status

# Install packages from a list
initium brew batch ~/my-packages.txt

# Export current system state
initium export ~/my-mac-setup.json

# Create and upload backup
initium backup create
```

### Menu Bar Application
Beautiful SwiftUI app for visual system management:
- Real-time system health monitoring
- One-click package installations
- Visual timeline of system changes
- Accessible settings and preferences
- Progress notifications and alerts

## 🚀 Quick Start

### Installation
```bash
# Install via Homebrew (coming soon)
brew install initium

# Or download from releases
curl -L https://github.com/yourusername/initium/releases/latest/download/initium -o /usr/local/bin/initium
chmod +x /usr/local/bin/initium
```

### First Setup
```bash
# Initialize Initium with your current system
initium init

# Create your first backup
initium backup create

# Set up a new Mac from backup
initium backup restore <backup-id>
```

## 📋 System Requirements

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools
- Admin privileges for system modifications

## 🏗️ Development

### Architecture

Initium is built with Swift for native macOS performance and uses a shared-core architecture:

```
Sources/
├── InitiumCore/      # Shared business logic
├── InitiumCLI/       # Command-line interface  
├── InitiumMenuBar/   # SwiftUI menu bar app
├── InitiumBackup/    # Backup and sync system
├── InitiumTracking/  # Analytics and evolution tracking
└── InitiumServices/  # External integrations
```

### Technology Stack
- **Swift** - Native macOS performance and system integration
- **SwiftUI** - Modern, declarative user interface
- **ArgumentParser** - Robust command-line interface
- **SQLite** - Local database for tracking and analytics
- **CloudKit** - Apple ecosystem integration for sync

### Development Setup

1. **Clone and setup**
```bash
git clone https://github.com/yourusername/initium.git
cd initium
swift package resolve
```

2. **Build and run CLI**
```bash
swift run initium-cli --help
```

3. **Open in Xcode for menu bar app**
```bash
open Package.swift
# Select InitiumMenuBar scheme and run
```

4. **Run tests**
```bash
swift test
```

### Development Phases

Initium is being developed in logical phases:

1. **Foundation** - Core architecture and basic functionality ✅
2. **Interface** - CLI and menu bar app foundations 🚧
3. **Homebrew** - Complete package management
4. **Backup** - System state and cloud sync  
5. **Automation** - Dotfiles, settings, and developer tools
6. **Intelligence** - Evolution tracking and analytics
7. **Scale** - Multi-device and App Store preparation

## 🤝 Contributing

We welcome contributions! Initium is designed to be:

- **Open Source** - MIT licensed with full functionality available
- **Modular** - Clean separation between components
- **Well-tested** - Comprehensive test coverage
- **Well-documented** - Clear code and user documentation

### Getting Started
1. Check out the [issues](https://github.com/yourusername/initium/issues) for good first contributions
2. Read our [development phases](memory-bank/implementation-phases.txt) to understand the roadmap
3. Set up the development environment (see above)
4. Make your changes and submit a pull request

### Areas We Need Help
- macOS system integration and testing
- SwiftUI interface design and UX
- Performance optimization
- Documentation and tutorials
- Testing on different macOS versions

## 📊 Competitive Landscape

Initium differentiates itself from existing tools:

| Feature | Initium | Homebrew | Mackup | Dotbot | mas-cli |
|---------|---------|----------|--------|--------|---------|
| Package Management | ✅ | ✅ | ❌ | ❌ | ❌ |
| Dotfiles | ✅ | ❌ | ✅ | ✅ | ❌ |
| System Settings | ✅ | ❌ | ✅ | ❌ | ❌ |
| GUI Interface | ✅ | ❌ | ❌ | ❌ | ❌ |
| Evolution Tracking | ✅ | ❌ | ❌ | ❌ | ❌ |
| Performance Analysis | ✅ | ❌ | ❌ | ❌ | ❌ |
| Cloud Sync | ✅ | ❌ | Limited | ❌ | ❌ |
| Multi-device | ✅ | ❌ | ❌ | ❌ | ❌ |

## 📈 Roadmap

- **Q1 2024**: Foundation and Interface phases complete
- **Q2 2024**: Homebrew and Backup phases complete (MVP ready)
- **Q3 2024**: Automation phase complete (full system management)
- **Q4 2024**: Intelligence phase complete (evolution tracking)
- **Q1 2025**: Scale phase complete (App Store ready)

See our detailed [implementation phases](memory-bank/implementation-phases.txt) for specifics.

## 🔒 Privacy & Security

- **Local-first** - All data stored locally by default
- **Encrypted backups** - CloudKit backups are end-to-end encrypted
- **Minimal permissions** - Only requests necessary system access
- **Transparent tracking** - You control what data is collected and stored
- **Open source** - Full code transparency for security review

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

This means you can:
- ✅ Use Initium commercially
- ✅ Modify and distribute it
- ✅ Include it in proprietary software
- ✅ Use it without attribution (though we'd appreciate it!)

## 🙏 Acknowledgments

Inspired by the many excellent macOS setup tools that came before, including:
- [Homebrew](https://brew.sh/) for package management
- [Mackup](https://github.com/lra/mackup) for application settings backup
- [Dotbot](https://github.com/anishathalye/dotbot) for dotfiles management

Initium aims to bring all these capabilities together with intelligent evolution tracking and a modern dual interface.

---

**Status**: 🚧 Early Development - Foundation Phase  
**Version**: 0.1.0-dev  
**Supported**: macOS 13.0+

*Star this repo to follow development progress!*