# LibrimeKit

Swift bindings for [librime](https://github.com/rime/librime), packaged as a
SwiftPM binary distribution for iOS.

## What's inside

- **C/ObjC shim** (`Sources/ObjC` + `Sources/C`) — exposes librime's C API
  through a thin Objective-C wrapper (`LRK*` types) so it's safe to call from
  Swift.
- **Swift sugar** (`Sources/Swift`) — `Rime`, `RimeSchema`, candidate models,
  notifications, lifecycle helpers.
- **Binary targets** — librime + boost (atomic / filesystem / regex / system) +
  leveldb + marisa + opencc + yaml-cpp, prebuilt as iOS xcframeworks and
  uploaded to GitHub Releases.

## Architectures

Each release ships **only**:

- `ios-arm64` (device)
- `ios-arm64-simulator` (Apple silicon Mac)

`x86_64-simulator` is not built. macOS / tvOS / watchOS / visionOS / Mac
Catalyst slices are not shipped — open an issue if you need them.

## Versions

| Component | Version |
|----------|---------|
| librime  | 1.16.1 (built with `-DENABLE_LOGGING=OFF`) |

## Usage

Add as a Swift Package dependency to your iOS app:

```swift
.package(url: "https://github.com/zhanggenlove/LibrimeKit.git", from: "0.1.0"),
```

Then link `LibrimeKit` against any target that needs the IME.

```swift
import LibrimeKit

// Lifecycle
Rime.shared.startService(...)
let candidates = Rime.shared.process(input: "nihao")
```

## Releasing a new version

`Package.swift` references each xcframework via
`binaryTarget(url:checksum:)` pointing at a GitHub Release asset. To cut a new
version after dropping fresh binaries into `Frameworks/`:

```bash
# 1. Strip non-iOS slices, zip each xcframework, emit checksums.
./scripts/strip-and-package.sh

# Output goes to /tmp/librimekit-release/
#   stripped/      ← rebuilt xcframeworks (ios-arm64 + ios-arm64-simulator)
#   zips/          ← .xcframework.zip release assets
#   manifest.txt   ← name<TAB>sha256<TAB>size

# 2. Bump `releaseTag` and the `Checksums.*` constants in Package.swift
#    using values from manifest.txt.

# 3. Commit, tag, push.
git add Package.swift README.md
git commit -m "Release v0.x.y"
git tag v0.x.y
git push origin master --tags

# 4. Create the GitHub Release and upload the asset zips.
gh release create v0.x.y \
  /tmp/librimekit-release/zips/*.xcframework.zip \
  --title "v0.x.y" \
  --notes "..."
```

The xcframework binaries themselves are NOT committed to the repo —
`Frameworks/` is in `.gitignore`. Builders need to fetch / rebuild them
locally and run the script. A future GitHub Action will rebuild from upstream
sources automatically; today this is manual.

## License

The wrapper code in this repository is BSD-3-Clause licensed (matching librime
itself). Bundled binary frameworks retain their upstream licenses — see
`THIRD_PARTY_LICENSES.md` for the full attribution list.
