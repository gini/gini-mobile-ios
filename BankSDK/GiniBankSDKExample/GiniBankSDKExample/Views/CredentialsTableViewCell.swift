import UIKit

protocol CredentialsTableViewCellDelegate: AnyObject {
    func didTapSaveButton(clientId: String, clientSecret: String)
}

class CredentialsTableViewCell: UITableViewCell, NibLoadableView {

    @IBOutlet private weak var clientIDTextField: UITextField!
    @IBOutlet private weak var clientSecretTextField: UITextField!
    @IBOutlet private weak var saveButton: UIButton!

    weak var delegate: CredentialsTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    func set(data: CredentialsModel) {
        clientIDTextField.text = data.clientId
        clientSecretTextField.text = data.secretId
    }

    @objc private func saveButtonTapped() {
        delegate?.didTapSaveButton(clientId: clientIDTextField.text ?? "", clientSecret: clientSecretTextField.text ?? "")
    }
}
