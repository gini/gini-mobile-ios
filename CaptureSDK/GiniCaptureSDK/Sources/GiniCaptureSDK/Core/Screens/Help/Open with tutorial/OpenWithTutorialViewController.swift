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
        return (self.collectionView?.collectionViewLayout as? OpenWithTutorialCollectionFlowLayout)!
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
        self.title = .localized(resource: HelpStrings.openWithTutorialTitle)
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = Colors.Gini.dynamicPearl
        } else {
            view.backgroundColor = Colors.Gini.pearl
        }
        
        self.collectionView!.backgroundColor = nil
        self.collectionView.contentInsetAdjustmentBehavior = .never

        self.collectionView!.register(OpenWithTutorialCollectionCell.self,
                                      forCellWithReuseIdentifier: openWithTutorialCollectionCellIdentifier)
        self.collectionView!.register(OpenWithTutorialCollectionHeader.self,
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                      withReuseIdentifier: openWithTutorialCollectionHeaderIdentifier)
        
        stepsCollectionLayout.minimumLineSpacing = 1
        stepsCollectionLayout.minimumInteritemSpacing = 1
        stepsCollectionLayout.estimatedItemSize = estimatedCellSize(widthParentSize: view.frame.size)
        self.edgesForExtendedLayout = []
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
            let width: CGFloat = round(UIScreen.main.bounds.width / CGFloat(self.items.count) -
                CGFloat(self.stepsCollectionLayout.minimumInteritemSpacing * CGFloat(self.items.count - 1)))
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
