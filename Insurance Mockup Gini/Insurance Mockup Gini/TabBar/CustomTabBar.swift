//
//  CustomTabBar.swift
//  Gini
//
//  Inspired from quacklabs/customTabBarSwift @ GitHub
//
//  Created by David Vizaknai on 21.03.2022.
//



import UIKit

class CustomTabBar: UIView {
    var itemTapped: ((_ tab: Int) -> Void)?
    var activeItem: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(menuItems: [TabBarItem], frame: CGRect) {
        self.init(frame: frame)

        backgroundColor = .white
        isUserInteractionEnabled = true
        
        clipsToBounds = true
        
        for i in 0 ..< menuItems.count {
            let itemWidth = self.frame.width / CGFloat(menuItems.count)
            let leadingAnchor = itemWidth * CGFloat(i)
            
            let itemView = createTabItem(item: menuItems[i])
            itemView.tag = i
            
            self.addSubview(itemView)
            
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.clipsToBounds = true
            
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalToConstant: Constants.itemHeight),
                itemView.widthAnchor.constraint(equalToConstant: itemWidth),
                
                itemView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingAnchor),
                itemView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topPadding),
            ])
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.activateTab(tab: 0)
    }
    
    func createTabItem(item: TabBarItem) -> UIView {
        let tabBarItem = UIStackView(frame: CGRect.zero)
        let itemTitleLabel = UILabel(frame: CGRect.zero)
        let itemIconView = UIImageView(frame: CGRect.zero)
        
        // adding tags to get views for modification when selected/unselected
        
        tabBarItem.tag = 11
        itemTitleLabel.tag = 12
        itemIconView.tag = 13

        itemTitleLabel.text = item.displayTitle
        itemTitleLabel.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .semibold)
        itemTitleLabel.textColor = .gray
        itemTitleLabel.textAlignment = .center
        
        itemIconView.image = item.icon!.withRenderingMode(.automatic)
        itemIconView.contentMode = .scaleAspectFit

        tabBarItem.axis = .vertical
        tabBarItem.layer.backgroundColor = UIColor.clear.cgColor
        tabBarItem.distribution = .fill
        tabBarItem.alignment = .center

        tabBarItem.addArrangedSubview(itemIconView)
        tabBarItem.addArrangedSubview(itemTitleLabel)

        tabBarItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap)))
        return tabBarItem
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        self.switchTab(from: activeItem, to: sender.view!.tag)
    }
    
    func switchTab(from: Int, to: Int) {
        deactivateTab(tab: from)
        activateTab(tab: to)
    }
    
    func activateTab(tab: Int) {
        self.itemTapped?(tab)
        self.activeItem = tab

        let activeTab = self.subviews[tab]
        (activeTab.viewWithTag(12) as? UILabel)?.textColor = Style.TabBarColor.activeColor
        (activeTab.viewWithTag(13) as? UIImageView)?.tintColor = Style.TabBarColor.activeColor
    }

    func deactivateTab(tab: Int) {

        let inactiveTab = self.subviews[tab]

        (inactiveTab.viewWithTag(12) as? UILabel)?.textColor = Style.TabBarColor.inactiveColor
        (inactiveTab.viewWithTag(13) as? UIImageView)?.tintColor = Style.TabBarColor.inactiveColor
    }
}

private extension CustomTabBar {
    enum Constants {
        static let itemHeight: CGFloat = 48
        static let topPadding: CGFloat = 16
        static let fontSize: CGFloat = 12
    }
}
