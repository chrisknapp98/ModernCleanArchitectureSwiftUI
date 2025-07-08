import ProjectDescription

enum BenchmarkModuleName: String, CaseIterable {
    case Task1 = "Task-1"
    case Task2 = "Task-2"
    case Task3 = "Task-3"
}

extension BenchmarkModuleName {
    var target: Target {
        .target(
            name: rawValue,
            destinations: .iOS,
            product: .framework,
            bundleId: "com.multifilebenchmark.\(rawValue)",
            sources: "Sources/\(rawValue)/**",
            dependencies: .build {
                CoreModuleName.allCases.map(TargetDependency.fromCore)
                DomainModuleName.allCases.map(TargetDependency.fromDomain)
                FeaturesModuleName.allCases.map(TargetDependency.fromFeatures)
                PlatformModuleName.allCases.map(TargetDependency.fromPlatform)
                UIModuleName.allCases.map(TargetDependency.fromUI)

                TargetDependency.external(.Dependencies)
            }
        )
    }
}

extension TargetDependency {
    static func fromPlatform(_ name: PlatformModuleName) -> Self {
        .project(
            target: name.rawValue,
            path: .relativeToRoot("Projects/Platform")
        )
    }
}