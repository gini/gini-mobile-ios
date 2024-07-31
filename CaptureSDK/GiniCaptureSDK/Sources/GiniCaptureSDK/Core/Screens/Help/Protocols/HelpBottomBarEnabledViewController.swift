//
//  HelpBottomBarEnabledViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 05/10/2022.
//

import UIKit

protocol HelpBottomBarEnabledViewController: UIViewController {
    var bottomNavigationBar: UIView? {get set}
    var navigationBarBottomAdapter: HelpBottomNavigationBarAdapter? {get set}

    func configureBottomNavigationBar(
        configuration: GiniConfiguration,
        under underView: UIView)
}

extension HelpBottomBarEnabledViewController {

    func configureCustomTopNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated: true)
    }

    private func configureBottomNavigationBarConstraints(
        bottomNavigationBar: UIView,
        superView: UIView,
        under view: UIView
    ) {
        bottomNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(bottomNavigationBar)
        superView.bringSubviewToFront(bottomNavigationBar)
        NSLayoutConstraint.activate([
            bottomNavigationBar.bottomAnchor.constraint(equalTo: superView.bottomAnchor),
            bottomNavigationBar.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            bottomNavigationBar.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            bottomNavigationBar.heightAnchor.constraint(equalToConstant: bottomNavigationBar.frame.height),
            view.bottomAnchor.constraint(equalTo: bottomNavigationBar.topAnchor)
        ])
        superView.layoutSubviews()
    }

    func configureBottomNavigationBar(
        configuration: GiniConfiguration,
        under underView: UIView) {
        if configuration.bottomNavigationBarEnabled {
            configureCustomTopNavigationBar()
            if let bottomBarAdapter = configuration.helpNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBarAdapter
            } else {
                navigationBarBottomAdapter = DefaultHelpBottomNavigationBarAdapter()
            }

            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                GiniAnalyticsManager.track(event: .closeTapped, screenName: .help)
                self?.navigationController?.popViewController(animated: true)
            }
            if let adapter = navigationBarBottomAdapter {
                let injectedView = adapter.injectedView()
                configureBottomNavigationBarConstraints(
                    bottomNavigationBar: injectedView,
                    superView: view,
                    under: underView)
                bottomNavigationBar = injectedView
            }
        }
    }
}
