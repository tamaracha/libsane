import PackageDescription

let package = Package(
    name: "libsane",
    dependencies: [
        .Package(url: "https://github.com/tamaracha/Clibsane", majorVersion: 1)
    ]
)
