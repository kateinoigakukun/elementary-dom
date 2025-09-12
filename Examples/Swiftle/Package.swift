// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "Embedded",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "Swiftle",
            dependencies: [
                "ElementaryDOM",
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-z", "-Xlinker", "stack-size=5531072"], .when(platforms: [.wasi]))
            ]
        ),
        .target(
            name: "ElementaryDOM",
            dependencies: [
                "JavaScriptKit",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=complete"),
                .enableUpcomingFeature("StrictConcurrency=complete"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .swiftLanguageMode(.v5),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableExperimentalFeature("Extern"),
            ]
        ),
        .target(
            name: "JavaScriptKit",
            dependencies: ["_CJavaScriptKit"],
            swiftSettings: [
                .enableExperimentalFeature("Extern")
            ]
        ),
        .target(name: "_CJavaScriptKit"),
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
