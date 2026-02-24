//
//  StreamCiphers.swift
//
//
//  Created by John Jakobsen on 5/10/23.
//

import Foundation
@preconcurrency import CryptoSwift
import Encryption

public final class ChaChaStream: StreamCipher, @unchecked Sendable {

    private var chacha: ChaCha20
    private var key: Data
    private var nonce: Data
    private var encryptOffset: Int = 0
    private var decryptOffset: Int = 0

    public init(key: Data, nonce: Data) throws {
        self.chacha = try ChaCha20(key: Array(key), iv: Array(nonce))
        self.key = key
        self.nonce = nonce
    }

    public func decrypt(encryptedData: Data) throws -> Data {
        let paddedData = padDataWithDummyBytes(data: encryptedData, paddingLength: decryptOffset)
        let decryptedDataWithPad = try Data(chacha.decrypt(Array(paddedData)))
        let decryptedData = decryptedDataWithPad.subdata(in: decryptOffset..<decryptedDataWithPad.count)
        decryptOffset += encryptedData.count

        return decryptedData
    }

    public func encrypt(data: Data) throws -> Data {
        let paddedData = padDataWithDummyBytes(data: data, paddingLength: encryptOffset)
        let encryptedDataWithPad = try Data(chacha.encrypt(Array(paddedData)))
        let encryptedData = encryptedDataWithPad.subdata(in: encryptOffset..<encryptedDataWithPad.count)
        encryptOffset += data.count

        return encryptedData
    }

    public func refresh(key: Data, nonce: Data) throws {
        self.key = key
        self.nonce = nonce
        self.encryptOffset = 0
        self.decryptOffset = 0
        self.chacha = try ChaCha20(key: Array(key), iv: Array(nonce))
    }

    public func reset() {
        encryptOffset = 0
        decryptOffset = 0
    }

    private func padDataWithDummyBytes(data: Data, paddingLength: Int) -> Data {
        if (paddingLength <= 0) {
            return data
        }
        let dummyBytes = Data(repeating: 0x00, count: paddingLength)
        return dummyBytes + data
    }
}
