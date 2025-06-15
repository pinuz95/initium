# Tuist - Documentation Summary

## What is Tuist?

Tuist is an integrated extension of Apple's native toolchain designed to build better apps faster. It provides a Swift-based DSL (Domain Specific Language) to make Xcode projects more manageable and scalable, especially for large codebases and teams.

## Key Value Propositions

- **Generated Projects**: Define projects in Swift code instead of maintaining Xcode project files
- **Cache**: Get faster compilations by skipping compilation with cached binaries
- **Selective Testing**: Skip test targets when dependent code hasn't changed
- **Previews**: Share app previews with URLs that launch the app on click
- **Registry**: Cut down package resolution time from minutes to seconds
- **Insights**: Get project insights to maintain productive developer environment
- **Bundle Size Analysis**: Optimize app memory footprint

## Installation

### Homebrew (Recommended)
```bash
brew tap tuist/tuist
brew install --formula tuist
```

### Mise
```bash
mise x tuist@latest -- tuist init
```

### Verification
```bash
tuist --version
```

## Getting Started

### Initialize New Project
```bash
tuist init
```

This creates a basic project structure with:
- `Project.swift` - Main project definition
- `Workspace.swift` - Workspace configuration (optional)
- `Tuist/` directory - Tuist configuration files

### Generate Xcode Project
```bash
tuist generate
```

This reads your Swift-based project definition and generates the actual `.xcodeproj` file.

## Project Structure

### Basic Project.swift
```swift
import ProjectDescription

let project = Project(
    name: "MyApp",
    targets: [
        .target(
            name: "MyApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.company.myapp",
            sources: ["Sources/**"],
            dependencies: []
        ),
        .target(
            name: "MyAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.company.myapp.tests",
            sources: ["Tests/**"],
            dependencies: [.target(name: "MyApp")]
        )
    ]
)
```

### Multi-Target Setup
```swift
let project = Project(
    name: "Initium",
    targets: [
        // Main CLI target
        .target(
            name: "InitiumCLI",
            destinations: .macOS,
            product: .commandLineTool,
            bundleId: "com.initium.cli",
            sources: ["Sources/InitiumCLI/**"],
            dependencies: [
                .target(name: "InitiumCore"),
                .external(name: "ArgumentParser")
            ]
        ),
        
        // Menu Bar App target
        .target(
            name: "InitiumMenuBar",
            destinations: .macOS,
            product: .app,
            bundleId: "com.initium.menubar",
            sources: ["Sources/InitiumMenuBar/**"],
            dependencies: [
                .target(name: "InitiumCore"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        
        // Shared Core target
        .target(
            name: "InitiumCore",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.initium.core",
            sources: ["Sources/InitiumCore/**"],
            dependencies: [
                .external(name: "SQLite3"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        
        // Tests
        .target(
            name: "InitiumTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.initium.tests",
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "InitiumCore"),
                .target(name: "InitiumCLI"),
                .target(name: "InitiumMenuBar")
            ]
        )
    ]
)
```

## Key Features for Initium

### 1. Dependency Management
```swift
// In Project.swift
dependencies: [
    .external(name: "ComposableArchitecture"),
    .external(name: "ArgumentParser"),
    .external(name: "SQLite3")
]
```

### 2. Build Configurations
```swift
settings: .settings(
    base: [
        "SWIFT_VERSION": "5.9",
        "MACOSX_DEPLOYMENT_TARGET": "13.0"
    ],
    configurations: [
        .debug(name: .debug),
        .release(name: .release)
    ]
)
```

### 3. Resource Management
```swift
.target(
    name: "InitiumMenuBar",
    destinations: .macOS,
    product: .app,
    bundleId: "com.initium.menubar",
    sources: ["Sources/InitiumMenuBar/**"],
    resources: [
        "Resources/**",
        "Assets.xcassets"
    ]
)
```

## Common Commands

### Project Management
```bash
# Initialize new project
tuist init

# Generate Xcode project
tuist generate

# Clean generated projects
tuist clean

# Open generated project
tuist generate --open
```

### Development Workflow
```bash
# Generate and open project
tuist generate --open

# Generate specific scheme
tuist generate --scheme InitiumCLI

# Generate for specific platform
tuist generate --platform macOS
```

### Cache Management
```bash
# Enable cache
tuist cache warm

# Clean cache
tuist cache clean

# Cache status
tuist cache print-hashes
```

## Advanced Features

### Workspace Configuration
```swift
// Workspace.swift
import ProjectDescription

let workspace = Workspace(
    name: "Initium",
    projects: [
        ".",
        "Plugins/**"
    ]
)
```

### Custom Templates
```bash
# Create custom template
tuist scaffold MyTemplate

# Use template
tuist scaffold MyTemplate --name MyFeature
```

### Plugins
```swift
// Plugin.swift
import ProjectDescription

let plugin = Plugin(name: "MyPlugin")
```

## Benefits for Initium Development

### 1. **Modularity**
- Clear separation between CLI, MenuBar, and Core
- Independent building and testing
- Easier code sharing and reuse

### 2. **Dependency Management**
- Centralized external dependencies
- Version consistency across targets
- Easy dependency updates

### 3. **Build Performance**
- Cached compilations for faster builds
- Selective testing saves time
- Parallel target building

### 4. **Team Collaboration**
- Swift-based configuration is version controllable
- No Xcode project file conflicts
- Consistent project structure

### 5. **CI/CD Integration**
- Reproducible builds
- Command-line friendly
- Easy automation

## Recommended Initium Structure

```
Initium/
├── Project.swift                 # Main project definition
├── Tuist/
│   ├── Config.swift             # Tuist configuration
│   └── Dependencies.swift        # External dependencies
├── Sources/
│   ├── InitiumCore/             # Shared business logic
│   ├── InitiumCLI/              # Command-line interface
│   └── InitiumMenuBar/          # SwiftUI menu bar app
├── Tests/
│   ├── InitiumCoreTests/
│   ├── InitiumCLITests/
│   └── InitiumMenuBarTests/
├── Resources/                   # Shared resources
└── Documentation/               # Project documentation
```

## Tuist Configuration

### Config.swift
```swift
import ProjectDescription

let config = Config(
    compatibleXcodeVersions: ["15.0"],
    swiftVersion: "5.9",
    generationOptions: .options(
        xcodeProjectName: "Initium",
        organizationName: "Initium",
        developmentRegion: "en"
    )
)
```

### Dependencies.swift
```swift
import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies([
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .upToNextMajor(from: "1.20.0")
        ),
        .remote(
            url: "https://github.com/apple/swift-argument-parser",
            requirement: .upToNextMajor(from: "1.0.0")
        )
    ])
)
```

## Best Practices

### 1. **Project Structure**
- Keep targets focused and single-purpose
- Use clear naming conventions
- Separate concerns appropriately

### 2. **Dependencies**
- Minimize external dependencies
- Use specific version requirements
- Regular dependency updates

### 3. **Testing**
- Create test targets for each module
- Use selective testing for large projects
- Include integration tests

### 4. **Build Configuration**
- Use appropriate deployment targets
- Configure build settings centrally
- Optimize for both development and release

## Common Issues and Solutions

### 1. **Generation Errors**
```bash
# Clean and regenerate
tuist clean
tuist generate
```

### 2. **Dependency Resolution**
```bash
# Reset dependencies
tuist dependencies clean
tuist dependencies fetch
```

### 3. **Cache Issues**
```bash
# Clear cache
tuist cache clean
tuist cache warm
```

## Integration with Initium Development

Tuist will provide Initium with:
- **Scalable architecture** for multiple targets
- **Fast iteration** with caching
- **Clean separation** between CLI and GUI
- **Professional project structure**
- **Easy dependency management**
- **Consistent build process**

This makes Tuist an excellent choice for Initium's dual-interface architecture, allowing clean separation between the CLI tool and SwiftUI menu bar app while sharing common business logic.