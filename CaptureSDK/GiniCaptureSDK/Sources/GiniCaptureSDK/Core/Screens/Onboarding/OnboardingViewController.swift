//
//  OnboardingViewController.swift
//  GiniCaptureSDK
//
//  Created by Nadya Karaban on 07.06.22.
//

import Foundation
import UIKit

class OnboardingViewController: UIViewController,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var pagesCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIStackView!
        @IBOutlet weak var viewContainer: UIStackView!
    fileprivate var navigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter?
    let configuration = GiniConfiguration.shared
    fileprivate func configureCollectionView() {
        pagesCollection.register(
            UINib(nibName: "OnboardingPageCell", bundle: giniCaptureBundle()),
            forCellWithReuseIdentifier: "onboardingPageCellIdentifier")
        pagesCollection.dataSource = self
        pagesCollection.delegate = self
        pagesCollection.setNeedsLayout()
        pagesCollection.layoutIfNeeded()
        pagesCollection.reloadData()
    }
    private func setupView() {
        configureCollectionView()
        configureBottomNavigation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = navigationBar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = navigationBar.topAnchor.constraint(equalTo: pageControl.bottomAnchor)
        let widthConstraint = navigationBar.widthAnchor.constraint(equalTo: view.widthAnchor)
        let heightConstraint = navigationBar.heightAnchor.constraint(equalToConstant: navigationBar.frame.height)
        let bottomConstraint = navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([horizontalConstraint,
                                     verticalConstraint,
                                     heightConstraint,
                                     widthConstraint,
                                     bottomConstraint])
    }
    private func configureBottomNavigation() {
        if configuration.bottomNavigationBarEnabled {
            removeButtons()
            if let customBottomNavigationBar = configuration.onboardingNavigationBarBottomAdapter {
                navigationBarBottomAdapter = customBottomNavigationBar
            } else {
                navigationBarBottomAdapter = DefaultOnboardingNavigationBarBottomAdapter()
            }
            navigationBarBottomAdapter?.setNextButtonClickedActionCallback {
                self.nextPage()
            }
            navigationBarBottomAdapter?.setSkipButtonClickedActionCallback {
                self.skip()
            }

            if let navigationBar =
                navigationBarBottomAdapter?.injectedView() {
                view.addSubview(navigationBar)
                layoutBottomNavigationBar(navigationBar)
            }
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(close))
        }
    }

    private func removeButtons() {
        nextButton.removeFromSuperview()
        containerView.removeArrangedSubview(nextButton)
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == pagesCollection {
            pagesCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    @objc private func close() {
        dismiss(animated: true)
    }

    private func nextPage() {
    }
    private func skip() {
        close()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }

    fileprivate func configureCell(_ cell: OnboardingPageCell) {
        let image = UIImageNamedPreferred(named: "onboardingPage1")
        cell.iconView.icon = image
        cell.fullText.text = "Ensure that the document is flat, and positioned within the frame"
        cell.title.text = "Flat paper within the frame"
    }
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingPageCell.identifier,
                                                         for: indexPath) as? OnboardingPageCell {
            configureCell(cell)
            return cell
        }
        fatalError("OnboardingPageCell wasn't initialized")
    }
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }

    // MARK: - For Display the page number in page controll of collection view Cell

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

class CollectionFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
