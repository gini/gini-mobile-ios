//
//  AlbumsPickerViewControllerDelegateTests.swift
//  Example_Tests
//
//  Created by Nadya Karaban on 25.08.21.
//  Copyright © 2021 Gini GmbH. All rights reserved.
//

@testable import GiniCaptureSDK
import XCTest

final class AlbumsPickerViewControllerDelegateMock: AlbumsPickerViewControllerDelegate {
    var selectedAlbum: Album?

    func albumsPicker(_ viewController: AlbumsPickerViewController, didSelectAlbum album: Album) {
        selectedAlbum = album
    }
}
