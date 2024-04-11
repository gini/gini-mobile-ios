//
//  InstallAppBottomViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary

final class InstallAppBottomViewModel {
    
    weak var viewDelegate: PaymentProvidersBottomViewProtocol?

    var paymentProviders: [PaymentProviderAdditionalInfo] = []
    private var selectedPaymentProvider: PaymentProvider?
    
    let maximumViewHeight: CGFloat = UIScreen.main.bounds.height - Constants.topPaddingView
    let rowHeight: CGFloat = Constants.cellSizeHeight
    var bottomViewHeight: CGFloat = 0
    var heightTableView: CGFloat = 0

    let backgroundColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark7,
                                             darkModeColor: UIColor.GiniHealthColors.light7).uiColor()
    let rectangleColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                            darkModeColor: UIColor.GiniHealthColors.light5).uiColor()
    let dimmingBackgroundColor: UIColor = GiniColor(lightModeColor: UIColor.black,
                                                    darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)

    let titleText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.installAppBottom.title",
                                                                       comment: "Install App Bottom sheet title")
    let titleLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark2,
                                                        darkModeColor: UIColor.GiniHealthColors.light2).uiColor()
    var titleLabelFont: UIFont

    private var bankImageIconData: Data?
    var bankImageIcon: UIImage {
        if let bankImageIconData {
            return UIImage(data: bankImageIconData) ?? UIImage()
        }
        return UIImage()
    }
    var bankIconBorderColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark5,
                                        darkModeColor: UIColor.GiniHealthColors.light5).uiColor()

    let descriptionText: String = NSLocalizedStringPreferredFormat("ginihealth.paymentcomponent.paymentproviderslist.description",
                                                                   comment: "Top description text on payment providers bottom sheet")
    let descriptionLabelAccentColor: UIColor = GiniColor(lightModeColor: UIColor.GiniHealthColors.dark3,
                                                         darkModeColor: UIColor.GiniHealthColors.light3).uiColor()
    var descriptionLabelFont: UIFont

    init(paymentProviders: PaymentProviders, selectedPaymentProvider: PaymentProvider?) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIconData = selectedPaymentProvider?.iconData
        
        let defaultRegularFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let defaultBoldFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)

        self.titleLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.subtitle1] ?? defaultBoldFont
        self.descriptionLabelFont = GiniHealthConfiguration.shared.textStyleFonts[.caption1] ?? defaultRegularFont
        
        self.paymentProviders = []
        
        self.calculateHeights()
    }
    
    func updatePaymentProvidersInstalledState() {
        for index in 0 ..< paymentProviders.count {
            paymentProviders[index].isInstalled = isPaymentProviderInstalled(paymentProvider: paymentProviders[index].paymentProvider)
        }
        if selectedPaymentProvider == nil {
            selectedPaymentProvider = paymentProviders.first(where: { $0.isInstalled == true })?.paymentProvider
            if let indexSelected = paymentProviders.firstIndex(where: { $0.paymentProvider.id == selectedPaymentProvider?.id }) {
                paymentProviders[indexSelected].isSelected = true
            }
        }
    }
    
    private func calculateHeights() {
        let totalTableViewHeight = CGFloat(paymentProviders.count) * Constants.cellSizeHeight
        let totalBottomViewHeight = Constants.blankBottomViewHeight + totalTableViewHeight
        if totalBottomViewHeight > maximumViewHeight {
            self.heightTableView = maximumViewHeight - Constants.blankBottomViewHeight
            self.bottomViewHeight = maximumViewHeight
        } else {
            self.heightTableView = totalTableViewHeight
            self.bottomViewHeight = totalTableViewHeight + Constants.blankBottomViewHeight
        }
    }

    func paymentProvidersViewModel(paymentProvider: PaymentProviderAdditionalInfo) -> BankSelectionTableViewCellModel {
        BankSelectionTableViewCellModel(paymentProvider: paymentProvider)
    }
    
    func didTapOnClose() {
        viewDelegate?.didTapOnClose()
    }
    
    private func isPaymentProviderInstalled(paymentProvider: PaymentProvider) -> Bool {
        paymentProvider.appSchemeIOS.canOpenURLString()
    }
}

extension InstallAppBottomViewModel {
    enum Constants {
        static let blankBottomViewHeight: CGFloat = 200.0
        static let cellSizeHeight: CGFloat = 64.0
        static let topPaddingView: CGFloat = 100.0
    }
}
