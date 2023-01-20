//
//  GetTokenByIdResponse.swift
//  
//
//  Created by Brian Gonzalez on 1/19/23.
//

import Foundation
import BasisTheory
import AnyCodable

extension Token {
    public func toGetTokenByIdResponse(data: JSON) -> GetTokenByIdResponse {
        GetTokenByIdResponse(id: self.id, type: self.type, tenantId: self.tenantId, data: data, metadata: self.metadata, encryption: self.encryption, createdBy: self.createdBy, createdAt: self.createdAt, modifiedBy: self.modifiedBy, modifiedAt: self.modifiedAt, fingerprint: self.fingerprint, fingerprintExpression: self.fingerprintExpression, mask: self.mask, privacy: self.privacy, searchIndexes: self.searchIndexes, expiresAt: self.expiresAt, containers: self.containers)
    }
}

public struct GetTokenByIdResponse {
    public var id: String?
    public var type: String?
    public var tenantId: UUID?
    public var data: JSON?
    public var metadata: [String: String]?
    public var encryption: EncryptionMetadata?
    public var createdBy: UUID?
    public var createdAt: Date?
    public var modifiedBy: UUID?
    public var modifiedAt: Date?
    public var fingerprint: String?
    public var fingerprintExpression: String?
    public var mask: AnyCodable?
    public var privacy: Privacy?
    public var searchIndexes: [String]?
    public var expiresAt: Date?
    public var containers: [String]?
    
    public init(id: String? = nil, type: String? = nil, tenantId: UUID? = nil, data: JSON? = nil, metadata: [String : String]? = nil, encryption: EncryptionMetadata? = nil, createdBy: UUID? = nil, createdAt: Date? = nil, modifiedBy: UUID? = nil, modifiedAt: Date? = nil, fingerprint: String? = nil, fingerprintExpression: String? = nil, mask: AnyCodable? = nil, privacy: Privacy? = nil, searchIndexes: [String]? = nil, expiresAt: Date? = nil, containers: [String]? = nil) {
        self.id = id
        self.type = type
        self.tenantId = tenantId
        self.data = data
        self.metadata = metadata
        self.encryption = encryption
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.modifiedBy = modifiedBy
        self.modifiedAt = modifiedAt
        self.fingerprint = fingerprint
        self.fingerprintExpression = fingerprintExpression
        self.mask = mask
        self.privacy = privacy
        self.searchIndexes = searchIndexes
        self.expiresAt = expiresAt
        self.containers = containers
    }
}

