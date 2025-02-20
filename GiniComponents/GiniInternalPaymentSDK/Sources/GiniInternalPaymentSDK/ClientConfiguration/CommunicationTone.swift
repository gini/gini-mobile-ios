//
//  CommunicationToneEnum.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

/**
 An enumeration representing the tone of communication.

 Use this enum to specify whether the communication style should be formal or informal.
 */
public enum CommunicationToneEnum: String, Codable, CaseIterable {
    case formal = "FORMAL"
    case informal = "INFORMAL"

    public func localizable() -> String {
        switch self {
            case .formal:
                "de"
            case .informal:
                "de_informal"
        }
    }

    public static let defaultCommunicationTone = CommunicationToneEnum.formal.localizable()
}
