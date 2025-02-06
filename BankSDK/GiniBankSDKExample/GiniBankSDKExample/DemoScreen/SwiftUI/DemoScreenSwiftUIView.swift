import SwiftUI
import GiniCaptureSDK
import GiniBankSDK

struct DemoView: View {
    @State private var ibanText: String = ""
    var clientId: String?
    var onPhotoPayment: () -> Void
    var onSettingsTap: () -> Void
    var onEntryPointSelected: (GiniConfiguration.GiniEntryPoint) -> Void

    var body: some View {
        VStack {
            Spacer(minLength: Constants.giniLogoTopConstant)

            // Gini Logo
            Image("gini_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 114, height: 72)

            // Welcome Title
            Text(DemoScreenStrings.welcomeTitle.localized)
                .font(.system(size: 22, weight: .bold))
                .padding(.top, Constants.welcomeTitleTopConstant)

            // Description Text
            Text(DemoScreenStrings.screenDescription.localized)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 50)
                .padding(.top, 12)

            VStack(spacing: 24) {
                IBANTextFieldSwiftUIView(ibanText: $ibanText, onCameraTap: {
                    onEntryPointSelected(.field)
                })
                .padding(.horizontal, Constants.stackViewMarginConstant)

                Text(DemoScreenStrings.alternativeText.localized)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)

                GiniSwiftUIButton(title: DemoScreenStrings.photoPaymentButtonTitle.localized,
                                  action: {
                    onEntryPointSelected(.button)
                })
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color(Constants.itemBackgroundColor))
                .cornerRadius(7)
                .padding(.horizontal, Constants.stackViewMarginConstant)
            }
            .padding(.top, Constants.stackViewTopConstant)


            Spacer()

            // Meta Information
            Text("Gini Bank SDK: (\(GiniBankSDKVersion)) / Gini Capture SDK: (\(GiniCaptureSDKVersion)) / Client id: \(clientId ?? "")")
                .font(.system(size: 11))
                .multilineTextAlignment(.center)
                .lineLimit(nil) // Ensures unlimited lines (equivalent to numberOfLines = 0)
                .fixedSize(horizontal: false, vertical: true) // Allows text to expand vertically
                .padding(.horizontal, 50)
                .padding(.bottom, 14)
                .onTapGesture {
                    onSettingsTap()
                }
        }
        .background(Color(UIColor.systemBackground))
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Constants
private struct Constants {
    static let welcomeTitleTopConstant: CGFloat = Device.small ? 24 : UIDevice.current.isIpad ? 85 : 48
    static let giniLogoTopConstant: CGFloat = Device.small ? 48 : UIDevice.current.isIpad ? 150 : 112
    static let stackViewTopConstant: CGFloat = 72
    static let stackViewMarginConstant: CGFloat = UIDevice.current.isIpad ? 64 : 16
    static let itemBackgroundColor = GiniColor(
        light: giniCaptureColor("Light04"),
        dark: giniCaptureColor("Dark04")
    ).uiColor()
}

// MARK: - Hide Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    DemoView(clientId: "example-client-id",
             onPhotoPayment: {},
             onSettingsTap: {},
             onEntryPointSelected: { _ in })
}
