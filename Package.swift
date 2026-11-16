// swift-tools-version: 5.9
// Copyright (c) 2026 Ignore Solutions
// SPDX-License-Identifier: MIT

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