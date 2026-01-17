import UIKit

final class EditCategoryViewController: UIViewController {
    
    private let completion: (String) -> Void
    private let categoryTitle: String
    
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    init(title: String, completion: @escaping (String) -> Void) {
        self.categoryTitle = title
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        setupUI()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("editCategory.title", comment: "")
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        textField.text = categoryTitle
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.setLeftPadding(16)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        doneButton.setTitle(NSLocalizedString("editCategory.done", comment: ""), for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        applyDoneButtonStyle(isEnabled: true)

        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneTapped() {
        let text = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text.isEmpty else { return }
        completion(text)
        dismiss(animated: true)
    }
    
    private func applyDoneButtonStyle(isEnabled: Bool) {
        doneButton.isEnabled = isEnabled

        if isEnabled {
            doneButton.backgroundColor = Colors.buttonEnabled
            doneButton.setTitleColor(Colors.buttonEnabledText, for: .normal)
        } else {
            doneButton.backgroundColor = Colors.buttonDisabled
            doneButton.setTitleColor(Colors.buttonDisabledText, for: .normal)
        }
    }

}
