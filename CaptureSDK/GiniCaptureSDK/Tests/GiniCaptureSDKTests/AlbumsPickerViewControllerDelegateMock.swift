//
//  AlbumsPickerViewControllerDelegateMock.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 3/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK

final class AlbumsPickerViewControllerDelegateMock: AlbumsPickerViewControllerDelegate {
    
    var selectedAlbum: Album?
    
    func albumsPicker(_ viewController: AlbumsPickerViewController, didSelectAlbum album: Album) {
        selectedAlbum = album
    }
    
}
