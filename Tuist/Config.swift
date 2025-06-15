import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .all,
    swiftVersion: Version("5.9"),
    generationOptions: .options(
        resolveDependenciesWithSystemScm: false,
        disablePackageVersionLocking: false
    )
)
