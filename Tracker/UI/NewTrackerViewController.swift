import UIKit

final class NewTrackerViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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
    private var scheduleDescriptionTopConstraint: NSLayoutConstraint!
    private let categoryDescriptionLabel = UILabel()
    private var categoryDescriptionTopConstraint: NSLayoutConstraint!
    
    
    private let emojiTitleLabel = UILabel()
    private let emojis = TrackerEmoji.all
    private var selectedEmoji: String?
    
    private let colorTitleLabel = UILabel()
    private let colors = TrackerColors.all
    private var selectedColorIndex: Int?
    
    private var emojiCollectionView: UICollectionView!
    private var colorCollectionView: UICollectionView!
    
    private var selectedCategory: TrackerCategoryCoreData?
    var onCreate: ((Tracker, TrackerCategoryCoreData?) -> Void)?
    private var selectedWeekDays: [Weekday] = []
    private var optionsTopConstraint: NSLayoutConstraint!
    var onCategoryDeleted: (() -> Void)?
    var onCategoryUpdated: (() -> Void)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        
        setupCancelButton()
        setupCreateButton()
        setupTitle()
        setupNameTextField()
        setupErrorLabel()
        setupOptionsContainer()
        setupEmojiTitleLabel()
        setupEmojiCollectionView()
        setupColorTitleLabel()
        setupColorCollectionView()
        
        setupLayout()
        
        registerForKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    // MARK: Настройка UI
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        [titleLabel, nameTextField, errorLabel, optionsContainerView, emojiTitleLabel,
         colorTitleLabel,].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupTitle() {
        titleLabel.text = NSLocalizedString("newTracker.title", comment: "")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
    }
    
    private func setupNameTextField() {
        nameTextField.placeholder = NSLocalizedString("newTracker.placeholder", comment: "")
        nameTextField.backgroundColor = UIColor.systemGray6
        nameTextField.layer.cornerRadius = 10
        nameTextField.textColor = .black
        nameTextField.setLeftPadding(16)
        nameTextField.delegate = self
    }
    
    private func setupErrorLabel() {
        errorLabel.text = NSLocalizedString("newTracker.errorLabel", comment: "")
        errorLabel.font = UIFont.systemFont(ofSize: 17)
        errorLabel.textColor = .red
        errorLabel.isHidden = true
    }
    
    private func setupOptionsContainer() {
        optionsContainerView.backgroundColor = .systemGray6
        optionsContainerView.layer.cornerRadius = 16
        
        categoryButton.setTitle(NSLocalizedString("newTracker.categoryButton.title", comment: ""), for: .normal)
        categoryButton.setTitleColor(.black, for: .normal)
        categoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        addChevronIcon(to: categoryButton)
        categoryButton.addTarget(self, action: #selector(selectCategoryTapped), for: .touchUpInside)
        
        scheduleButton.setTitle(NSLocalizedString("newTracker.scheduleButton.title", comment: ""), for: .normal)
        scheduleButton.setTitleColor(.black, for: .normal)
        scheduleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        scheduleButton.contentHorizontalAlignment = .left
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        addChevronIcon(to: scheduleButton)
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.titlePadding = 0
        scheduleButton.configuration = config
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        
        separatorView.backgroundColor = .systemGray4
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleDescriptionLabel.font = .systemFont(ofSize: 17)
        scheduleDescriptionLabel.textColor = .systemGray
        scheduleDescriptionLabel.numberOfLines = 1
        scheduleDescriptionLabel.isHidden = true
        scheduleDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        categoryDescriptionLabel.font = .systemFont(ofSize: 17)
        categoryDescriptionLabel.textColor = .systemGray
        categoryDescriptionLabel.numberOfLines = 1
        categoryDescriptionLabel.isHidden = true
        categoryDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [categoryButton, categoryDescriptionLabel, separatorView, scheduleButton, scheduleDescriptionLabel].forEach {
            optionsContainerView.addSubview($0)
        }
        
        categoryDescriptionTopConstraint = categoryDescriptionLabel.topAnchor.constraint(
            equalTo: categoryButton.titleLabel!.bottomAnchor,
            constant: 4
        )
        
        scheduleDescriptionTopConstraint = scheduleDescriptionLabel.topAnchor.constraint(
            equalTo: scheduleButton.titleLabel!.bottomAnchor,
            constant: 4
        )
        
        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            categoryDescriptionTopConstraint,
            categoryDescriptionLabel.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor),
            categoryDescriptionLabel.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            scheduleButton.bottomAnchor.constraint(equalTo: optionsContainerView.bottomAnchor),
            
            scheduleDescriptionTopConstraint,
            scheduleDescriptionLabel.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor),
            scheduleDescriptionLabel.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor)
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
        cancelButton.setTitle(NSLocalizedString("newtracker.cancelButton.title", comment: ""), for: .normal)
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
        createButton.setTitle(NSLocalizedString("newtracker.createButton.title", comment: ""), for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.backgroundColor = .systemGray
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        view.addSubview(createButton)
    }
    
    private func setupEmojiTitleLabel() {
        emojiTitleLabel.text = NSLocalizedString("newTracker.emojiLabel", comment: "")
        emojiTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emojiTitleLabel.textColor = .black
    }
    
    private func setupColorTitleLabel() {
        colorTitleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorTitleLabel.text = NSLocalizedString("newTracker.colorLabel", comment: "")
        colorTitleLabel.textColor = .black
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        optionsTopConstraint = optionsContainerView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            optionsTopConstraint,
            
            optionsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            emojiTitleLabel.topAnchor.constraint(equalTo: optionsContainerView.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    // MARK: - Обработка клавиатуры
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if nameTextField.isFirstResponder {
            let textFieldFrame = nameTextField.convert(nameTextField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(textFieldFrame, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func selectCategoryTapped() {
        guard let context = AppDelegate.context else { return }
        let categoryStore = TrackerCategoryStore(context: context)
        let viewModel = CategoryViewModel(categoryStore: categoryStore)
        let categoryVC = CategoryViewController(viewModel: viewModel)
        
        categoryVC.onCategorySelected = { [weak self] category in
            self?.selectedCategory = category
            self?.categoryDescriptionLabel.text = category.title
            self?.categoryDescriptionLabel.isHidden = false
            self?.updateCreateButtonState()
        }
        
        categoryVC.onCategoryDeleted = { [weak self] in
            self?.onCategoryDeleted?()  
        }
        
        categoryVC.onCategoryUpdated = { [weak self] in
            self?.onCategoryUpdated?()
        }
        
        
        present(categoryVC, animated: true)
    }
    // MARK: -
    
    private func makeEmojiLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
        return layout
    }
    
    private func makeColorLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
        return layout
    }
    
    private func setupEmojiCollectionView() {
        let layout = makeEmojiLayout()
        emojiCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        emojiCollectionView.setCollectionViewLayout(makeEmojiLayout(), animated: false)
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        
        contentView.addSubview(emojiCollectionView)
    }
    
    private func setupColorCollectionView() {
        let layout = makeColorLayout()
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colorCollectionView.setCollectionViewLayout(makeColorLayout(), animated: false)
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        
        contentView.addSubview(colorCollectionView)
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVc = ScheduleViewController()
        scheduleVc.onDone = {[weak self] selectedDays in
            self?.selectedWeekDays = selectedDays.sorted { $0.rawValue < $1.rawValue }
            self?.updateScheduleLabel()
            self?.updateCreateButtonState()
        }
        scheduleVc.modalPresentationStyle = .pageSheet
        if let sheet = scheduleVc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.preferredCornerRadius = 16
            sheet.selectedDetentIdentifier = .large
        }
        present(scheduleVc, animated: true)
    }
    
    private func updateScheduleLabel() {
        guard !selectedWeekDays.isEmpty else {
            scheduleDescriptionLabel.isHidden = true
            
            scheduleButton.contentVerticalAlignment = .center
            setScheduleButtonInsets(top: 0)
            
            return
        }
        
        let text = selectedWeekDays
            .map { $0.shortTitle }
            .joined(separator: ", ")
        
        scheduleDescriptionLabel.text = text
        scheduleDescriptionLabel.isHidden = false
        
        scheduleButton.contentVerticalAlignment = .top
        setScheduleButtonInsets(top: 14)
    }
    
    
    private func setScheduleButtonInsets(top: CGFloat) {
        var config = scheduleButton.configuration ?? .plain()
        config.contentInsets = NSDirectionalEdgeInsets(
            top: top,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        scheduleButton.configuration = config
    }
    
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              !selectedWeekDays.isEmpty,
              let selectedEmoji = selectedEmoji,
              let selectedColorIndex = selectedColorIndex,
              let selectedCategory = selectedCategory,
              let categoryTitle = selectedCategory.title else { return }
        
        
        let selectedUIColor = colors[selectedColorIndex]
        let colorHex = selectedUIColor.toHexString()
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: colorHex,
            emoji: selectedEmoji,
            schedule: selectedWeekDays,
            categoryTitle: categoryTitle
        )
        
        print("Создан трекер:", tracker)
        
        onCreate?(tracker, selectedCategory)
        
        dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let hasSelectedDays = !selectedWeekDays.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColorIndex != nil
        let hasCategory = selectedCategory != nil
        
        let isEnabled = isNameValid && hasSelectedDays && hasEmoji && hasColor && hasCategory
        
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

extension NewTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorCollectionView {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as! EmojiCell
            let emoji = emojis[indexPath.item]
            cell.emojiConfigure(with: emoji, isSelected: emoji == selectedEmoji)
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as! ColorCell
            let color = colors[indexPath.item]
            let isSelected = selectedColorIndex == indexPath.item
            cell.colorConfigure(with: color, isSelected: isSelected)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            collectionView.reloadData()
            updateCreateButtonState()
        } else if collectionView == colorCollectionView {
            selectedColorIndex = indexPath.item
            collectionView.reloadData()
            updateCreateButtonState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
}
