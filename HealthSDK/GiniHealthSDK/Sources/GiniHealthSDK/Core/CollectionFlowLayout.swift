//
//  CollectionFlowLayout.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 09.04.21.
//

import UIKit

class CollectionFlowLayout: UICollectionViewFlowLayout{
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
