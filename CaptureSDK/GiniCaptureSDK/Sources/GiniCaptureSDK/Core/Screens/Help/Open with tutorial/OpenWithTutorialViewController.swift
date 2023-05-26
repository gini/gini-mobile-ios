//
//  OpenWithTutorialViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/20/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

typealias OpenWithTutorialStep = (title: String, subtitle: String, image: UIImage?)

final class OpenWithTutorialViewController: UICollectionViewController {
    let openWithTutorialCollectionCellIdentifier = "openWithTutorialCollectionCellIdentifier"
    let openWithTutorialCollectionHeaderIdentifier = "openWithTutorialCollectionHeaderIdentifier"
    
    let giniConfiguration: GiniConfiguration
    var appName: String {
        return giniConfiguration.openWithAppNameForTexts
    }
    
    lazy var items: [OpenWithTutorialStep] = {
        var items: [OpenWithTutorialStep] = [
            (.localized(resource: HelpStrings.openWithTutorialStep1Title),
             .localized(resource: HelpStrings.openWithTutorialStep1Subtitle),
             UIImageNamedPreferred(named: .localized(resource: ImageAssetsStrings.openWithTutorialStep1))),
            (.localized(resource: HelpStrings.openWithTutorialStep2Title),
             .localized(resource: HelpStrings.openWithTutorialStep2Subtitle, args:
                    appName,
                    appName),
             UIImageNamedPreferred(named: .localized(resource: ImageAssetsStrings.openWithTutorialStep2)))
        ]
        
        if self.giniConfiguration.shouldShowDragAndDropTutorial {
            items.append((.localized(resource: HelpStrings.openWithTutorialStep3Title),
                          .localized(resource: HelpStrings.openWithTutorialStep3Subtitle, args:
                                 appName,
                                 appName,
                                 appName),
                          UIImageNamedPreferred(named: .localized(resource: ImageAssetsStrings.openWithTutorialStep3))))
        }
        
        return items
    }()
    
    lazy var headerTitle: String = {
        return .localized(resource: HelpStrings.openWithTutorialCollectionHeader, args: appName)
    }()
    
    fileprivate var stepsCollectionLayout: OpenWithTutorialCollectionFlowLayout {
        return (collectionView?.collectionViewLayout as? OpenWithTutorialCollectionFlowLayout)!
    }
    
    init(giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
        super.init(collectionViewLayout: OpenWithTutorialCollectionFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init() should be called instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .localized(resource: HelpStrings.openWithTutorialTitle)

        collectionView?.backgroundColor = UIColor.from(giniColor: giniConfiguration.openWithScreenBackgroundColor)
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView?.register(OpenWithTutorialCollectionCell.self,
                                      forCellWithReuseIdentifier: openWithTutorialCollectionCellIdentifier)
        collectionView?.register(OpenWithTutorialCollectionHeader.self,
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                      withReuseIdentifier: openWithTutorialCollectionHeaderIdentifier)
        collectionView?.showsVerticalScrollIndicator = false
        stepsCollectionLayout.minimumLineSpacing = 1
        stepsCollectionLayout.minimumInteritemSpacing = 1
        stepsCollectionLayout.estimatedItemSize = estimatedCellSize(widthParentSize: view.frame.size)
        edgesForExtendedLayout = []
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.stepsCollectionLayout.estimatedItemSize = self.estimatedCellSize(widthParentSize: size)
            self.collectionView?.collectionViewLayout.invalidateLayout()
        })
    }
    
    private func estimatedCellSize(widthParentSize size: CGSize) -> CGSize {
        if size.width > size.height && UIDevice.current.isIpad {
            let width: CGFloat = round(UIScreen.main.bounds.width / CGFloat(items.count) -
                CGFloat(stepsCollectionLayout.minimumInteritemSpacing * CGFloat(items.count - 1)))
            return CGSize(width: width, height: size.height)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: 100)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: openWithTutorialCollectionCellIdentifier,
                                                      for: indexPath) as? OpenWithTutorialCollectionCell)!
        cell.fillWith(item: items[indexPath.row], at: indexPath.row, giniConfiguration: giniConfiguration)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let header = (collectionView
            .dequeueReusableSupplementaryView(ofKind: kind,
                                              withReuseIdentifier: openWithTutorialCollectionHeaderIdentifier,
                                              for: indexPath) as? OpenWithTutorialCollectionHeader)!
        header.headerTitle.font = giniConfiguration
            .customFont.with(weight: .regular,
                             size: OpenWithTutorialCollectionHeader.maxHeaderFontSize,
                             style: .body)
        header.headerTitle.text = headerTitle
        header.headerTitle.backgroundColor = UIColor.from(giniColor: giniConfiguration.openWithScreenBackgroundColor)
        return header
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension OpenWithTutorialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = collectionView.frame.width > collectionView.frame.height ? 0 : 130
        
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
}
