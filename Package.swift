// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "AxeFXUltraEditRemake", platforms: [.macOS(.v13)],
    products: [.executable(name: "AxeFXUltraEditRemake", targets: ["UltraEdit"]), .executable(name: "ultra-probe", targets: ["UltraProbe"])],
    targets: [.target(name: "UltraCore"), .executableTarget(name: "UltraEdit", dependencies: ["UltraCore"]), .executableTarget(name: "UltraProbe", dependencies: ["UltraCore"]), .testTarget(name: "UltraCoreTests", dependencies: ["UltraCore"])]
)
