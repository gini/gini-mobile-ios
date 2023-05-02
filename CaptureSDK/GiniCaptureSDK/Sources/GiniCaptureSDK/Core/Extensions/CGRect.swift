//
//  CGRect.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import UIKit

extension CGRect {

    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }

    func scaled(for scaleFactor: CGFloat) -> CGRect {
        return CGRect(x: self.minX * scaleFactor,
                      y: self.minY * scaleFactor,
                      width: self.width * scaleFactor,
                      height: self.height * scaleFactor)
    }
}
