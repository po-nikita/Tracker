import UIKit

final class NewTrackerViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let errorLabel = UILabel()
    private let maxLength = 38
    
    private let optionsContainerView = UIView()
    private let categoryButton = UIButton()
    private let scheduleButton = UIButton()
    private let separatorView = UIView()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    private let scheduleDescriptionLabel = UILabel()
    
    var onCreate: ((Tracker) -> Void)?
    private var selectedWeekDays: [Weekday] = []
    private var optionsTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCancelButton()
        setupCreateButton()
        setupTitle()
        setupNameTextField()
        setupErrorLabel()
        setupOptionsContainer()
        setupScheduleDescriptionLabel()

        setupLayout()
    }
    
    // MARK: Настройка UI
    
    private func setupTitle() {
        titleLabel.text = "Новая привычка"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupNameTextField() {
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.backgroundColor = UIColor.systemGray6
        nameTextField.layer.cornerRadius = 10
        nameTextField.textColor = .black
        nameTextField.setLeftPadding(16)
        nameTextField.delegate = self
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)
    }
    
    private func setupErrorLabel() {
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.font = UIFont.systemFont(ofSize: 17)
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
    }
    
    private func setupOptionsContainer() {
        optionsContainerView.backgroundColor = .systemGray6
        optionsContainerView.layer.cornerRadius = 16
        optionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsContainerView)
        
        // Настройка кнопок
        categoryButton.setTitle("Категория", for: .normal)
        categoryButton.setTitleColor(.black, for: .normal)
        categoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        addChevronIcon(to: categoryButton)
        
        scheduleButton.setTitle("Расписание", for: .normal)
        scheduleButton.setTitleColor(.black, for: .normal)
        scheduleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        scheduleButton.contentHorizontalAlignment = .left
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        addChevronIcon(to: scheduleButton)
        
        separatorView.backgroundColor = .systemGray4
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        [categoryButton, separatorView, scheduleButton].forEach { optionsContainerView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            scheduleButton.bottomAnchor.constraint(equalTo: optionsContainerView.bottomAnchor)
        ])
    }
    
    private func addChevronIcon(to button: UIButton) {
        let chevronImage = UIImage(systemName: "chevron.right")
        let icon = UIImageView(image: chevronImage)
        icon.tintColor = .gray
        icon.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            icon.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
    }
    
    private func setupCreateButton() {
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = .systemGray
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        view.addSubview(createButton)
    }
    
    private func setupScheduleDescriptionLabel() {
        scheduleDescriptionLabel.font = .systemFont(ofSize: 13)
        scheduleDescriptionLabel.textColor = .systemGray
        scheduleDescriptionLabel.numberOfLines = 1
        scheduleDescriptionLabel.isHidden = true
        scheduleDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionsContainerView.addSubview(scheduleDescriptionLabel)
    }

    
    // MARK: Layout
    
    private func setupLayout() {
        optionsTopConstraint = optionsContainerView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            optionsTopConstraint,
            
            optionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            scheduleDescriptionLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor),
            scheduleDescriptionLabel.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor),
            scheduleDescriptionLabel.topAnchor.constraint(equalTo: scheduleButton.titleLabel!.bottomAnchor, constant: 4)
            ])
    }
    
// MARK: Кнопка расписания
    @objc private func scheduleButtonTapped() {
        let scheduleVc = ScheduleViewController()
        // подписываемся на результат
        scheduleVc.onDone = {[weak self] selectedDays in // когда контроллер вызовет onDone, выполнится этот код
            guard let self else {return}
            self.selectedWeekDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
            self.updateScheduleLabel()
            self.updateCreateButtonState()
        }
        scheduleVc.modalPresentationStyle = .pageSheet // шторка снизу
        if let sheet = scheduleVc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 16
            sheet.selectedDetentIdentifier = .large
        }
        present(scheduleVc, animated: true)
    }
    
    private func updateScheduleLabel() {
        guard !selectedWeekDays.isEmpty else { // если выбранных дней нету - скрываем
            scheduleDescriptionLabel.isHidden = true
            return
        }

        let text = selectedWeekDays // если есть, выводим
            .map { $0.shortTitle }
            .joined(separator: ", ")

        scheduleDescriptionLabel.text = text
        scheduleDescriptionLabel.isHidden = false
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        guard !selectedWeekDays.isEmpty else { return }

        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: "red",
            emoji: "🔥",
            schedule: selectedWeekDays
        )

        print("Создан трекер:", tracker)

        onCreate?(tracker)  

        dismiss(animated: true)
    }

    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasSelectedDays = !selectedWeekDays.isEmpty
        
        let isEnabled = isNameValid && hasSelectedDays
        
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .systemGray
    }

}

extension NewTrackerViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let isWithinLimit = newText.count <= maxLength
        
        if newText.count >= maxLength {
            errorLabel.isHidden = false
            optionsTopConstraint.constant = 24 + errorLabel.intrinsicContentSize.height + 8
            shakeTextField(textField)
        } else {
            errorLabel.isHidden = true
            optionsTopConstraint.constant = 24
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.updateCreateButtonState()
        }
        
        
        
        return isWithinLimit
    }
    
    private func shakeTextField(_ textField: UITextField) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-5, 5, -5, 5, -2.5, 2.5, 0]
        textField.layer.add(animation, forKey: "shake")
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

}
