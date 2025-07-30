import ProjectDescription

public enum ProjectName: String, CaseIterable {
    case Core
    case Domain
    case Example
    case Features
    case Platform
    case UI
    case Benchmark
}

extension ProjectName {
    public var projectPath: Path {
        "Projects/\(rawValue)"
    }
}

extension ProjectName {
    public var project: Project {
        switch self {
        case .Core:
            Project(
                name: rawValue,
                targets: CoreModuleName.allCases.map(\.target)
            )
        case .Domain:
            Project(
                name: rawValue,
                targets: DomainModuleName.allCases.map(\.target)
            )
        case .Example:
            Project(
                name: rawValue,
                targets: ExampleModuleName.allCases.map(\.target)
            )
        case .Features:
            Project(
                name: rawValue,
                targets: FeaturesModuleName.allCases.map(\.target)
            )
        case .Platform:
            Project(
                name: rawValue,
                targets: PlatformModuleName.allCases.map(\.target)
            )
        case .UI:
            Project(
                name: rawValue,
                targets: UIModuleName.allCases.map(\.target)
            )
        case .Benchmark:
            Project(
                name: rawValue,
                targets: BenchmarkModuleName.allCases.flatMap { [$0.target, $0.testTarget] }
            )
        }
    }
}
