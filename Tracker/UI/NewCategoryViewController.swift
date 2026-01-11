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
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("newCategory.title", comment: "")
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        textField.placeholder = NSLocalizedString("newCategory.placeholder", comment: "")
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.setLeftPadding(16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        addButton.setTitle(NSLocalizedString("newCategory.done", comment: ""), for: .normal)
        addButton.isEnabled = false
        addButton.backgroundColor = .systemGray
        addButton.layer.cornerRadius = 16
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        addButton.tintColor = .white
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
    
    @objc private func textChanged() {
        addButton.isEnabled = !(textField.text?.isEmpty ?? true)
        addButton.backgroundColor = .black
    }
    
    @objc private func addTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        completion(text)
        dismiss(animated: true)
    }
}

