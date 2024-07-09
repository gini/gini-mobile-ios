//
//  SSLPinningManager.swift
//
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import CryptoKit
import Foundation
import CommonCrypto

struct SSLPinningManager {
    private enum PinningError: Error {
        case noCertificatesFromServer
        case failedToGetPublicKey
        case failedToGetDataFromPublicKey
        case receivedWrongCertificate
    }
    
    private static let rsa2048ASN1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86,
        0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00
    ]

    private let pinnedKeyHashes: [String]
    
    init(pinnedKeyHashes: [String]) {
        self.pinnedKeyHashes = pinnedKeyHashes
    }

    func validate(challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        do {
            let trust = try validateAndGetTrust(with: challenge)
            completionHandler(.useCredential, URLCredential(trust: trust))
        } catch {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

//MARK: - private methods

private extension SSLPinningManager {
    func validateAndGetTrust(with challenge: URLAuthenticationChallenge) throws -> SecTrust {
        guard let trust = challenge.protectionSpace.serverTrust,
              let trustCertificateChain = trustCopyCertificateChain(trust),
              !trustCertificateChain.isEmpty else {
            throw PinningError.noCertificatesFromServer
        }

        for serverCertificate in trustCertificateChain {
            let publicKey = try getPublicKey(for: serverCertificate)
            let publicKeyHash = try getKeyHash(of: publicKey)

            if pinnedKeyHashes.contains(publicKeyHash) {
                return trust
            }
        }
        throw PinningError.receivedWrongCertificate
    }
    
    func getPublicKey(for certificate: SecCertificate) throws -> SecKey {
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)

        guard let trust, trustCreationStatus == errSecSuccess, let publicKey = trustCopyPublicKey(trust) else {
            throw PinningError.failedToGetPublicKey
        }
        
        return publicKey
    }
    
    func getKeyHash(of publicKey: SecKey) throws -> String {
        guard let publicKeyCFData = SecKeyCopyExternalRepresentation(publicKey, nil) else {
            throw PinningError.failedToGetDataFromPublicKey
        }

        let publicKeyData = (publicKeyCFData as NSData) as Data
        var publicKeyWithHeaderData = Data(Self.rsa2048ASN1Header)
        publicKeyWithHeaderData.append(publicKeyData)
        let publicKeyHashData = sha256(data: publicKeyWithHeaderData)
        return publicKeyHashData.base64EncodedString()
    }
}

//MARK: - private methods for capability with old ios versions

private extension SSLPinningManager {
    func trustCopyPublicKey(_ trust: SecTrust) -> SecKey? {
        if #available(iOS 14, macOS 11, tvOS 14, watchOS 7, visionOS 1, *) {
            return SecTrustCopyKey(trust)
        } else {
            return SecTrustCopyPublicKey(trust)
        }
    }
    
    func trustCopyCertificateChain(_ trust: SecTrust) -> [SecCertificate]? {
        if #available(iOS 15, macOS 11, tvOS 14, watchOS 7, visionOS 1, *) {
            return (SecTrustCopyCertificateChain(trust) as? [SecCertificate])
        } else {
            return (0..<SecTrustGetCertificateCount(trust)).compactMap { index in
                SecTrustGetCertificateAtIndex(trust, index)
            }
        }
    }

    func sha256(data: Data) -> Data {
        if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
            return Data(SHA256.hash(data: data))
        } else {
            var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes { buffer in
                _ = CC_SHA256(buffer.baseAddress!, CC_LONG(buffer.count), &hash)
            }
            return Data(hash)
        }
    }
}
