import UIKit

final class TrackerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    
    private lazy var trackerStore: TrackerStore = {
        guard let context = AppDelegate.context else {
            fatalError("Core Data context is not available")
        }
        return TrackerStore(context: context)
    }()
    
    private lazy var recordStore: TrackerRecordStore = {
        guard let context = AppDelegate.context else {
            fatalError("Core Data context is not available")
        }
        return TrackerRecordStore(context: context)
    }()
    
    private var filteredCategories: [TrackerCategory] = []
    private var isSearching: Bool = false
    private let searchController = UISearchController(searchResultsController: nil)

    private let titleLabel = UILabel()
    private let searchView = UIView()
    private let searchIcon = UIImageView()
    private let searchTextField = UITextField()
    private let emptyImage = UIImageView()
    private let emptyLabel = UILabel()
    
    private var collectionView: UICollectionView!
    private var selectedDate: Date = Date()
    
    var categories: [TrackerCategory] = []
    
    var completedTrackers: [TrackerRecord] = []
    let datePicker = UIDatePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTitleLabel()
        setupSearchController()
        setupSearchView()
        setupSearchIcon()
        setupSearchTextField()
        setupEmptyImage()
        setupEmptyLabel()
        setupCollectionView()
        setupConstrait()
        
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.reuseIdentifier
        )
        
        collectionView.register(CategoryHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryHeaderView.reuseIdentifier
        )
        loadDataFromCoreData()
        
    }
    
    private func loadDataFromCoreData() {
        let allTrackers = trackerStore.loadTrackers()
        
        var trackersDict: [String: [Tracker]] = [:]
        for tracker in allTrackers {
            let categoryTitle = tracker.categoryTitle
            if trackersDict[categoryTitle] == nil {
                trackersDict[categoryTitle] = []
            }
            trackersDict[categoryTitle]?.append(tracker)
        }
        
        categories = trackersDict.map { title, trackers in
            TrackerCategory(title: title, trackers: trackers)
        }
        
        completedTrackers = recordStore.loadRecords()
        
        updatePlaceholder()
        collectionView.reloadData()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            image: UIImage.plus,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        loadDataFromCoreData()
    }
    
    @objc private func searchTextChanged() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            isSearching = false
            collectionView.reloadData()
            updatePlaceholder()
            return
        }

        isSearching = true
        filterTrackers(for: searchText)
    }


    @objc private func addButtonTapped() {
        let vc = NewTrackerViewController()
        vc.onCreate = { [weak self] tracker, _ in
            self?.addTracker(tracker)
        }
        
        vc.onCategoryDeleted = { [weak self] in
            self?.loadDataFromCoreData()
        }
        vc.onCategoryUpdated = { [weak self] in
            self?.loadDataFromCoreData()
        }
        
        
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.selectedDetentIdentifier = .large
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(vc, animated: true)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchTextField.textColor = .black
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("tracker.search.placeholder", comment: ""),
            attributes: [.foregroundColor: UIColor.gray]
        )
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }

    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.text = NSLocalizedString("tracker.title", comment: "")
        titleLabel.font = .systemFont(ofSize: 41, weight: .bold)
    }
    
    private func setupSearchView() {
        searchView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchView)
        searchView.backgroundColor = UIColor.systemGray5
        searchView.layer.cornerRadius = 10
    }
    
    private func setupSearchIcon() {
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchView.addSubview(searchIcon)
        searchIcon.image = UIImage.mangnifyingglass
        searchIcon.tintColor = .gray
    }
    
    private func setupSearchTextField() {
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchView.addSubview(searchTextField)
        searchTextField.placeholder = NSLocalizedString("tracker.search.placeholder", comment: "")
        searchTextField.textColor = .black
    }
    
    private func setupEmptyImage() {
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyImage)
        emptyImage.image = UIImage.empty
    }
    
    private func setupEmptyLabel() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        emptyLabel.text = NSLocalizedString("tracker.emptylabel", comment: "")
        emptyLabel.font = .systemFont(ofSize: 12)
    }
    
    private func setupConstrait() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchView.heightAnchor.constraint(equalToConstant: 36),
            
            searchIcon.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 8),
            searchIcon.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 15),
            searchIcon.heightAnchor.constraint(equalToConstant: 15),
            
            searchTextField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 6),
            searchTextField.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            
            emptyImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImage.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 230),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            
            collectionView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func makeCollectionLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 16
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 28)
        return layout
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func addTracker(_ tracker: Tracker) {
        trackerStore.saveTracker(tracker, categoryTitle: tracker.categoryTitle)
        
        loadDataFromCoreData()
    }
    
    private func filterTrackers(for query: String) {
        let lowercasedQuery = query.lowercased()
        
        let allTrackers = trackerStore.loadTrackers()
        
        let matchingTrackers = allTrackers.filter { $0.name.lowercased().contains(lowercasedQuery) }
        
        var trackersDict: [String: [Tracker]] = [:]
        for tracker in matchingTrackers {
            let categoryTitle = tracker.categoryTitle
            if trackersDict[categoryTitle] == nil {
                trackersDict[categoryTitle] = []
            }
            trackersDict[categoryTitle]?.append(tracker)
        }
        
        filteredCategories = trackersDict.map { title, trackers in
            TrackerCategory(title: title, trackers: trackers)
        }
        
        collectionView.reloadData()
        updatePlaceholder()
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearching = false
            collectionView.reloadData()
            updatePlaceholder()
            return
        }
        
        isSearching = true
        filterTrackers(for: searchText)
    }

    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isSearching ? filteredCategories.count : categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = isSearching ? filteredCategories[section] : categories[section]
        return trackersForSelectedDate(in: category).count
       }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = isSearching ? filteredCategories[indexPath.section] : categories[indexPath.section]
        let trackers = trackersForSelectedDate(in: category)
        let tracker = trackers[indexPath.item]

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let isCompletedToday = recordStore.isTrackerCompleted(trackerID: tracker.id, date: selectedDate)
        let completedCount = recordStore.getCompletedCount(for: tracker.id)

        cell.configure(with: tracker, completedCount: completedCount, isCompleted: isCompletedToday)
        cell.onCompleteTapped = { [weak self] trackerID in
            self?.handleComplete(trackerID: trackerID)
        }

        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.reuseIdentifier,
            for: indexPath
        )
        
        guard let header = reusableView as? CategoryHeaderView else {
            assertionFailure("Expected CategoryHeaderView")
            return reusableView
        }
        
        header.titleLabel.text = categories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let trackers = trackersForSelectedDate(in: categories[section])
        return trackers.isEmpty ? .zero : CGSize(width: collectionView.bounds.width, height: 28)
    }
    
    private func handleComplete(trackerID: UUID) {
        guard !isFutureDate(selectedDate) else { return }
        
        let isCompletedToday = recordStore.isTrackerCompleted(trackerID: trackerID, date: selectedDate)
        
        if isCompletedToday {
            recordStore.deleteRecord(trackerID: trackerID, date: selectedDate)
        } else {
            recordStore.saveRecord(trackerID: trackerID, date: selectedDate)
        }
        
        completedTrackers = recordStore.loadRecords()
        
        if let indexPath = findIndexPathForTracker(trackerID: trackerID) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func findIndexPathForTracker(trackerID: UUID) -> IndexPath? {
        let currentCategories = isSearching ? filteredCategories : categories
        
        for (sectionIndex, category) in currentCategories.enumerated() {
            let trackers = isSearching ? trackersForSearch(in: category) : trackersForSelectedDate(in: category)
            if let itemIndex = trackers.firstIndex(where: { $0.id == trackerID }) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        
        return nil
    }

    private func updatePlaceholder() {
        let currentCategories = isSearching ? filteredCategories : categories
        let hasTrackers = !currentCategories.flatMap { trackersForCategory($0) }.isEmpty
        
        collectionView.isHidden = !hasTrackers
        emptyImage.isHidden = hasTrackers
        emptyLabel.isHidden = hasTrackers

        guard !hasTrackers else { return }

        if isSearching {
            emptyImage.image = UIImage(named: "emptyFound_image") 
            emptyLabel.text = NSLocalizedString("tracker.emptyFound.label", comment: "")
        } else {
            emptyImage.image = UIImage.empty
            emptyLabel.text = NSLocalizedString("tracker.emptylabel", comment: "")
        }
    }

    private func trackersForCategory(_ category: TrackerCategory) -> [Tracker] {
        return isSearching ? trackersForSearch(in: category) : trackersForSelectedDate(in: category)
    }


    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInsets: CGFloat = 16 * 2
        let interItemSpacing: CGFloat = 8
        let availableWidth = collectionView.bounds.width - horizontalInsets - interItemSpacing
        let width = availableWidth / 2
        let height: CGFloat = 148
        return CGSize(width: width, height: height)
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        return Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    private func trackersForSelectedDate(in category: TrackerCategory) -> [Tracker] {
        let weekdayNumber = Calendar.current.component(.weekday, from: selectedDate)
        let adjustedWeekday = weekdayNumber == 1 ? 7 : weekdayNumber - 1
        guard let weekday = Weekday(rawValue: adjustedWeekday) else { return [] }
        return category.trackers.filter { $0.schedule.contains(weekday) }
    }
   
    private func trackersForSearch(in category: TrackerCategory) -> [Tracker] {
        return category.trackers
    }

    private func openEditTracker(_ tracker: Tracker) {
        let vc = NewTrackerViewController()
        vc.configureForEdit(tracker: tracker)

        vc.onUpdate = { [weak self] updatedTracker in
            self?.trackerStore.updateTracker(updatedTracker)
            self?.loadDataFromCoreData()
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }

        present(vc, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let trackers = trackersForSelectedDate(in: categories[indexPath.section])
        let tracker = trackers[indexPath.item]

        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            actionProvider: { [weak self] _ in
                guard let self else { return nil }

                let editAction = UIAction(
                    title: NSLocalizedString("tracker.context.edit", comment: "")
                ) { _ in
                    self.openEditTracker(tracker)
                }

                let deleteAction = UIAction(
                    title: NSLocalizedString("tracker.context.delete", comment: ""),
                    attributes: .destructive
                ) { _ in
                    self.confirmDelete(tracker)
                }
                
                return UIMenu(children: [editAction, deleteAction])
            })
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell.cardView, parameters: parameters)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell.cardView, parameters: parameters)
    }
    
    private func confirmDelete(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("tracker.delete.confirm.message", comment: ""),
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("tracker.delete.confirm.cancel", comment: ""),
            style: .cancel
        ))

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("tracker.delete.confirm.delete", comment: ""),
            style: .destructive,
            handler: { [weak self] _ in
                self?.deleteTracker(tracker)
            }
        ))

        present(alert, animated: true)
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        trackerStore.deleteTracker(id: tracker.id)
        recordStore.deleteAllRecords(for: tracker.id)
        loadDataFromCoreData()
    }

}

extension TrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
