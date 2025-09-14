// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "Embedded",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "Swiftle",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-z", "-Xlinker", "stack-size=5531072"], .when(platforms: [.wasi]))
            ]
        ),
        .plugin(
            name: "PackageToJS",
            capability: .command(
                intent: .custom(verb: "js", description: "Convert a Swift package to a JavaScript package")
            ),
            path: "Plugins/PackageToJS/Sources"
        ),
    ],
    swiftLanguageModes: [.v5]
)
