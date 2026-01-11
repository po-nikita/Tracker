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
        view.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("editCategory.title", comment: "")
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        textField.text = categoryTitle
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.setLeftPadding(16)
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        doneButton.setTitle(NSLocalizedString("editCategory.done", comment: ""), for: .normal)
        doneButton.isEnabled = false
        doneButton.backgroundColor = .systemGray
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        doneButton.tintColor = .white
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
    
    @objc private func textChanged() {
        let text = textField.text ?? ""
        doneButton.isEnabled = !text.isEmpty && text != categoryTitle
        doneButton.backgroundColor = doneButton.isEnabled ? .black : .systemGray
    }
    
    @objc private func doneTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        completion(text)
        dismiss(animated: true)
    }
}
