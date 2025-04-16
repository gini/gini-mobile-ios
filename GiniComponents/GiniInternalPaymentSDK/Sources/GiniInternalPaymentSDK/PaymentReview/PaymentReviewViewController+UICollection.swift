//
//  PaymentReviewViewController+UICollection.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension PaymentReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        model.numberOfCells
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PageCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.pageImageView.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        let cellModel = model.getCellViewModel(at: indexPath)
        cell.pageImageView.display(image: cellModel.preview)
        cell.pageImageView.accessibilityTraits = .image
        cell.pageImageView.isAccessibilityElement = true
        cell.pageImageView.accessibilityLabel = model.strings.invoiceImageAccessibilityLabel
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if !UIDevice.isPortrait() {
            return UIEdgeInsets(top: 0, left: -(Constants.landscapeCollectionViewLeftInsetRatio * collectionView.frame.width), bottom: 0, right: 0)
        } else {
            return .zero
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }

    // MARK: - For Display the page number in page controll of collection view Cell

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
