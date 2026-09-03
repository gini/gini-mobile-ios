//
//  ContentView.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.

import SwiftUI
import GiniCaptureSDK
import GiniBankSDK

protocol ContentViewDelegate: AnyObject {
    func didSelectEntryPoint(_ entryPoint: GiniCaptureSDK.GiniConfiguration.GiniEntryPoint)
    func didSelectSettings()
    func didTapTransactionList()
}

struct ContentView: View {
    @State private var ibanText: String = ""
    @State private var focusedFormField: Bool = false

    private var viewModel: ContentViewModel
    weak var delegate: ContentViewDelegate?
    var clientId: String?

    init(delegate: ContentViewDelegate? = nil, clientId: String? = nil) {
        viewModel = ContentViewModel()
        self.delegate = delegate
        self.clientId = clientId
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(spacing: Constants.mainContentSpacing) {
                    topSection
                    ibanSection
                    photoPaymentSection
                    transactionSection
                    bottomSection
                }
            }
        }
        .background(Color.white)
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - View Components
private extension ContentView {

    var navigationBar: some View {
        HStack {
            Spacer()
            Button(action: {
                launchSettings()
            }) {
                Image(systemName: "gearshape")
                    .foregroundColor(.black)
                    .font(.system(size: Constants.settingsIconSize))
            }
        }
        .padding(.horizontal, Constants.navigationHorizontalPadding)
        .padding(.top, Constants.navigationTopPadding)
    }

    var topSection: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: Constants.topSpacerHeight)

            giniLogo
            welcomeTitle
            descriptionText
        }
    }

    var giniLogo: some View {
        Image("gini_logo")
            .resizable()
            .scaledToFit()
            .frame(width: Constants.logoWidth, height: Constants.logoHeight)
    }

    var welcomeTitle: some View {
        Text(DemoScreenStrings.welcomeTitle.localized)
            .font(.system(size: Constants.welcomeTitleFontSize, weight: .bold))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
    }

    var descriptionText: some View {
        Text(DemoScreenStrings.screenDescription.localized)
            .font(.system(size: Constants.descriptionFontSize))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, Constants.horizontalPadding)
    }

    var ibanSection: some View {
        VStack(spacing: Constants.alternativeTextTopPadding) {
            Spacer()
                .frame(height: Constants.beforeIBANSpacing)

            IBANTextFieldSwiftUIView(
                ibanText: $ibanText,
                onCameraTap: {
                    startSDK(entryPoint: .field)
                }
            )
            .padding(.horizontal, Constants.horizontalPadding)

            alternativeText
        }
    }

    var alternativeText: some View {
        Text(DemoScreenStrings.alternativeText.localized)
            .font(.system(size: Constants.alternativeTextFontSize))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
    }

    var photoPaymentSection: some View {
        VStack(spacing: 0) {
            GiniSwiftUIButton(
                title: DemoScreenStrings.photoPaymentButtonTitle.localized,
                textColor: SwiftUIColor.gini(light: .GiniBank.light1, dark: .GiniBank.light1),
                backgroundColor: SwiftUIColor.gini(light: .GiniBank.accent1, dark: .GiniBank.accent1),
                action: {
                    photoPaymentButtonTapped()
                }
            )
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.photoButtonTopPadding)

            Spacer()
                .frame(height: Constants.beforeTransactionButtonSpacing)
        }
    }

    var transactionSection: some View {
        Button(action: {
            transactionListButtonTapped()
        }) {
            Text(DemoScreenStrings.transactionListButtonTitle.localized)
                .font(.system(size: Constants.transactionButtonFontSize))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: Constants.buttonHeight)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Constants.transactionButtonBorderColor, lineWidth: Constants.transactionButtonBorderWidth)
                )
        }
        .padding(.horizontal, Constants.horizontalPadding)
    }

    var bottomSection: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: Constants.bottomSpacerHeight)

            metaInformation
        }
    }

    private var metaInfoText: String {
        let bankSDK = "Gini Bank SDK: (\(GiniBankSDKVersion))"
        let captureSDK = "Gini Capture SDK: (\(GiniCaptureSDKVersion))"
        let client = "Client id: \(clientId ?? "gini-mobile-test")"

        return "\(bankSDK) / \(captureSDK) /\n\(client)"
    }

    var metaInformation: some View {
        Text(metaInfoText)
            .font(.system(size: Constants.metaInformationFontSize))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(.horizontal, Constants.horizontalPadding)
            .onTapGesture {
                launchSettings()
            }
    }
}

// MARK: - Actions
private extension ContentView {

    func startSDK(entryPoint: GiniConfiguration.GiniEntryPoint) {
        hideKeyboard()
        viewModel.openModule()
        delegate?.didSelectEntryPoint(entryPoint)
    }

    func photoPaymentButtonTapped() {
        startSDK(entryPoint: .button)
    }

    func transactionListButtonTapped() {
        delegate?.didTapTransactionList()
    }

    func launchSettings() {
        delegate?.didSelectSettings()
    }
}

// MARK: - Constants
private struct Constants {
    // Navigation
    static let navigationHorizontalPadding: CGFloat = 16
    static let navigationTopPadding: CGFloat = 8
    static let settingsIconSize: CGFloat = 20

    // Layout spacing
    static let mainContentSpacing: CGFloat = 0
    static let topSpacerHeight: CGFloat = 40
    static let beforeIBANSpacing: CGFloat = 60
    static let alternativeTextTopPadding: CGFloat = 24
    static let photoButtonTopPadding: CGFloat = 8
    static let beforeTransactionButtonSpacing: CGFloat = 80
    static let bottomSpacerHeight: CGFloat = 40

    // Logo
    static let logoWidth: CGFloat = 120
    static let logoHeight: CGFloat = 76

    // Typography
    static let welcomeTitleFontSize: CGFloat = 24
    static let descriptionFontSize: CGFloat = 16
    static let alternativeTextFontSize: CGFloat = 16
    static let transactionButtonFontSize: CGFloat = 17
    static let metaInformationFontSize: CGFloat = 11

    // Buttons and UI
    static let buttonHeight: CGFloat = 50
    static let cornerRadius: CGFloat = 8
    static let transactionButtonBorderWidth: CGFloat = 1
    static let transactionButtonBorderColor = Color(UIColor.systemGray4)

    // Spacing
    static let horizontalPadding: CGFloat = 32
}

// MARK: - Hide Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    ContentView(delegate: nil, clientId: "gini-mobile-test")
}
