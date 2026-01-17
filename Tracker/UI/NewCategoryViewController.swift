import UIKit

final class NewCategoryViewController: UIViewController {
    
    private let completion: (String) -> Void
    
    private let textField = UITextField()
    private let addButton = UIButton(type: .system)
    
    init(completion: @escaping (String) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        setupUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("newCategory.title", comment: "")
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("newCategory.placeholder", comment: ""),
            attributes: [.foregroundColor: UIColor.secondaryLabel])
        
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.setLeftPadding(16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        addButton.setTitle(NSLocalizedString("newCategory.done", comment: ""), for: .normal)
        addButton.isEnabled = false
        applyAddButtonStyle(isEnabled: false)
        addButton.layer.cornerRadius = 16
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func applyAddButtonStyle(isEnabled: Bool) {
        addButton.isEnabled = isEnabled

        if isEnabled {
            addButton.backgroundColor = Colors.buttonEnabled
            addButton.setTitleColor(Colors.buttonEnabledText, for: .normal)
        } else {
            addButton.backgroundColor = Colors.buttonDisabled
            addButton.setTitleColor(Colors.buttonDisabledText, for: .normal)
        }
    }

    @objc private func textChanged() {
        let isEnabled = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        applyAddButtonStyle(isEnabled: isEnabled)
    }
    
    @objc private func addTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        completion(text)
        dismiss(animated: true)
    }
}

