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

    @IBOutlet weak var nextBottom: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    fileprivate func configureView() {
        let configuration = GiniConfiguration.shared
        nextBottom.tintColor = .white
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
