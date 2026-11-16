// swift-tools-version: 5.9

import PackageDescription;

let package = Package(
    name: "DockPosition",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DockPosition",targets: ["DockPosition"])
    ],
    targets: [
        .executableTarget(name: "DockPosition")
    ]
);