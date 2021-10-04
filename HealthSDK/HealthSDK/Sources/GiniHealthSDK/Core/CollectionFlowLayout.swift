//
//  CollectionFlowLayout.swift
//  GiniPayBusiness
//
//  Created by Nadya Karaban on 09.04.21.
//

import Foundation
class CollectionFlowLayout: UICollectionViewFlowLayout{
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
