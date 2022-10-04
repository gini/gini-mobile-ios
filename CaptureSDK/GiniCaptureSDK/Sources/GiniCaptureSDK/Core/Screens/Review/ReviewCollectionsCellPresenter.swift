//
//  ReviewCollectionCellPresenter.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 12/28/18.
//

import UIKit

protocol ReviewCollectionCellPresenterDelegate: AnyObject {
    func multipage(_ reviewCollectionCellPresenter: ReviewCollectionCellPresenter,
                   didUpdateCellAt indexPath: IndexPath)
}

final class ReviewCollectionCellPresenter {
    weak var delegate: ReviewCollectionCellPresenterDelegate?
    var thumbnails: [String: [ThumbnailType: UIImage]] = [:]
    private let giniConfiguration: GiniConfiguration
    private let thumbnailsQueue = DispatchQueue(label: "Thumbnails queue")

    enum ThumbnailType {
        case big, small

        var scale: CGFloat {
            switch self {
            case .big:
                return 1.0
            case .small:
                return 1/4
            }
        }
    }

    init(giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
    }

    func setUp(_ cell: ReviewCollectionCell,
               with page: GiniCapturePage,
               at indexPath: IndexPath) -> UICollectionViewCell {

        if let thumbnail = self.thumbnails[page.document.id, default: [:]][.big] {
            cell.documentImageView.image = thumbnail
        } else {
            cell.documentImageView.image = nil
            fetchThumbnailImage(for: page, of: .big, in: cell, at: indexPath)
        }

        return cell
    }

    // MARK: - Thumbnails

    private func fetchThumbnailImage(for page: GiniCapturePage,
                                     of type: ThumbnailType,
                                     in cell: ReviewCollectionCell,
                                     at indexPath: IndexPath) {
        thumbnailsQueue.async { [weak self] in
            guard let self = self else { return }
            let thumbnail = UIImage.downsample(from: page.document.data,
                                               to: self.targetThumbnailSize(from: page.document.data),
                                               scale: type.scale)
            self.thumbnails[page.document.id, default: [:]][type] = thumbnail

            DispatchQueue.main.async {
                self.delegate?.multipage(self, didUpdateCellAt: indexPath)
            }
        }
    }

    private func targetThumbnailSize(from imageData: Data, screen: UIScreen = .main) -> CGSize {
        let imageSize = UIImage(data: imageData)?.size ?? .zero

        if imageSize.width > (screen.bounds.size.width * 2) {
            let maxWidth = screen.bounds.size.width * 2
            return CGSize(width: maxWidth, height: imageSize.height * maxWidth / imageSize.width)
        } else {
            return imageSize
        }

    }
}
