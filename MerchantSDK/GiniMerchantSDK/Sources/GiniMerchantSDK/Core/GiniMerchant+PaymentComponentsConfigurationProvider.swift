//
//  GiniMerchant+PaymentComponentsConfigurationProvider.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites
import GiniInternalPaymentSDK

extension GiniMerchant: PaymentComponentsConfigurationProvider {
    public var defaultStyleInputFieldConfiguration: TextFieldConfiguration {
        GiniMerchantConfiguration.shared.defaultStyleInputFieldConfiguration
    }
    
    public var errorStyleInputFieldConfiguration: TextFieldConfiguration {
        GiniMerchantConfiguration.shared.errorStyleInputFieldConfiguration
    }
    
    public var selectionStyleInputFieldConfiguration: TextFieldConfiguration {
        GiniMerchantConfiguration.shared.selectionStyleInputFieldConfiguration
    }
    
    public var showPaymentReviewCloseButton: Bool {
        false
    }
    
    public var paymentComponentButtonsHeight: CGFloat {
        GiniMerchantConfiguration.shared.paymentComponentButtonsHeight
    }
    
    public var paymentReviewContainerConfiguration: PaymentReviewContainerConfiguration {
        PaymentReviewContainerConfiguration(
            errorLabel: .init(
                textColor: GiniColor.feedback1.uiColor(),
                font: GiniMerchantConfiguration.shared.font(for: .captions2)
            ),
            banksPicker: .init(
                lockIcon: GiniMerchantImage.lock.preferredUIImage(),
                lockedFields: true,
                showBanksPicker: false,
                chevronDownIcon: nil,
                chevronDownIconColor: nil
            ),
            infoBar: .init(
                labelTextColor: GiniMerchantColorPalette.dark7.preferredColor(),
                labelFont: GiniMerchantConfiguration.shared.font(for: .captions1),
                backgroundColor: GiniMerchantColorPalette.success1.preferredColor(),
                containerBackgroundColor: GiniColor.standard7.uiColor()
            ),
            popupAnimationDuration: 0
        )
    }
    
    public var installAppConfiguration: InstallAppConfiguration {
        InstallAppConfiguration(
            titleAccentColor: GiniColor.standard2.uiColor(),
            titleFont: GiniMerchantConfiguration.shared.font(for: .subtitle1),
            moreInformationFont: GiniMerchantConfiguration.shared.font(for: .captions1),
            moreInformationTextColor: GiniColor.standard3.uiColor(),
            moreInformationAccentColor: GiniColor.standard3.uiColor(),
            moreInformationIcon: GiniMerchantImage.info.preferredUIImage(),
            appStoreIcon: GiniMerchantImage.appStore.preferredUIImage(),
            bankIconBorderColor: GiniColor.standard5.uiColor()
        )
    }

    public var bottomSheetConfiguration: BottomSheetConfiguration {
        BottomSheetConfiguration(
            backgroundColor: GiniColor.standard7.uiColor(),
            rectangleColor: GiniColor.standard5.uiColor(),
            dimmingBackgroundColor: GiniColor(lightModeColor: UIColor.black, darkModeColor: UIColor.white).uiColor().withAlphaComponent(0.4)
        )
    }
    
    public var shareInvoiceConfiguration: ShareInvoiceConfiguration {
        ShareInvoiceConfiguration(
            titleFont: GiniMerchantConfiguration.shared.font(for: .subtitle1),
            titleAccentColor: GiniColor.standard2.uiColor(),
            descriptionFont: GiniMerchantConfiguration.shared.font(for: .captions1),
            descriptionTextColor: GiniColor.standard3.uiColor(),
            descriptionAccentColor: GiniColor.standard3.uiColor(),
            paymentInfoBorderColor: GiniColor.standard5.uiColor(),
            titlePaymentInfoTextColor: GiniColor.standard4.uiColor(),
            subtitlePaymentInfoTextColor: GiniColor.standard1.uiColor(),
            titlepaymentInfoFont: GiniMerchantConfiguration.shared.font(for: .captions2),
            subtitlePaymentInfoFont: GiniMerchantConfiguration.shared.font(for: .body2),
        )
    }

    public var paymentInfoConfiguration: PaymentInfoConfiguration {
        PaymentInfoConfiguration(
            answerCell: .init(font: GiniMerchantConfiguration.shared.font(for: .body2),
                              textColor: GiniColor.standard1.uiColor(),
                              linkColor: GiniColor.accent1.uiColor()),
            questionHeader: .init(font: GiniMerchantConfiguration.shared.font(for: .body1),
                                  titleColor: GiniColor.standard1.uiColor(),
                                  minusIcon: GiniMerchantImage.minus.preferredUIImage(),
                                  plusIcon: GiniMerchantImage.plus.preferredUIImage(),
                                  iconTintColor: GiniColor.accent1.uiColor()),
            questionsTitle: .init(font: GiniMerchantConfiguration.shared.font(for: .subtitle1),
                                  color: GiniColor.standard1.uiColor()),
            payBills: .init(titleFont: GiniMerchantConfiguration.shared.font(for: .subtitle1),
                            titleColor: GiniColor.standard1.uiColor(),
                            descriptionFont: GiniMerchantConfiguration.shared.font(for: .body2)),
            links: .init(giniFont: GiniMerchantConfiguration.shared.font(for: .button),
                         font: GiniMerchantConfiguration.shared.font(for: .linkBold),
                         color: GiniColor.accent1.uiColor()),
            layout: .init(bankCellBorderColor: GiniColor.standard5.uiColor(),
                          separatorColor: GiniColor.standard5.uiColor(),
                          backgroundColor: GiniColor.standard7.uiColor())
        )
    }
    
    public var bankSelectionConfiguration: BankSelectionConfiguration {
        BankSelectionConfiguration(
            descriptionAccentColor: GiniColor.standard3.uiColor(),
            descriptionFont: GiniMerchantConfiguration.shared.font(for: .captions1),
            selectBankAccentColor: GiniColor.standard2.uiColor(),
            selectBankFont: GiniMerchantConfiguration.shared.font(for: .subtitle1),
            bankCellBackgroundColor: GiniColor.standard7.uiColor(),
            bankCellIconBorderColor: GiniColor.standard5.uiColor(),
            bankCellNameFont: GiniMerchantConfiguration.shared.font(for: .body1),
            bankCellNameAccentColor: GiniColor.standard1.uiColor(),
            bankCellSelectedBorderColor: GiniColor.accent1.uiColor(),
            bankCellNotSelectedBorderColor: GiniColor.standard5.uiColor(),
            bankCellSelectionIndicatorImage: GiniMerchantImage.selectionIndicator.preferredUIImage()
        )
    }
    
    public var paymentComponentsConfiguration: PaymentComponentsConfiguration {
        PaymentComponentsConfiguration(
            selectYourBankLabelFont: GiniMerchantConfiguration.shared.font(for: .subtitle2),
            selectYourBankAccentColor: GiniColor.standard1.uiColor(),
            chevronDownIcon: GiniMerchantImage.chevronDown.preferredUIImage(),
            chevronDownIconColor: GiniColor(lightModeColorName: .light7, darkModeColorName: .light1).uiColor(),
            notInstalledBankTextColor: GiniColor.standard4.uiColor()
        )
    }
    
    public var paymentReviewConfiguration: PaymentReviewConfiguration {
        PaymentReviewConfiguration(
            loadingIndicatorStyle: UIActivityIndicatorView.Style.large,
            loadingIndicatorColor: GiniMerchantColorPalette.accent1.preferredColor(),
            infoBarLabelTextColor: GiniMerchantColorPalette.dark7.preferredColor(),
            infoBarBackgroundColor: GiniMerchantColorPalette.success1.preferredColor(),
            mainViewBackgroundColor: GiniColor.standard7.uiColor(),
            infoContainerViewBackgroundColor: GiniColor.standard7.uiColor(), 
            paymentReviewClose: GiniMerchantImage.paymentReviewClose.preferredUIImage(),
            backgroundColor: GiniColor(lightModeColorName: .light7, darkModeColorName: .light7).uiColor(),
            rectangleColor: GiniColor.standard5.uiColor(),
            infoBarLabelFont: GiniMerchantConfiguration.shared.font(for: .captions1),
            statusBarStyle: .default,
            pageIndicatorTintColor: GiniColor.standard4.uiColor(),
            currentPageIndicatorTintColor: GiniColor(lightModeColorName: .dark2, darkModeColorName: .light5).uiColor(),
            isInfoBarHidden: true
        )
    }
    
    public var poweredByGiniConfiguration: PoweredByGiniConfiguration {
        PoweredByGiniConfiguration(
            poweredByGiniLabelFont: GiniMerchantConfiguration.shared.font(for: .captions2),
            poweredByGiniLabelAccentColor: GiniColor.standard4.uiColor(),
            giniIcon: GiniMerchantImage.logo.preferredUIImage()
        )
    }
    
    public var moreInformationConfiguration: MoreInformationConfiguration {
        MoreInformationConfiguration(
            moreInformationAccentColor: GiniColor.standard2.uiColor(),
            moreInformationTextColor: GiniColor.standard4.uiColor(),
            moreInformationLinkFont: GiniMerchantConfiguration.shared.font(for: .captions2),
            moreInformationIcon: GiniMerchantImage.info.preferredUIImage()
        )
    }
    
    public var primaryButtonConfiguration: GiniInternalPaymentSDK.ButtonConfiguration {
        GiniMerchantConfiguration.shared.primaryButtonConfiguration
    }
    
    public var secondaryButtonConfiguration: GiniInternalPaymentSDK.ButtonConfiguration {
        GiniMerchantConfiguration.shared.secondaryButtonConfiguration
    }
}
