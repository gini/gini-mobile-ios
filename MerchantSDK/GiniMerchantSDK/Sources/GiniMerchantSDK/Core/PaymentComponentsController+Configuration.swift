//
//  File.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

extension PaymentComponentsController {
    func generateBanksBottomConfiguration() -> BanksBottomConfiguration {
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

    func generatePaymentComponentsConfiguration() -> PaymentComponentsConfiguration {
        PaymentComponentsConfiguration(
            selectYourBankLabelFont: GiniMerchantConfiguration.shared.font(for: .subtitle2),
            selectYourBankAccentColor: GiniColor.standard1.uiColor(),
            chevronDownIcon: GiniMerchantImage.chevronDown.preferredUIImage(),
            chevronDownIconColor: GiniColor(lightModeColorName: .light7, darkModeColorName: .light1).uiColor(),
            notInstalledBankTextColor: GiniColor.standard4.uiColor()
        )
    }

    func generatePoweredByGiniConfiguration() -> PoweredByGiniConfiguration {
        PoweredByGiniConfiguration(
            poweredByGiniLabelFont: GiniMerchantConfiguration.shared.font(for: .captions2),
            poweredByGiniLabelAccentColor: GiniColor.standard4.uiColor(),
            giniIcon: GiniMerchantImage.logo.preferredUIImage()
        )
    }

    func generateMoreInformationConfiguration() -> MoreInformationConfiguration {
        MoreInformationConfiguration(
            moreInformationAccentColor: GiniColor.standard2.uiColor(),
            moreInformationTextColor: GiniColor.standard4.uiColor(),
            moreInformationLinkFont: GiniMerchantConfiguration.shared.font(for: .captions2),
            moreInformationIcon: GiniMerchantImage.info.preferredUIImage()
        )

    }

    func generateShareInvoiceConfiguration() -> ShareInvoiceConfiguration {
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

    func generateInstallAppConfiguration() -> InstallAppConfiguration {
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

    func generatePaymentInfoConfiguration() -> PaymentInfoConfiguration {
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
}
