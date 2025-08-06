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

    var testTarget: Target {
        .target(
            name: "\(rawValue)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.multifilebenchmark.\(rawValue)Tests",
            sources: "Tests/\(rawValue)/**",
            dependencies: [
                .target(name: rawValue)
            ]
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

// MARK: - Project
extension BenchmarkModuleName {
    static var parentTarget: Target {
        .target(
            name: "Benchmark",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.multifilebenchmark.Benchmark",
            sources: [],
            dependencies: BenchmarkModuleName.allCases.map { .target(name: $0.rawValue) }
        )
    }

    static var parentTestTarget: Target {
        .target(
            name: "BenchmarkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.multifilebenchmark.BenchmarkTests",
            sources: "Tests/**",
            dependencies: [
                .target(name: "Benchmark"),
                .external(name: "Dependencies"),
            ]
        )
    }

    static var scheme: Scheme {
        .scheme(
            name: "Benchmark",
            shared: true,
            buildAction: .buildAction(targets: ["Benchmark"]),
            testAction: .testPlans(
                ["BenchmarkTests.xctestplan"],
                configuration: .debug
            ),
            runAction: .runAction(configuration: .debug)
        )
    }
}
