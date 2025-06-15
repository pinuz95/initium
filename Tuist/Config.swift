import ProjectDescription

let config = Config(
    compatibleXcodeVersions: ["15.0", "15.1", "15.2", "15.3", "15.4"],
    cloud: nil,
    cache: nil,
    plugins: [],
    generationOptions: .options(
        resolveDependenciesWithSystemScm: false,
        disablePackageVersionLocking: false
    ),
    path: nil
)
