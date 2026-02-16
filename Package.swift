// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package_dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0"),
    .package(url: "https://github.com/Py-Swift/PySwiftAST", from: .init(0, 0, 0)),
    .package(url: "https://github.com/kylef/PathKit", .upToNextMajor(from: "1.0.1")),
]



let package_targets: [Target] = [
    .target(
        name: "PySwift2Python",
        dependencies: [
            // add other package products or internal targets
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            "PathKit",
            .product(name: "PySwiftAST", package: "PySwiftAST"),
            .product(name: "PySwiftCodeGen", package: "PySwiftAST"),
            .product(name: "PyAstVisitors", package: "PySwiftAST"),
            .product(name: "PyFormatters", package: "PySwiftAST"),
        ],
        resources: [

        ]
    )
]



let package = Package(
    name: "PySwift2Python",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PySwift2Python",
            targets: ["PySwift2Python"]),
    ],
    dependencies: package_dependencies,
    targets: package_targets
)
