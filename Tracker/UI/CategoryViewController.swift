import UIKit

final class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let viewModel: CategoryViewModel
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private let emptyImage = UIImageView()
    private let emptyLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private let containerView = UIView()
    
    private var tableHeightConstraint: NSLayoutConstraint?
    var onCategoryDeleted: (() -> Void)?
    var onCategoryUpdated: (() -> Void)?
    
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?
    
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        
        setupViews()
        setupTitleLabel()
        setupEmptyLabel()
        setupEmptyImage()
        setupAddButton()
        setupTableView()
        setupConstraints()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [titleLabel, emptyImage, emptyLabel, containerView, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tableView)
    }
    
    private func setupTitleLabel() {
        titleLabel.text = NSLocalizedString("category.titleLabel", comment: "")
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
    }
    
    private func setupEmptyLabel() {
        emptyLabel.text = NSLocalizedString("category.emptyLabel", comment: "")
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyLabel.textColor = .label
    }
    
    private func setupEmptyImage() {
        emptyImage.image = UIImage.empty
    }
    
    private func setupAddButton() {
        addButton.setTitle(NSLocalizedString("category.button.addCategory", comment: ""), for: .normal)
        addButton.backgroundColor = Colors.createButtonEnabled
            addButton.setTitleColor(
                UIColor { trait in
                    trait.userInterfaceStyle == .dark ? .black : .white
                },
                for: .normal
            )
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.layer.cornerRadius = 16
        addButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = true
        tableView.rowHeight = 75
        tableView.alwaysBounceVertical = true
        
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
    }
    
    // MARK: - Bind
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
            self.updateEmptyState()
            self.updateTableHeight()
        }
        
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.categories.isEmpty
        tableView.isHidden = isEmpty
        emptyImage.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
    private func updateTableHeight() {
        let maxHeight: CGFloat = 600
        let contentHeight = CGFloat(viewModel.categories.count * 75)
        tableHeightConstraint?.constant = min(contentHeight, maxHeight)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emptyImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 246),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        tableHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true
        updateTableHeight()
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryTapped() {
        let newCategoryVC = NewCategoryViewController { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
        present(newCategoryVC, animated: true)
    }
    
    
    // MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseId, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.category(at: indexPath.row)
        let isSelected = viewModel.isSelected(category)
        let isLast = indexPath.row == viewModel.categories.count - 1
        
        cell.configure(title: category.title ?? "", isSelected: isSelected, isLast: isLast)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(categoryLongPressed(_:)))
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    @objc private func categoryLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let cell = gesture.view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        
        let category = viewModel.category(at: indexPath.row)
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.alpha = 0.9
        blurView.tag = 999
        view.addSubview(blurView)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("category.alert.edit", comment: ""), style: .default) { [weak self] _ in
            self?.presentEditCategory(category)
            blurView.removeFromSuperview()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("category.alert.delete", comment: ""), style: .destructive) { [weak self] _ in
            self?.presentDeleteCategory(category)
            blurView.removeFromSuperview()
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("category.alert.cancel", comment: ""), style: .cancel) { _ in
            blurView.removeFromSuperview()
        })
        
        present(alert, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.category(at: indexPath.row)
        viewModel.selectCategory(category)
        onCategorySelected?(category)
        dismiss(animated: true)
    }
    
    private func presentEditCategory(_ category: TrackerCategoryCoreData) {
        let editVC = EditCategoryViewController(title: category.title ?? "") { [weak self] newTitle in
            category.title = newTitle
            do {
                try category.managedObjectContext?.save()
                self?.viewModel.loadCategories()
                self?.onCategoryUpdated?()
                
            } catch {
                print("Ошибка обновления категории: \(error)")
            }
        }
        present(editVC, animated: true)
    }
    
    private func presentDeleteCategory(_ category: TrackerCategoryCoreData) {
        let alert = UIAlertController(title: NSLocalizedString("category.alert.deleteTitle", comment: ""), message: NSLocalizedString("category.alert.message", comment: ""), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("category.alert.delete", comment: ""), style: .destructive) { [weak self] _ in
            guard let context = category.managedObjectContext else { return }
            
            if let trackers = category.trackers as? Set<TrackerCoreData> {
                for tracker in trackers {
                    if let records = tracker.records as? Set<TrackerRecordCoreData> {
                        for record in records {
                            context.delete(record)
                        }
                    }
                    context.delete(tracker)
                }
            }
            
            context.delete(category)
            
            do {
                try context.save()
                self?.viewModel.loadCategories()
                self?.onCategoryDeleted?()
                
            } catch {
                print("Ошибка удаления категории: \(error)")
            }
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("category.alert.cancel", comment: ""), style: .cancel))
        present(alert, animated: true)
    }
    
}
