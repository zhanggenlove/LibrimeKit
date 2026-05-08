// swift-tools-version: 5.8
//
// LibrimeKit — Swift bindings to librime for iOS, packaged as
// SwiftPM binary targets pulled from GitHub Releases.
//
// Each `binaryTarget(url:checksum:)` points at a per-framework
// zip uploaded as a release asset. The matching sha256 checksum
// is what `swift package compute-checksum <zip>` produces — if
// the upstream asset is rebuilt the checksum here must be bumped
// or SwiftPM rejects the resolve.
//
// Architectures shipped: ios-arm64 (device) + ios-arm64-simulator
// (Apple silicon Mac). x86_64-simulator is not built.
//
// To cut a new release from the existing Frameworks/ tree, run
// `scripts/strip-and-package.sh` and update the URLs/checksums
// below to the new tag + manifest values.

import PackageDescription

// MARK: - Release version

/// The release tag to fetch all binaryTargets from. Bumping this
/// constant + the per-target checksum constants below is the
/// only thing required for a version upgrade — every URL is
/// derived from this.
let releaseTag = "v0.1.0"
let releaseURLPrefix =
    "https://github.com/zhanggenlove/LibrimeKit/releases/download/\(releaseTag)"

/// Per-target sha256 checksums emitted by
/// `swift package compute-checksum`. Match the v0.1.0 release
/// assets uploaded with that tag.
struct Checksums {
    static let librime           = "869ad448db92be5855e239f6f61a87d87e84974a4668509a3cbe4d766f294a54"
    static let boost_atomic      = "4db32b1015c0b2df5b55042e5ec2cced674f8e54e083f7d4aeb1e7db3a6c6925"
    static let boost_filesystem  = "d22bfd6aa9dd37333710aa5cea19fb065ab270bf2e55551841193bfac5b52af1"
    static let boost_regex       = "8b13fb6da177e777b76cc9e02d1aed342f922cb3c24f3029e3879f3c2f82fe33"
    static let boost_system      = "cb3a7cb48499686024923eef902c4327bb021eb8ef25da602a713b9108f56365"
    static let libleveldb        = "147cd30ee8763ccea573ca9778a5b2ed420c3adf5c91fe1b171fd1799422d103"
    static let libmarisa         = "cf66bb44fe11d5bc9ce39d61212e5f269bc4cc5045250bc79d62e34205bfc3bb"
    static let libopencc         = "715f2a323cc3f2b5aaeb3158533fc52ede265dbb54b07ea82f586c68604fe914"
    static let libyamlcpp        = "4c277cc6fa3f7330200f16d4454cd77c43c495714465bcb0d506d07d5fcdcc4c"
}

func remote(_ name: String, checksum: String) -> Target {
    return .binaryTarget(
        name: name,
        url: "\(releaseURLPrefix)/\(name).xcframework.zip",
        checksum: checksum)
}

let package = Package(
    name: "LibrimeKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "LibrimeKit", targets: ["LibrimeKit"]),
    ],
    targets: [
        // Binary targets — one per upstream library, downloaded
        // on `swift package resolve` from the v0.1.0 release.
        remote("librime",          checksum: Checksums.librime),
        remote("boost_atomic",     checksum: Checksums.boost_atomic),
        remote("boost_filesystem", checksum: Checksums.boost_filesystem),
        remote("boost_regex",      checksum: Checksums.boost_regex),
        remote("boost_system",     checksum: Checksums.boost_system),
        remote("libleveldb",       checksum: Checksums.libleveldb),
        remote("libmarisa",        checksum: Checksums.libmarisa),
        remote("libopencc",        checksum: Checksums.libopencc),
        remote("libyaml-cpp",      checksum: Checksums.libyamlcpp),

        // ObjC shim that exposes librime's C API to Swift via a
        // small wrapper (`lrk_api.h`/`.m`). Headers in `Sources/C`
        // are searchable from this target.
        .target(
            name: "RimeKitObjC",
            dependencies: [
                "librime",
                "boost_atomic",
                "boost_filesystem",
                "boost_regex",
                "boost_system",
                "libleveldb",
                "libmarisa",
                "libopencc",
                "libyaml-cpp",
            ],
            path: "Sources/ObjC",
            cSettings: [.headerSearchPath("../C")],
            cxxSettings: [.headerSearchPath("../C")],
            linkerSettings: [.linkedLibrary("c++")]),

        // Swift sugar on top of the ObjC shim — exposes
        // `Rime`, `RimeSchema`, candidate models etc.
        .target(
            name: "LibrimeKit",
            dependencies: ["RimeKitObjC"],
            path: "Sources/Swift"),

        .testTarget(
            name: "LibrimeKitTests",
            dependencies: ["LibrimeKit"]),
    ]
)
