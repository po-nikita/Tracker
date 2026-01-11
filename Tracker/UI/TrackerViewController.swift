import UIKit

final class TrackerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabel.text = "Трекеры"
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
        searchTextField.placeholder = "Поиск"
        searchTextField.textColor = .ypGrayText
    }
    
    private func setupEmptyImage() {
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyImage)
        emptyImage.image = UIImage.empty
    }
    
    private func setupEmptyLabel() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        emptyLabel.text = "Что будем отслеживать?"
        emptyLabel.font = .systemFont(ofSize: 12)
    }
    
    private func setupConstrait() {
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // Поиск
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
            
            // Empty image
            emptyImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImage.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 230),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            
            // CollectionView
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
    
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackersForSelectedDate(in: categories[section]).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let trackers = trackersForSelectedDate(in: categories[indexPath.section])
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
        for (sectionIndex, category) in categories.enumerated() {
            let trackers = trackersForSelectedDate(in: category)
            if let itemIndex = trackers.firstIndex(where: { $0.id == trackerID }) {
                return IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    private func updatePlaceholder() {
        let hasTrackers = !categories.flatMap { trackersForSelectedDate(in: $0) }.isEmpty
        emptyImage.isHidden = hasTrackers
        emptyLabel.isHidden = hasTrackers
        collectionView.isHidden = !emptyImage.isHidden
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
}
