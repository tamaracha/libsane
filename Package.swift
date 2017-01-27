import PackageDescription

let package = Package(
    name: "libsane",
    dependencies: [
        .Package(url: "../Clibsane", majorVersion: 1)
    ]
)
