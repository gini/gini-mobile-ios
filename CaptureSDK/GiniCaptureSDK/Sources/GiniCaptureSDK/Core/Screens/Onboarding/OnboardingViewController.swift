//
//  OnboardingViewController.swift
//  GiniCaptureSDK
//
//  Created by Nadya Karaban on 07.06.22.
//

import Foundation
import UIKit

class OnboardingViewController: UIViewController {
    @IBOutlet weak var pagesCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIStackView!
        @IBOutlet weak var viewContainer: UIStackView!
    private var navigationBarBottomAdapter: OnboardingNavigationBarBottomAdapter?
    private (set) var dataSource: OnboardingDataSource
    private let configuration = GiniConfiguration.shared
    lazy var skipButton = UIBarButtonItem(title: "Skip",
                                          style: .plain,
                              target: self,
                              action: #selector(close))
    init() {
        dataSource = OnboardingDataSource(configuration: configuration)
        super.init(nibName: "OnboardingViewController", bundle: giniCaptureBundle())
      }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func configureCollectionView() {
        pagesCollection.register(
            UINib(nibName: "OnboardingPageCell", bundle: giniCaptureBundle()),
            forCellWithReuseIdentifier: OnboardingPageCell.reuseIdentifier)
        pagesCollection.setNeedsLayout()
        pagesCollection.layoutIfNeeded()
        pagesCollection.reloadData()
        pagesCollection.isPagingEnabled = true
        pagesCollection.dataSource = dataSource
        pagesCollection.delegate = dataSource
        dataSource.delegate = self
    }

    private func configurePageControl() {
        pageControl.pageIndicatorTintColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor().withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = GiniColor(
            light: UIColor.GiniCapture.dark1,
            dark: UIColor.GiniCapture.light1
        ).uiColor()
        pageControl.numberOfPages = dataSource.itemSections.count
    }

    private func setupView() {
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.light2, dark: UIColor.GiniCapture.dark2).uiColor()
        configureCollectionView()
        configureBottomNavigation()
        configurePageControl()
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
            nextButton.layer.cornerRadius = 14
            nextButton.setTitle("Next", for: .normal)
            nextButton.backgroundColor = GiniColor(
                light: UIColor.GiniCapture.accent1,
                dark: UIColor.GiniCapture.accent1
            ).uiColor()
            nextButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
            navigationItem.rightBarButtonItem = skipButton
        }
    }

    private func removeButtons() {
        nextButton.removeFromSuperview()
        containerView.removeArrangedSubview(nextButton)
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func nextPage() {
        if dataSource.currentPage < dataSource.itemSections.count - 1 {
            let index = IndexPath(item: dataSource.currentPage + 1, section: 0)
            pagesCollection.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        } else {
            close()
        }
    }

    private func skip() {
        close()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if #available(iOS 13, *) {
            view.layoutSubviews()
        } else {
            let offsetX = CGFloat(max(dataSource.currentPage, 0)) * size.width
            pagesCollection.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pagesCollection.collectionViewLayout.invalidateLayout()
    }
}

extension OnboardingViewController: OnboardingScreen {
    func didScroll(page: Int) {
        if page == dataSource.itemSections.count - 1 {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = skipButton
        }
        pageControl.currentPage = page
    }
}

class CollectionFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        collectionView?.reloadData()
        return true
    }
}
