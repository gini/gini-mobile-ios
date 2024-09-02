//
//  GiniMerchant+PaymentComponentsConfigurationProvider.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites
import GiniPaymentComponents

extension GiniMerchant: PaymentComponentsConfigurationProvider {
    public var defaultStyleInputFieldConfiguration: GiniPaymentComponents.TextFieldConfiguration {
        GiniMerchantConfiguration.shared.defaultStyleInputFieldConfiguration
    }
    
    public var errorStyleInputFieldConfiguration: GiniPaymentComponents.TextFieldConfiguration {
        GiniMerchantConfiguration.shared.errorStyleInputFieldConfiguration
    }
    
    public var selectionStyleInputFieldConfiguration: GiniPaymentComponents.TextFieldConfiguration {
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
            errorLabelTextColor: GiniColor.feedback1.uiColor(),
            errorLabelFont: GiniMerchantConfiguration.shared.font(for: .captions2),
            lockIcon: GiniMerchantImage.lock.preferredUIImage()
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
            tipIcon: GiniMerchantImage.info.preferredUIImage(),
            tipFont: GiniMerchantConfiguration.shared.font(for: .captions1),
            tipLinkFont: GiniMerchantConfiguration.shared.font(for: .linkBold),
            tipAccentColor: GiniColor.standard2.uiColor(),
            tipTextColor: GiniColor.standard4.uiColor(),
            moreIcon: GiniMerchantImage.more.preferredUIImage(),
            bankIconBorderColor: GiniColor.standard5.uiColor(),
            appsBackgroundColor: GiniColor.standard6.uiColor(),
            singleAppTitleFont: GiniMerchantConfiguration.shared.font(for: .captions2),
            singleAppTitleColor: GiniColor.standard3.uiColor(),
            singleAppIconBorderColor: GiniColor.standard3.uiColor(),
            singleAppIconBackgroundColor: GiniColor(lightModeColor: .white, darkModeColor: GiniMerchantColorPalette.light3.preferredColor()).uiColor()
        )
    }
    
    public var paymentInfoConfiguration: PaymentInfoConfiguration {
        PaymentInfoConfiguration(
            giniFont: GiniMerchantConfiguration.shared.font(for: .button),
            answersFont: GiniMerchantConfiguration.shared.font(for: .body2),
            answerCellTextColor: GiniColor.standard1.uiColor(),
            answerCellLinkColor: GiniColor.accent1.uiColor(),
            questionsTitleFont: GiniMerchantConfiguration.shared.font(for: .subtitle1),
            questionsTitleColor: GiniColor.standard1.uiColor(),
            questionHeaderFont: GiniMerchantConfiguration.shared.font(for: .body1),
            questionHeaderTitleColor: GiniColor.standard1.uiColor(),
            questionHeaderMinusIcon: GiniMerchantImage.minus.preferredUIImage(),
            questionHeaderPlusIcon: GiniMerchantImage.plus.preferredUIImage(),
            bankCellBorderColor: GiniColor.standard5.uiColor(),
            payBillsTitleFont: GiniMerchantConfiguration.shared.font(for: .subtitle1),
            payBillsTitleColor: GiniColor.standard1.uiColor(),
            payBillsDescriptionFont: GiniMerchantConfiguration.shared.font(for: .body2),
            linksFont: GiniMerchantConfiguration.shared.font(for: .linkBold),
            linksColor: GiniColor.accent1.uiColor(),
            separatorColor: GiniColor.standard5.uiColor(),
            backgroundColor: GiniColor.standard7.uiColor()
        )
    }
    
    public var banksBottomConfiguration: BanksBottomConfiguration {
        BanksBottomConfiguration(
            descriptionAccentColor: GiniColor.standard3.uiColor(),
            descriptionFont: GiniMerchantConfiguration.shared.font(for: .captions1),
            selectBankAccentColor: GiniColor.standard2.uiColor(),
            selectBankFont: GiniMerchantConfiguration.shared.font(for: .subtitle1),
            closeTitleIcon: GiniMerchantImage.close.preferredUIImage(),
            closeIconAccentColor: GiniColor.standard2.uiColor(),
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
    
    public var primaryButtonConfiguration: GiniPaymentComponents.ButtonConfiguration {
        GiniMerchantConfiguration.shared.primaryButtonConfiguration
    }
    
    public var secondaryButtonConfiguration: GiniPaymentComponents.ButtonConfiguration {
        GiniMerchantConfiguration.shared.secondaryButtonConfiguration
    }
}
