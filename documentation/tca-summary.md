# The Composable Architecture (TCA) - Documentation Summary

## Version Information
- **Latest Version**: 1.20.2 (as of last check)
- **Repository**: https://github.com/pointfreeco/swift-composable-architecture
- **License**: MIT
- **Platforms**: iOS, macOS, iPadOS, visionOS, tvOS, watchOS
- **Frameworks**: SwiftUI, UIKit compatible

## Core Concepts

### 1. State
- Represents the data your feature needs
- Should be a value type (struct)
- Annotated with `@ObservableState` for observation support
- Should conform to `Equatable` for testing

```swift
@ObservableState
struct State: Equatable {
    var count = 0
    var isLoading = false
    var errorMessage: String?
}
```

### 2. Action
- Enum representing all possible actions in your feature
- User interactions, system events, API responses
- Should be exhaustive for all state changes

```swift
enum Action {
    case incrementTapped
    case decrementTapped
    case fetchDataTapped
    case dataResponse(Result<String, Error>)
}
```

### 3. Reducer
- Function that evolves state based on actions
- Returns effects for side effects
- Annotated with `@Reducer` macro
- Implements `body` property

```swift
@Reducer
struct Feature {
    @ObservableState
    struct State: Equatable { /* ... */ }
    enum Action { /* ... */ }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .incrementTapped:
                state.count += 1
                return .none
            case .fetchDataTapped:
                return .run { send in
                    // Side effect logic
                }
            }
        }
    }
}
```

### 4. Store
- Runtime that drives your feature
- Holds state and processes actions
- Observable for UI updates

```swift
let store = Store(initialState: Feature.State()) {
    Feature()
}
```

## Key APIs and Macros

### @Reducer Macro
- Applied to reducer types
- Generates boilerplate code
- Enables composition and testing features

### @ObservableState Macro
- Applied to State types
- Enables observation in SwiftUI
- Provides automatic UI updates

### @Dependency Property Wrapper
- Accesses registered dependencies
- Automatic dependency injection
- Testable and mockable

```swift
@Reducer
struct Feature {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.uuid) var uuid
    
    // Use in reducer body
}
```

### Effects
- `.none` - No side effects
- `.run` - Async side effects
- `.send` - Send actions back to store

```swift
return .run { send in
    let result = try await apiClient.fetchData()
    await send(.dataResponse(.success(result)))
}
```

## SwiftUI Integration

### Basic View
```swift
struct FeatureView: View {
    let store: StoreOf<Feature>
    
    var body: some View {
        VStack {
            Text("\(store.count)")
            Button("Increment") {
                store.send(.incrementTapped)
            }
        }
    }
}
```

### Observing State Changes
- Store is automatically observable
- SwiftUI views update when state changes
- Use `store.state` or direct property access

## Testing

### TestStore
- Specialized store for testing
- Asserts state changes step by step
- Validates effects and their results

```swift
@Test
func testIncrement() async {
    let store = TestStore(initialState: Feature.State()) {
        Feature()
    }
    
    await store.send(.incrementTapped) {
        $0.count = 1
    }
}
```

### Testing Effects
```swift
await store.send(.fetchDataTapped)
await store.receive(\.dataResponse) {
    $0.data = "Expected data"
}
```

### Dependency Overrides
```swift
let store = TestStore(initialState: Feature.State()) {
    Feature()
} withDependencies: {
    $0.apiClient = .mock
    $0.uuid = .incrementing
}
```

## Dependency Management

### Registering Dependencies
```swift
struct APIClient {
    var fetchData: () async throws -> String
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient(
        fetchData: {
            // Real implementation
        }
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
```

### Using Dependencies
```swift
@Reducer
struct Feature {
    @Dependency(\.apiClient) var apiClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchData:
                return .run { send in
                    let data = try await apiClient.fetchData()
                    await send(.dataReceived(data))
                }
            }
        }
    }
}
```

## Composition

### Combining Reducers
```swift
@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var tab1 = Tab1Feature.State()
        var tab2 = Tab2Feature.State()
    }
    
    enum Action {
        case tab1(Tab1Feature.Action)
        case tab2(Tab2Feature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.tab1, action: \.tab1) {
            Tab1Feature()
        }
        Scope(state: \.tab2, action: \.tab2) {
            Tab2Feature()
        }
    }
}
```

## Installation

### Swift Package Manager
```swift
dependencies: [
    .package(
        url: "https://github.com/pointfreeco/swift-composable-architecture",
        from: "1.20.2"
    )
]
```

### Xcode
1. File → Add Package Dependencies
2. Enter: `https://github.com/pointfreeco/swift-composable-architecture`
3. Select version or use "Up to Next Major"

## Best Practices for Initium

### Menu Bar App Structure
- Use `@Reducer` for main app logic
- `@ObservableState` for system status
- Dependencies for system integrations (brew, git, etc.)
- TestStore for comprehensive testing

### Recommended Architecture
```swift
@Reducer
struct InitiumApp {
    @ObservableState
    struct State {
        var systemStatus = SystemStatus()
        var brewPackages: [Package] = []
        var isMenuOpen = false
    }
    
    enum Action {
        case menuToggled
        case systemStatusRequested
        case brewPackagesRequested
        case packageInstallRequested(String)
    }
    
    @Dependency(\.systemClient) var systemClient
    @Dependency(\.brewClient) var brewClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            // Implementation
        }
    }
}
```

### Testing Strategy
- Test each reducer independently
- Mock system dependencies
- Use TestStore for integration tests
- Validate UI state changes

## Key Advantages for Initium

1. **Testability**: Comprehensive testing of business logic
2. **Modularity**: Clear separation of concerns
3. **Predictability**: Unidirectional data flow
4. **Composition**: Easy to combine features
5. **SwiftUI Integration**: Seamless UI updates
6. **Dependency Injection**: Mockable system integrations

## Common Patterns

### Loading States
```swift
@ObservableState
struct State {
    var isLoading = false
    var data: String?
    var error: String?
}
```

### Navigation
```swift
@ObservableState  
struct State {
    @Presents var destination: Destination.State?
}
```

### Side Effects
```swift
return .run { [state] send in
    try await Task.sleep(for: .seconds(1))
    await send(.delayed)
}
```

This architecture will provide a solid foundation for Initium's menu bar app with clear state management, testable business logic, and seamless SwiftUI integration.