// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KDBX",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "KDBX",
            targets: ["KDBX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tmthecoder/Argon2Swift", branch: "main"),
        .package(url: "https://github.com/1024jp/GzipSwift", from: Version(6, 0, 0)),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.7.1")),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "KDBX",
            dependencies: [
                .product(name: "Gzip", package: "GzipSwift"),
                "Encryption",
                "XML"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "StreamCiphers",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                "Encryption"
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "Encryption",
            dependencies: [
                .product(name: "Argon2Swift", package: "Argon2Swift"),
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .target(
            name: "XML",
            dependencies: [
            "StreamCiphers",
            .product(name: "SWXMLHash", package: "SWXMLHash"),
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "KDBXTests",
            dependencies: ["KDBX"],
            resources: [
                .copy("Passwords.kdbx"),
                .copy("EncryptedPasswords.kdbx"),
                .copy("EncryptedPasswords2.kdbx"),
                .copy("DecryptedPasswords.xml"),
                .copy("MockEncryptedPasswords.kdbx")
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
