//
//  DebugMenuViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniHealthSDK
import GiniInternalPaymentSDK
import GiniUtilites

enum SwitchType {
    case showReviewScreen
    case showBrandedView
    case useBottomPaymentComponent
    case showPaymentCloseButton
    case useAlternativeNavigation
}

protocol DebugMenuDelegate: AnyObject {
    func didChangeSwitchValue(type: SwitchType, isOn: Bool)
    func didPickNewLocalization(localization: GiniLocalization)
    func didChangeSliderValue(value: Float)
    func didCustomizeShareWithFilename(filename: String)
    func didTapOnBulkDelete()
}

class DebugMenuViewController: UIViewController {
    private let spacing = 20.0
    private let rowHeight = 50.0
    
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var mainStackView: UIStackView!

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Gini Health"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .largeTitle)
        return label
    }()

    private lazy var localizationTitleLabel: UILabel = rowTitle("Localization")

    private lazy var localizationPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var localizationRow: UIStackView = stackView(axis: .horizontal, subviews: [localizationTitleLabel, localizationPicker])

    private lazy var reviewScreenOptionLabel: UILabel = rowTitle("Show Review Screen")
    private var reviewScreenSwitch: UISwitch!
    private lazy var reviewScreenRow: UIStackView = stackView(axis: .horizontal, subviews: [reviewScreenOptionLabel, reviewScreenSwitch])

    private lazy var bottomPaymentComponentOptionLabel: UILabel = rowTitle("Use bottom payment component")
    private var bottomPaymentComponentSwitch: UISwitch!
    private lazy var bottomPaymentComponentEditableRow: UIStackView = stackView(axis: .horizontal, subviews: [bottomPaymentComponentOptionLabel, bottomPaymentComponentSwitch])

    private lazy var closeButtonOptionLabel: UILabel = rowTitle("Show Payment Review Close Button")
    private var closeButtonSwitch: UISwitch!
    private lazy var closeButtonRow: UIStackView = stackView(axis: .horizontal, subviews: [closeButtonOptionLabel, closeButtonSwitch])
    
    /// This option allows to test the navigation flow when the consumer app creates a new `UINavigationController` instance to start the payment flow. Instead of using the existing one.
    /// by using this flow the consumer app will be listening to the new `delegate` method in the `GiniHealthSDK` to handle the navigation.
    private lazy var useAlternativeNavigationLabel = rowTitle("Use alternative navigation")
    private var useAlternativeNavigationSwitch: UISwitch!
    private lazy var useAlternativeNavigationRow = stackView(axis: .horizontal, subviews: [useAlternativeNavigationLabel, useAlternativeNavigationSwitch])
    
    private lazy var popupDurationTitleLabel: UILabel = rowTitle("Popup Duration Time")
    
    private lazy var popupDurationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        if #available(iOS 15.0, *) {
            slider.toolTip = "\(slider.value)"
        }
        
        return slider
    }()
    
    private lazy var popupDurationRow: UIStackView = stackView(axis: .horizontal, subviews: [popupDurationTitleLabel,
                                                                                             popupDurationSlider])

    private lazy var shareWithFilenameOptionLabel: UILabel = rowTitle("QR PDF Filename")
    private lazy var shareWithFilenameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter filename"
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(shareWithFilenameTextFieldChanged(_:)), for: .editingChanged)
        return textField
    }()
    private lazy var shareWithFilenameRow: UIStackView = stackView(axis: .horizontal, subviews: [shareWithFilenameOptionLabel, shareWithFilenameTextField])
    private lazy var bulkDeleteButton: UIButton = actionButton(for: .deleteDocuments)

    weak var delegate: DebugMenuDelegate?

    init(showReviewScreen: Bool,
         useBottomPaymentComponent: Bool,
         paymentComponentConfiguration: PaymentComponentConfiguration,
         showPaymentCloseButton: Bool,
         popupDuration: TimeInterval,
         shouldUseAlternativeNavigation: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.reviewScreenSwitch = self.switchView(isOn: showReviewScreen)
        self.bottomPaymentComponentSwitch = self.switchView(isOn: useBottomPaymentComponent)
        self.closeButtonSwitch = self.switchView(isOn: showPaymentCloseButton)
        self.useAlternativeNavigationSwitch = self.switchView(isOn: shouldUseAlternativeNavigation)
        self.popupDurationSlider.value = Float(popupDuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let localization = GiniHealthConfiguration.shared.customLocalization, let index = GiniLocalization.allCases.firstIndex(of: localization) {
            localizationPicker.selectRow(index, inComponent: 0, animated: true)
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "background")
        setupScrollView()
        mainStackView = createMainStackView()
        contentView.addSubview(mainStackView)
        setupConstraints()
        
        addKeyboardObservers()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func createMainStackView() -> UIStackView {
        let spacer = UIView()
        let views = [
            titleLabel,
            useAlternativeNavigationRow,
            localizationRow,
            reviewScreenRow,
            bottomPaymentComponentEditableRow,
            closeButtonRow,
            popupDurationRow,
            shareWithFilenameRow,
            bulkDeleteButton,
            spacer
        ]

        let stack = stackView(axis: .vertical, subviews: views)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: spacing),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),

            useAlternativeNavigationRow.heightAnchor.constraint(equalToConstant: rowHeight),
            localizationRow.heightAnchor.constraint(equalToConstant: rowHeight),
            reviewScreenRow.heightAnchor.constraint(equalToConstant: rowHeight),
            bottomPaymentComponentEditableRow.heightAnchor.constraint(equalToConstant: rowHeight),
            closeButtonRow.heightAnchor.constraint(equalToConstant: rowHeight),
            popupDurationRow.heightAnchor.constraint(equalToConstant: rowHeight),
            shareWithFilenameRow.heightAnchor.constraint(equalToConstant: rowHeight),
            bulkDeleteButton.heightAnchor.constraint(equalToConstant: rowHeight)
        ])
    }

    // MARK: - Keyboard Handling
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc private func shareWithFilenameTextFieldChanged(_ sender: UITextField) {
        if let filename = sender.text {
            delegate?.didCustomizeShareWithFilename(filename: filename)
        }
    }
}

private extension DebugMenuViewController {
    enum DebugMenuActionType {
        case deleteDocuments
        // Add more cases if needed
        var title: String {
            switch self {
            case .deleteDocuments:
                return "Bulk Delete"
            }
        }

        var selector: Selector {
            switch self {
            case .deleteDocuments:
                return #selector(deleteDocumentsTapped)
            }
        }
    }

    func rowTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        return label
    }

    func stackView(axis: NSLayoutConstraint.Axis, subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.spacing = spacing
        return stackView
    }

    func switchView(isOn: Bool) -> UISwitch {
        let mySwitch = UISwitch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        mySwitch.isOn = isOn
        return mySwitch
    }

    func actionButton(for type: DebugMenuActionType) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(type.title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: type.selector, for: .touchUpInside)
        return button
    }

    @objc private func deleteDocumentsTapped() {
        delegate?.didTapOnBulkDelete()
    }
}

extension DebugMenuViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == localizationPicker {
            return GiniLocalization.allCases.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == localizationPicker {
            return GiniLocalization.allCases[row].rawValue
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == localizationPicker {
            delegate?.didPickNewLocalization(localization: GiniLocalization.allCases[row])
        }
    }
}

// MARK: Switch functions
private extension DebugMenuViewController {
    @objc private func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case reviewScreenSwitch:
            delegate?.didChangeSwitchValue(type: .showReviewScreen, isOn: sender.isOn)
        case bottomPaymentComponentSwitch:
            delegate?.didChangeSwitchValue(type: .useBottomPaymentComponent, isOn: sender.isOn)
        case closeButtonSwitch:
            delegate?.didChangeSwitchValue(type: .showPaymentCloseButton, isOn: sender.isOn)
        case useAlternativeNavigationSwitch:
            delegate?.didChangeSwitchValue(type: .useAlternativeNavigation, isOn: sender.isOn)
        default:
            break
        }
    }
}

// MARK: Slider functions
private extension DebugMenuViewController {
    @objc private func sliderValueChanged(_ sender: UISlider) {
        sender.value = roundf(sender.value)
        delegate?.didChangeSliderValue(value: sender.value)
    }
}
