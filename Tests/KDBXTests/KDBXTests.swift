//
//  KDBXTests.swift
//
//
//  Created by John Jakobsen on 7/26/23.
//

import Foundation
import XCTest
import XML
@testable import KDBX

class KDBXTests: XCTestCase {
    func helperResourcePath(name: String, ext: String) -> URL? {
        return Bundle.module.url(forResource: name, withExtension: ext)
    }

    func helperCreateMockManager() throws -> KDBX {
        let mockDB = try KDBX(title: "Test", description: "")
        mockDB.meta.setGenerator("KeePassXC")
        let entry1 = EntryXML(name: "Testing")
        let keyVals1 = [
            KeyValXML(key: "Notes", value: ""),
            KeyValXML(key: "Password", value: "testing", protected: true),
            KeyValXML(key: "URL", value: ""),
            KeyValXML(key: "UserName", value: "John"),
        ]
        for kv in keyVals1 {
            entry1.addKeyVal(keyVal: kv)
        }
        mockDB.group.addEntry(entry: entry1)

        let entry2 = EntryXML(name: "Testing2")
        let keyVals2 = [
            KeyValXML(key: "Notes", value: ""),
            KeyValXML(key: "Password", value: "testing2", protected: true),
            KeyValXML(key: "URL", value: ""),
            KeyValXML(key: "UserName", value: "john"),
        ]
        for kv in keyVals2 {
            entry2.addKeyVal(keyVal: kv)
        }
        mockDB.group.addEntry(entry: entry2)
        mockDB.group.setIconID(iconID: "48")

        return mockDB
    }

    func testKDBXFromRead() throws {
        guard let resourceURL = helperResourcePath(name: "EncryptedPasswords", ext: "kdbx") else {
            XCTFail("Could not find EncryptedPasswords.kdbx resource")
            return
        }
        let stream = InputStream(url: resourceURL)
        stream?.open()
        let kdbx = try KDBX.fromEncryptedStream(stream!, password: "butter")
        stream?.close()
        print(kdbx.meta)
        print(kdbx.group)

        let mockDB = try helperCreateMockManager()
        XCTAssertTrue(mockDB.meta.isEqual(kdbx.meta))
        XCTAssertTrue(mockDB.group.isEqual(kdbx.group))
    }

    func testEncryption() throws {
        let mockKDBX = try helperCreateMockManager()

        // Write to a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent("MockEncryptedPasswords.kdbx")

        let stream = OutputStream(url: tempFileURL, append: false)
        stream?.open()
        try mockKDBX.encryptToStream(stream!, password: "butter")
        stream?.close()

        let mockEncryptedStream = InputStream(url: tempFileURL)
        mockEncryptedStream?.open()
        let mockKDBXFromEncryptedFile = try KDBX.fromEncryptedStream(mockEncryptedStream!, password: "butter")
        mockEncryptedStream?.close()
        XCTAssertTrue(mockKDBX.meta.isEqual(mockKDBXFromEncryptedFile.meta))
        XCTAssertTrue(mockKDBX.group.isEqual(mockKDBXFromEncryptedFile.group))

        // Clean up
        try? FileManager.default.removeItem(at: tempFileURL)
    }

}
