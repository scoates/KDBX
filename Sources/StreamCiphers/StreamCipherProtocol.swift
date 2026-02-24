//
//  StreamProtocol.swift
//  
//
//  Created by John Jakobsen on 5/15/23.
//

import Foundation

public protocol StreamCipher: Sendable {
    mutating func decrypt(encryptedData: Data) throws -> Data
    mutating func encrypt(data: Data) throws -> Data
    mutating func refresh(key: Data, nonce: Data) throws
}
