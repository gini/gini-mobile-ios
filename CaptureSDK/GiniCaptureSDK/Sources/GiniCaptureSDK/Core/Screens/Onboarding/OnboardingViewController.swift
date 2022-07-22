//
//  OnboardingViewController.swift
//  GiniCaptureSDK
//
//  Created by Nadya Karaban on 07.06.22.
//

import Foundation
import UIKit

class OnboardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var pagesCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIStackView!
        @IBOutlet weak var viewContainer: UIStackView!
    fileprivate var navigationBarBottomProvider: DefaultBottomNavigationBar?

    
    fileprivate func configureCollectionView() {
        pagesCollection.register(UINib(nibName: "OnboardingPageCell", bundle: giniCaptureBundle()), forCellWithReuseIdentifier: "onboardingPageCellIdentifier")
        pagesCollection.dataSource = self
        pagesCollection.delegate = self
        
        pagesCollection.setNeedsLayout()
        pagesCollection.layoutIfNeeded()
        pagesCollection.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureBottomNavigation()
    }
    
    func configureBottomNavigation() {
        if GiniConfiguration.shared.bottomNavigationBarEnabled {
            removeButtons()
            if let someCustomView = DefaultBottomNavigationBar().loadNib() as?
                DefaultBottomNavigationBar {
                someCustomView.nextBottom.addTarget(self, action: #selector(close), for: .touchUpInside)

                let customItem = UIBarButtonItem(customView: someCustomView)
                
                toolbarItems = [customItem]
                navigationController?.toolbar.frame = CGRect(x: 0, y: view.frame.size.height - 120, width: view.frame.size.width, height: 120)
                navigationController?.setToolbarHidden(false, animated: false)

                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(close))
            }
        }
    }


    fileprivate func removeButtons() {
        nextButton.removeFromSuperview()
        containerView.layoutSubviews()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == pagesCollection {
            pagesCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
        @IBAction func close() {
            dismiss(animated: true)
        }
    
        @IBAction func nextPage() {
        }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingPageCellIdentifier", for: indexPath) as! OnboardingPageCell
        let image = UIImageNamedPreferred(named: "onboardingPage1")
        cell.iconView.icon = image

        cell.fullText.text = "Ensure that the document is flat, and positioned within the frame"
        cell.title.text = "Flat paper within the frame"
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        let width = collectionView.frame.width
        return CGSize(width: width, height: height)
    }

    // MARK: - For Display the page number in page controll of collection view Cell

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

class CollectionFlowLayout: UICollectionViewFlowLayout{
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        invalidateLayout(with: invalidationContext(forBoundsChange: newBounds))
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}
