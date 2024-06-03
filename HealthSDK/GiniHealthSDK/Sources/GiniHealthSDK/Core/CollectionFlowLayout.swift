//
//  CollectionFlowLayout.swift
//  GiniHealth
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class CollectionFlowLayout: UICollectionViewFlowLayout{
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
