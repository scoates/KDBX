//
//  File.swift
//
//
//  Created by John Jakobsen on 5/18/23.
//

import Foundation
import StreamCiphers

public protocol Serializable {
    func serialize(base64Encoded: Bool, streamCipher: inout (any StreamCipher)?) throws -> String
}

extension Serializable {
    public func serialize(base64Encoded: Bool = false, streamCipher: inout (any StreamCipher)?) throws -> String {
        return try serialize(base64Encoded: base64Encoded, streamCipher: &streamCipher)
    }
}

extension Optional where Wrapped: Serializable {
    func serialize(base64Encoded: Bool = false, streamCipher: inout (any StreamCipher)?) throws -> String {
        if let notNil = self {
            return try notNil.serialize(base64Encoded: base64Encoded, streamCipher: &streamCipher)
        }
        return ""
    }
}
