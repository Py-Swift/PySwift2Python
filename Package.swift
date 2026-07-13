// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package_dependencies: [Package.Dependency] = [
    //.package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
    .package(path: "../PySwiftGenerators"),
    .package(url: "https://github.com/Py-Swift/PySwiftAST", from: .init(0, 0, 0)),
    .package(url: "https://github.com/kylef/PathKit", .upToNextMajor(from: "1.0.1")),
]



let package_targets: [Target] = [
    .target(
        name: "PySwift2Python",
        dependencies: [
            //.product(name: "SwiftSyntax", package: "swift-syntax"),
            //.product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "SwiftSyntaxWrapper", package: "PySwiftGenerators"),
            "PathKit",
            .product(name: "PySwiftAST", package: "PySwiftAST"),
            .product(name: "PySwiftCodeGen", package: "PySwiftAST"),
            .product(name: "PyAstVisitors", package: "PySwiftAST"),
            .product(name: "PyFormatters", package: "PySwiftAST"),
        ]
    ),
    .executableTarget(
        name: "StubGen",
        dependencies: [
            "PySwift2Python",
            "PathKit",
        ],
        path: "Sources/StubGen"
    ),
]



let package = Package(
    name: "PySwift2Python",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "PySwift2Python",
            targets: ["PySwift2Python"]),
        .executable(
            name: "pyswift2python",
            targets: ["StubGen"]),
    ],
    dependencies: package_dependencies,
    targets: package_targets
)
