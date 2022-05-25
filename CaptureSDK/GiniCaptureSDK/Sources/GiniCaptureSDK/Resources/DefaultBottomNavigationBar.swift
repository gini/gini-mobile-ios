//
//  File.swift
//  
//
//  Created by Nadya Karaban on 23.05.22.
//

import Foundation
import UIKit

final class DefaultBottomNavigationBar: UIView {
        
    var didTapBackButton: (() -> Void) = {}
    var didTapForwardButton: (() -> Void) = {}

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared
        self.titleLabel.text = "test title"
//        let buttonTitle = NSLocalizedStringPreferredFormat("ginicapture.albums.selectMorePhotosButton",
//                                                           comment: "Title for select more photos button")
//        selectPhotosButton.titleLabel?.font = configuration.customFont.with(weight: .regular, size: 16, style: .footnote)
//        selectPhotosButton.setTitle(buttonTitle, for: .normal)
//        selectPhotosButton.setTitleColor(UIColor.from(giniColor: configuration.albumsScreenSelectMorePhotosTextColor), for: .normal)
//        selectPhotosButton.sizeToFit()
        self.backButton.setImage(backButtonIcon(), for: .normal)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.didClickBackButton()
    }
    @IBAction func forwardButtonTapped(_ sender: Any) {
        self.didTapForwardButton()
    }
    
}
extension DefaultBottomNavigationBar: NavigationBarBottomProvider {
    
    func didClickBackButton() {
        self.didTapBackButton()
    }
    
    func backButtonIcon() -> UIImage {
        UIImageNamedPreferred(named: "arrowBack")!
    }
    
    func injectedView() -> UIView {
        self
    }
}
