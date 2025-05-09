//
//  InvoicePhotoFlowState.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.

/**
 Represents the possible states of an education flow.

 - showMessage(messageIndex): Indicates that an education message should be shown. The message index
 specifies which message to display (e.g., 0 for first message, 1 for second message).
 - showOriginalFlow: Indicates that the original flow (e.g., spinning wheel) should be shown.
 */
enum EducationFlowState {
    case showMessage(messageIndex: Int)
    case showOriginalFlow
}
