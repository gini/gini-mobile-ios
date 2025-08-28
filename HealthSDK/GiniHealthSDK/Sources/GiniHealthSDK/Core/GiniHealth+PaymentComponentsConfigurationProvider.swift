//
//  GiniHealth+PaymentComponentsConfigurationProvider.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites
import GiniInternalPaymentSDK

extension GiniHealth: PaymentComponentsConfigurationProvider {
    public var defaultStyleInputFieldConfiguration: TextFieldConfiguration {
        GiniHealthConfiguration.shared.defaultStyleInputFieldConfiguration
    }

    public var errorStyleInputFieldConfiguration: TextFieldConfiguration {
        GiniHealthConfiguration.shared.errorStyleInputFieldConfiguration
    }

    public var selectionStyleInputFieldConfiguration: TextFieldConfiguration {
        GiniHealthConfiguration.shared.selectionStyleInputFieldConfiguration
    }

    public var showPaymentReviewCloseButton: Bool {
        GiniHealthConfiguration.shared.showPaymentReviewCloseButton
    }

    public var paymentComponentButtonsHeight: CGFloat {
        GiniHealthConfiguration.shared.paymentComponentButtonsHeight
    }

    public var paymentReviewContainerConfiguration: PaymentReviewContainerConfiguration {
        PaymentReviewContainerConfiguration(
            errorLabelTextColor: GiniColor.feedback1.uiColor(),
            errorLabelFont: GiniHealthConfiguration.shared.font(for: .captions2),
            lockIcon: GiniHealthImage.lock.preferredUIImage(),
            lockedFields: GiniHealthConfiguration.shared.useInvoiceWithoutDocument ? true : false,
            showBanksPicker: true,
            chevronDownIcon: GiniHealthImage.chevronDown.preferredUIImage(),
            chevronDownIconColor: GiniColor(lightModeColorName: .light7, darkModeColorName: .light1).uiColor()
        )
    }

    public var installAppConfiguration: InstallAppConfiguration {
        InstallAppConfiguration(
            titleAccentColor: GiniColor.standard2.uiColor(),
            titleFont: GiniHealthConfiguration.shared.font(for: .subtitle1),
            moreInformationFont: GiniHealthConfiguration.shared.font(for: .captions1),
            moreInformationTextColor: GiniColor.standard4.uiColor(),
            moreInformationAccentColor: GiniColor.standard8.uiColor(),
            moreInformationIcon: GiniHealthImage.info.preferredUIImage(),
            appStoreIcon: GiniHealthImage.appStore.preferredUIImage(),
            bankIconBorderColor: GiniColor.standard5.uiColor(),
            closeIcon: GiniHealthImage.close.preferredUIImage(),
            closeIconAccentColor: GiniColor.standard2.uiColor()
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
            titleFont: GiniHealthConfiguration.shared.font(for: .subtitle1),
            titleAccentColor: GiniColor.standard2.uiColor(),
            descriptionFont: GiniHealthConfiguration.shared.font(for: .captions1),
            descriptionTextColor: GiniColor.standard3.uiColor(),
            descriptionAccentColor: GiniColor.standard4.uiColor(),
            paymentInfoBorderColor: GiniColor.standard5.uiColor(),
            titlePaymentInfoTextColor: GiniColor.standard4.uiColor(),
            subtitlePaymentInfoTextColor: GiniColor.standard1.uiColor(),
            titlepaymentInfoFont: GiniHealthConfiguration.shared.font(for: .captions2),
            subtitlePaymentInfoFont: GiniHealthConfiguration.shared.font(for: .body2),
            closeIcon: GiniHealthImage.close.preferredUIImage(),
            closeIconAccentColor: GiniColor.standard2.uiColor()
        )
    }

    public var paymentInfoConfiguration: PaymentInfoConfiguration {
        PaymentInfoConfiguration(
            giniFont: GiniHealthConfiguration.shared.font(for: .button),
            answersFont: GiniHealthConfiguration.shared.font(for: .body2),
            answerCellTextColor: GiniColor.standard1.uiColor(),
            answerCellLinkColor: GiniColor.accent1.uiColor(),
            questionsTitleFont: GiniHealthConfiguration.shared.font(for: .subtitle1),
            questionsTitleColor: GiniColor.standard1.uiColor(),
            questionHeaderFont: GiniHealthConfiguration.shared.font(for: .body1),
            questionHeaderTitleColor: GiniColor.standard1.uiColor(),
            questionHeaderMinusIcon: GiniHealthImage.minus.preferredUIImage(),
            questionHeaderPlusIcon: GiniHealthImage.plus.preferredUIImage(),
            bankCellBorderColor: GiniColor.standard5.uiColor(),
            payBillsTitleFont: GiniHealthConfiguration.shared.font(for: .subtitle1),
            payBillsTitleColor: GiniColor.standard1.uiColor(),
            payBillsDescriptionFont: GiniHealthConfiguration.shared.font(for: .body2),
            linksFont: GiniHealthConfiguration.shared.font(for: .linkBold),
            linksColor: GiniColor.accent1.uiColor(),
            separatorColor: GiniColor.standard5.uiColor(),
            backgroundColor: GiniColor.standard7.uiColor(),
            closeIcon: GiniHealthImage.close.preferredUIImage(),
            closeIconTintColor: GiniColor.standard2.uiColor(),
            questionHeaderIconTintColor: GiniColor.accent1.uiColor()
        )
    }

    public var bankSelectionConfiguration: BankSelectionConfiguration {
        BankSelectionConfiguration(
            descriptionAccentColor: GiniColor.standard3.uiColor(),
            descriptionFont: GiniHealthConfiguration.shared.font(for: .captions1),
            selectBankAccentColor: GiniColor.standard2.uiColor(),
            selectBankFont: GiniHealthConfiguration.shared.font(for: .subtitle1),
            closeTitleIcon: GiniHealthImage.close.preferredUIImage(),
            closeIconAccentColor: GiniColor.standard2.uiColor(),
            bankCellBackgroundColor: GiniColor.standard7.uiColor(),
            bankCellIconBorderColor: GiniColor.standard5.uiColor(),
            bankCellNameFont: GiniHealthConfiguration.shared.font(for: .body1),
            bankCellNameAccentColor: GiniColor.standard1.uiColor(),
            bankCellSelectedBorderColor: GiniColor.accent1.uiColor(),
            bankCellNotSelectedBorderColor: GiniColor.standard5.uiColor(),
            bankCellSelectionIndicatorImage: GiniHealthImage.selectionIndicator.preferredUIImage()
        )
    }

    public var paymentComponentsConfiguration: PaymentComponentsConfiguration {
        PaymentComponentsConfiguration(
            selectYourBankLabelFont: GiniHealthConfiguration.shared.font(for: .subtitle2),
            selectYourBankAccentColor: GiniColor.standard1.uiColor(),
            chevronDownIcon: GiniHealthImage.chevronDown.preferredUIImage(),
            chevronDownIconColor: GiniColor(lightModeColorName: .light7, darkModeColorName: .light1).uiColor(),
            notInstalledBankTextColor: GiniColor.standard4.uiColor()
        )
    }

    public var paymentReviewConfiguration: PaymentReviewConfiguration {
        PaymentReviewConfiguration(
            loadingIndicatorStyle: UIActivityIndicatorView.Style.large,
            loadingIndicatorColor: GiniColor.accent1.uiColor(),
            infoBarLabelTextColor: GiniHealthColorPalette.dark7.preferredColor(),
            infoBarBackgroundColor: GiniColor.success1.uiColor(),
            mainViewBackgroundColor: GiniColor.standard7.uiColor(),
            infoContainerViewBackgroundColor: GiniColor.standard7.uiColor(),
            paymentReviewClose: GiniHealthImage.paymentReviewClose.preferredUIImage(),
            backgroundColor: GiniColor(lightModeColorName: .light7, darkModeColorName: .light7).uiColor(),
            rectangleColor: GiniColor.standard5.uiColor(),
            infoBarLabelFont: GiniHealthConfiguration.shared.font(for: .captions1),
            statusBarStyle: GiniHealthConfiguration.shared.paymentReviewStatusBarStyle,
            pageIndicatorTintColor: GiniColor.standard4.uiColor(),
            currentPageIndicatorTintColor: GiniColor(lightModeColorName: .dark2, darkModeColorName: .light5).uiColor(),
            isInfoBarHidden: GiniHealthConfiguration.shared.useInvoiceWithoutDocument ? true : false,
            popupAnimationDuration: GiniHealthConfiguration.shared.popupDurationPaymentReview
        )
    }

    public var poweredByGiniConfiguration: PoweredByGiniConfiguration {
        PoweredByGiniConfiguration(
            poweredByGiniLabelFont: GiniHealthConfiguration.shared.font(for: .captions2),
            poweredByGiniLabelAccentColor: GiniColor.standard4.uiColor(),
            giniIcon: GiniHealthImage.logo.preferredUIImage()
        )
    }

    public var moreInformationConfiguration: MoreInformationConfiguration {
        MoreInformationConfiguration(
            moreInformationAccentColor: GiniColor.standard8.uiColor(),
            moreInformationTextColor: GiniColor.standard4.uiColor(),
            moreInformationLinkFont: GiniHealthConfiguration.shared.font(for: .captions2),
            moreInformationIcon: GiniHealthImage.info.preferredUIImage().withRenderingMode(.alwaysTemplate)
        )
    }

    public var primaryButtonConfiguration: GiniInternalPaymentSDK.ButtonConfiguration {
        GiniHealthConfiguration.shared.primaryButtonConfiguration
    }

    public var secondaryButtonConfiguration: GiniInternalPaymentSDK.ButtonConfiguration {
        GiniHealthConfiguration.shared.secondaryButtonConfiguration
    }
}
