//
//  ImageAnalysisNoResultsViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

// This is unused and should be deleted!
/**
 The `ImageAnalysisNoResultsViewController` provides a custom no results screen which shows some capture
 suggestions when there is no results when analysing an image.
 */

final class ImageAnalysisNoResultsViewController: UIViewController {

    lazy var suggestionsCollectionView: CaptureSuggestionsCollectionView = {
        let collection = CaptureSuggestionsCollectionView()
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    lazy var bottomButton: UIButton = {
        let bottomButton = UIButton()
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.setTitle(self.bottomButtonText, for: .normal)
        bottomButton.titleLabel?.font = giniConfiguration.customFont.with(weight: .bold, size: 14, style: .caption1)
        let bottomButtonTextColor = GiniColor(light: .GiniCapture.accent1, dark: .GiniCapture.accent1).uiColor()
        bottomButton.setTitleColor(bottomButtonTextColor, for: .normal)
        bottomButton.setTitleColor(bottomButtonTextColor.withAlphaComponent(0.5), for: .highlighted)
        bottomButton.setImage(self.bottomButtonIconImage, for: .normal)
        if let highlightedImage = self.bottomButtonIconImage?.tintedImageWithColor(
            bottomButtonTextColor.withAlphaComponent(0.5)) {
            bottomButton.setImage(highlightedImage, for: .highlighted)
        }
        bottomButton.addTarget(self, action: #selector(didTapBottomButtonAction), for: .touchUpInside)
        bottomButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        bottomButton.backgroundColor = bottomButtonTextColor
        return bottomButton
    }()

    lazy var captureSuggestions: [(image: UIImage?, text: String)] = {
        var suggestions: [(image: UIImage?, text: String)] = [
            (UIImageNamedPreferred(named: "captureSuggestion1"),
             NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.1",
                                             comment: "First suggestion title for analysis screen")),
            (UIImageNamedPreferred(named: "captureSuggestion2"),
             NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.2",
                                              comment: "Second suggestion title for analysis screen")),
            (UIImageNamedPreferred(named: "captureSuggestion3"),
             NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.3",
                                              comment: "Third suggestion title for analysis screen")),
            (UIImageNamedPreferred(named: "captureSuggestion4"),
             NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.4",
                                              comment: "Fourth suggestion title for analysis screen"))
        ]

        if giniConfiguration.multipageEnabled {
            suggestions.append((UIImageNamedPreferred(named: "captureSuggestion5"),
                                NSLocalizedStringPreferredFormat("ginicapture.analysis.suggestion.5",
                                                            comment: "Fifth suggestion title for analysis screen")))
        }
        return suggestions
    }()

    fileprivate var subHeaderTitle: String?
    fileprivate var topViewText: String?
    fileprivate var topViewIcon: UIImage?
    fileprivate var bottomButtonText: String?
    fileprivate var bottomButtonIconImage: UIImage?
    fileprivate var giniConfiguration: GiniConfiguration

    var didTapBottomButton: (() -> Void) = { }

    convenience init(title: String? = nil,
                     subHeaderText: String? = NSLocalizedStringPreferredFormat(
                                                    "ginicapture.noresults.collection.header",
                                                    comment: "no results suggestions collection header title"),
                     topViewText: String = NSLocalizedStringPreferredFormat(
                                                    "ginicapture.noresults.warning",
                                                    comment: "Warning text that indicates that there " +
                                                             "was any result for this photo analysis"),
                     topViewIcon: UIImage? = UIImageNamedPreferred(named: "warningNoResults"),
                     bottomButtonText: String? = NSLocalizedStringPreferredFormat("ginicapture.noresults.gotocamera",
                                                    comment: "bottom button title (go to camera button)"),
                     bottomButtonIcon: UIImage? = UIImageNamedPreferred(named: "cameraIcon")) {
        self.init(title: title,
                  subHeaderText: subHeaderText,
                  topViewText: topViewText,
                  topViewIcon: topViewIcon,
                  bottomButtonText: bottomButtonText,
                  bottomButtonIcon: bottomButtonIcon,
                  giniConfiguration: .shared)
    }

    init(title: String? = nil,
         subHeaderText: String?,
         topViewText: String,
         topViewIcon: UIImage?,
         bottomButtonText: String?,
         bottomButtonIcon: UIImage?,
         giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.subHeaderTitle = subHeaderText
        self.topViewText = topViewText
        if let topViewIcon = topViewIcon {
            self.topViewIcon = topViewIcon.tintedImageWithColor(UIColor.GiniCapture.warning1)
        }
        self.bottomButtonText = bottomButtonText
        self.bottomButtonIconImage = bottomButtonIcon
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(title:subHeaderText:topViewText:topViewIcon:bottomButtonText:bottomButtonIcon:)" +
            "has not been implemented")
    }

    override func loadView() {
        super.loadView()
        edgesForExtendedLayout = []

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(suggestionsCollectionView)

        if bottomButtonText != nil {
            view.addSubview(bottomButton)
        }
        addConstraints()

        suggestionsCollectionView.dataSource = self
        suggestionsCollectionView.delegate = self
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.suggestionsCollectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    fileprivate func addConstraints() {

        // Collection View
        Constraints.active(item: suggestionsCollectionView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
        Constraints.active(item: self.view, attr: .leading, relatedBy: .equal, to: suggestionsCollectionView,
                           attr: .leading)
        Constraints.active(item: self.view, attr: .trailing, relatedBy: .equal, to: suggestionsCollectionView,
                           attr: .trailing)

        // Button
        if bottomButtonText != nil {
            Constraints.active(item: view.safeAreaLayoutGuide, attr: .bottom, relatedBy: .equal, to: bottomButton,
                               attr: .bottom, constant: 20)
            Constraints.active(item: self.view, attr: .leading, relatedBy: .equal, to: bottomButton, attr: .leading,
                               constant: -20, priority: 999)
            Constraints.active(item: self.view, attr: .trailing, relatedBy: .equal, to: bottomButton, attr: .trailing,
                               constant: 20, priority: 999)
            Constraints.active(item: self.view, attr: .centerX, relatedBy: .equal, to: bottomButton, attr: .centerX)
            Constraints.active(item: bottomButton, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                               constant: 60)
            Constraints.active(item: bottomButton, attr: .width, relatedBy: .lessThanOrEqual, to: nil,
                               attr: .notAnAttribute, constant: 375)
            Constraints.active(item: bottomButton, attr: .top, relatedBy: .equal, to: suggestionsCollectionView,
                               attr: .bottom, constant: 0, priority: 999)
        } else {
            Constraints.active(item: self.view, attr: .bottom, relatedBy: .equal, to: suggestionsCollectionView,
                               attr: .bottom, constant: 0, priority: 999)
        }

    }

    // MARK: Button action
    @objc func didTapBottomButtonAction() {
        didTapBottomButton()
    }
}

// MARK: UICollectionViewDataSource

extension ImageAnalysisNoResultsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return captureSuggestions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = CaptureSuggestionsCollectionView.captureSuggestionsCellIdentifier
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                       for: indexPath) as? CaptureSuggestionsCollectionCell)!
        cell.suggestionText.text = self.captureSuggestions[indexPath.row].text
        cell.suggestionText.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.suggestionImage.image = self.captureSuggestions[indexPath.row].image
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ImageAnalysisNoResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return suggestionsCollectionView.cellSize()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return suggestionsCollectionView.headerSize(withSubHeader: subHeaderTitle != nil)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = CaptureSuggestionsCollectionView.captureSuggestionsHeaderIdentifier
        let header = (collectionView
            .dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                              withReuseIdentifier: identifier,
                                              for: indexPath) as? CaptureSuggestionsCollectionHeader)!
        header.subHeaderTitle.text = self.subHeaderTitle
        header.subHeaderTitle.font = giniConfiguration.customFont.with(weight: .bold, size: 14, style: .body)
        header.topViewIcon.image = self.topViewIcon
        header.topViewText.text = self.topViewText
        header.topViewText.font = giniConfiguration.customFont.with(weight: .bold, size: 14, style: .body)
        header.shouldShowTopViewIcon = topViewIcon != nil
        header.shouldShowSubHeader = subHeaderTitle != nil
        return header
    }
}
