//
//  CameraButtonsViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/18/19.
//

import UIKit

protocol CameraButtonsViewControllerDelegate: AnyObject {
    func cameraButtons(_ viewController: CameraButtonsViewController,
                       didTapOn button: CameraButtonsViewController.Button)
}

final class CameraButtonsViewController: UIViewController {
    
    weak var delegate: CameraButtonsViewControllerDelegate?
    
    var isFlashSupported: Bool = false {
        didSet {
            flashToggleButtonContainerView.isHidden = !isFlashSupported
        }
    }
    
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let currentDevice: UIDevice
    fileprivate let captureButtonMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    fileprivate var cameraCaptureButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraCaptureButton")
    }
    
    enum Button: Equatable {
        case fileImport, capture, imagesStack, flashToggle(Bool)
    }
    
    lazy var captureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.cameraCaptureButtonImage, for: .normal)
        button.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        button.accessibilityLabel = .localized(resource: CameraStrings.captureButton)
        return button
    }()
    
    lazy var flashToggleButtonContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var flashToggleButton: UIButton = {
        let flashToggle = UIButton(type: .custom)
        flashToggle.translatesAutoresizingMaskIntoConstraints = false
        flashToggle.setImage(UIImageNamedPreferred(named: "flashOn"), for: .selected)
        flashToggle.setImage(UIImageNamedPreferred(named: "flashOff"), for: .normal)
        flashToggle.isSelected = giniConfiguration.flashOnByDefault
        flashToggle.imageView?.contentMode = .scaleAspectFit
        flashToggle.addTarget(self, action: #selector(tapOnFlashToggle), for: .touchUpInside)
        
        if currentDevice.isIpad {
            flashToggle.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        } else {
            flashToggle.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
        
        return flashToggle
    }()
    
    lazy var capturedImagesStackView: CapturedImagesStackView = {
        let view = CapturedImagesStackView(giniConfiguration: giniConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.didTapImageStackButton = { [weak self] in
            guard let self = self else { return }
            self.delegate?.cameraButtons(self, didTapOn: .imagesStack)
        }
        return view
    }()
    
    lazy var fileImportButtonView: FileImportButtonView = {
        let view = FileImportButtonView(giniConfiguration: giniConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.didTapButton = { [weak self] in
            guard let self = self else { return }
            self.delegate?.cameraButtons(self, didTapOn: .fileImport)
        }
        return view
    }()
    
    lazy var leftStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .horizontal
        stackView.alignment = currentDevice.isIpad ? .top : .center
        
        return stackView
    }()
    
    lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .horizontal
        stackView.alignment = currentDevice.isIpad ? .bottom : .center
        
        return stackView
    }()
    
    var verticalAlignedStackView: UIStackView {
        let verticalAlignedStackView = UIStackView()
        verticalAlignedStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalAlignedStackView.axis = .vertical
        verticalAlignedStackView.spacing = 32
        verticalAlignedStackView.alignment = .center
        return verticalAlignedStackView
    }
    
    init(giniConfiguration: GiniConfiguration = .shared, currentDevice: UIDevice = .current) {
        self.giniConfiguration = giniConfiguration
        self.currentDevice = currentDevice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.cameraButtonsViewBackgroundColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(captureButton)
        view.addSubview(leftStackView)
        view.addSubview(rightStackView)
        flashToggleButtonContainerView.addSubview(flashToggleButton)
        
        if currentDevice.isIpad {
            let topVerticalAlignedStackView = verticalAlignedStackView
            
            if giniConfiguration.multipageEnabled {
                topVerticalAlignedStackView.addArrangedSubview(capturedImagesStackView)
            }
            
            if giniConfiguration.flashToggleEnabled {
                topVerticalAlignedStackView.addArrangedSubview(flashToggleButtonContainerView)
            }
            
            if !topVerticalAlignedStackView.arrangedSubviews.isEmpty {
                rightStackView.addArrangedSubview(topVerticalAlignedStackView)
            }
        } else {
            if giniConfiguration.multipageEnabled {
                rightStackView.addArrangedSubview(capturedImagesStackView)
            }
            
            if giniConfiguration.flashToggleEnabled {
                if giniConfiguration.multipageEnabled {
                    leftStackView.addArrangedSubview(flashToggleButtonContainerView)
                } else {
                    rightStackView.addArrangedSubview(flashToggleButtonContainerView)
                }
            }
        }
        
        flashToggleButtonContainerView.isHidden = !isFlashSupported
        
        addConstraints()
    }
    
    func addFileImportButton() {
        if currentDevice.isIpad {
            let bottomVerticalAlignedStackView = verticalAlignedStackView
            bottomVerticalAlignedStackView.addArrangedSubview(fileImportButtonView)
            
            leftStackView.addArrangedSubview(bottomVerticalAlignedStackView)
            leftStackView.layoutIfNeeded()
        } else {
            leftStackView.insertArrangedSubview(fileImportButtonView, at: 0)
        }
        
        addImportButtonConstraints()
    }
    
    func toggleCaptureButtonActivation(state:Bool) {
        captureButton.isUserInteractionEnabled = state
        captureButton.isEnabled = state
    }

}

// MARK: - Button actions

fileprivate extension CameraButtonsViewController {
    @objc func captureImage(_ sender: AnyObject) {
        toggleCaptureButtonActivation(state: false)
        delegate?.cameraButtons(self, didTapOn: .capture)
    }
    
    @objc func tapOnFlashToggle(_ button: UIButton) {
        UIImpactFeedbackGenerator().impactOccurred()
        button.isSelected.toggle()
        delegate?.cameraButtons(self, didTapOn: .flashToggle(button.isSelected))
    }
}

// MARK: - Constraints

fileprivate extension CameraButtonsViewController {
    
    func addConstraints() {
        addCaptureButtonConstraints()
        addStackViewConstraints()
        
        if giniConfiguration.flashToggleEnabled {
            addFlashButtonConstraints()
        }
    }
    
    func addCaptureButtonConstraints() {
        if currentDevice.isIpad {
            captureButton.heightAnchor.constraint(equalTo: captureButton.widthAnchor).isActive = true
            captureButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            captureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -captureButtonMargins.right).isActive = true
            captureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: captureButtonMargins.left).isActive = true
        } else {
            captureButton.heightAnchor.constraint(equalTo: captureButton.widthAnchor).isActive = true
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            captureButton.topAnchor.constraint(equalTo: view.topAnchor,
                                               constant: captureButtonMargins.left).isActive = true
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                  constant: -captureButtonMargins.bottom).isActive = true
        }
    }
    
    func addStackViewConstraints() {
        if currentDevice.isIpad {
            rightStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            rightStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            rightStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            rightStackView.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -30).isActive = true
            
            leftStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            leftStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            leftStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            leftStackView.topAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: 30).isActive = true
        } else {
            rightStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            rightStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            rightStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            rightStackView.leadingAnchor.constraint(equalTo: captureButton.trailingAnchor).isActive = true
            
            leftStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            leftStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            leftStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            leftStackView.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor).isActive = true
        }
    }
    
    func addImportButtonConstraints() {
        if currentDevice.isIpad {
            fileImportButtonView.heightAnchor
                .constraint(equalToConstant: 70)
                .isActive = true
            fileImportButtonView.widthAnchor
                .constraint(equalTo: leftStackView.widthAnchor,
                            constant: -(leftStackView.layoutMargins.left + leftStackView.layoutMargins.right))
                .isActive = true
        } else {
            let heightConstraint = fileImportButtonView
                .heightAnchor.constraint(equalTo: leftStackView.heightAnchor)
            heightConstraint.priority = UILayoutPriority(999)
            heightConstraint.isActive = true
        }
    }
    
    func addFlashButtonConstraints() {
        flashToggleButton.centerXAnchor.constraint(equalTo: flashToggleButtonContainerView.centerXAnchor)
            .isActive = true
        flashToggleButton.centerYAnchor.constraint(equalTo: flashToggleButtonContainerView.centerYAnchor)
            .isActive = true

        if currentDevice.isIpad {
            let heightConstraint =
                flashToggleButtonContainerView.widthAnchor.constraint(equalTo: rightStackView.widthAnchor,
                                                                      multiplier: 1/3)
            heightConstraint.priority = UILayoutPriority(999)
            heightConstraint.isActive = true
            let widthConstraint = flashToggleButtonContainerView
                    .heightAnchor.constraint(equalTo: flashToggleButtonContainerView.widthAnchor,
                                                                       multiplier: 17/11)
            widthConstraint.priority = UILayoutPriority(999)
            widthConstraint.isActive = true

        } else {
            let heightConstraint = flashToggleButtonContainerView
                .heightAnchor.constraint(equalTo: leftStackView.heightAnchor,
                                         multiplier: 1)
            heightConstraint.priority = UILayoutPriority(999)
            heightConstraint.isActive = true
            let widthConstraint = flashToggleButtonContainerView
                .widthAnchor.constraint(equalTo: flashToggleButtonContainerView.heightAnchor,
                                        multiplier: 11/17)
            widthConstraint.priority = UILayoutPriority(999)
            widthConstraint.isActive = true
        }
        
        let heightConstraint = flashToggleButton
            .heightAnchor.constraint(equalTo: flashToggleButtonContainerView.heightAnchor)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
        
    }
}
