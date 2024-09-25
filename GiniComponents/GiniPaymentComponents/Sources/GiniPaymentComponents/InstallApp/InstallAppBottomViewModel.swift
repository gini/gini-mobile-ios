//
//  InstallAppBottomViewModel.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniUtilites
import GiniHealthAPILibrary

public protocol InstallAppBottomViewProtocol: AnyObject {
    func didTapOnContinue()
}

public final class InstallAppBottomViewModel {
    let primaryButtonConfiguration: ButtonConfiguration
    let configuration: InstallAppConfiguration
    let strings: InstallAppStrings
    let poweredByGiniViewModel: PoweredByGiniViewModel

    let selectedPaymentProvider: PaymentProvider?
    let paymentProviderColors: ProviderColors?
    let bankImageIcon: UIImage

    public weak var viewDelegate: InstallAppBottomViewProtocol?

    var moreInformationLabelText: String {
        isBankInstalled ?
        strings.moreInformationTipPattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "") :
        strings.moreInformationNotePattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
    }

    let titleText: String
    let bankToReplaceString = "[BANK]"

    var isBankInstalled: Bool {
        selectedPaymentProvider?.appSchemeIOS.canOpenURLString() == true
    }

    public init(selectedPaymentProvider: PaymentProvider?,
                installAppConfiguration: InstallAppConfiguration,
                strings: InstallAppStrings,
                primaryButtonConfiguration: ButtonConfiguration,
                poweredByGiniConfiguration: PoweredByGiniConfiguration,
                poweredByGiniStrings: PoweredByGiniStrings) {
        self.selectedPaymentProvider = selectedPaymentProvider
        self.bankImageIcon = selectedPaymentProvider?.iconData.toImage ?? UIImage()
        self.paymentProviderColors = selectedPaymentProvider?.colors
        self.configuration = installAppConfiguration
        self.strings = strings
        self.primaryButtonConfiguration = primaryButtonConfiguration
        self.poweredByGiniViewModel = PoweredByGiniViewModel(configuration: poweredByGiniConfiguration, strings: poweredByGiniStrings)

        titleText = strings.titlePattern.replacingOccurrences(of: bankToReplaceString, with: selectedPaymentProvider?.name ?? "")
    }

    func didTapOnContinue() {
        viewDelegate?.didTapOnContinue()
    }
}
