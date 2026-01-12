import UIKit

final class StatistickViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let emptyImage = UIImageView(image: UIImage(named: "noStatistick_image"))
    private let emptyLabel = UILabel()
    private var stats: TrackerStatistics?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitle()
        setupEmptyViews()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateRecords), name: .didUpdateTrackerRecords, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("statistick.title", comment: "")
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupEmptyViews() {
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyImage)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = NSLocalizedString("statistick.emptylabel", comment: "")
        emptyLabel.font = .systemFont(ofSize: 14)
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyImage.widthAnchor.constraint(equalToConstant: 80),
            emptyImage.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func didUpdateRecords() {
        loadStatistics()
    }
    
    private func loadStatistics() {
        let trackerStore = TrackerStore(context: AppDelegate.context!)
        let recordStore = TrackerRecordStore(context: AppDelegate.context!)
        
        let trackers = trackerStore.loadTrackers()
        let records = recordStore.loadRecords()
        
        view.subviews.filter { $0 is StatisticCardView }.forEach { $0.removeFromSuperview() }
        
        if trackers.isEmpty {
            emptyImage.isHidden = false
            emptyLabel.isHidden = false
        } else {
            emptyImage.isHidden = true
            emptyLabel.isHidden = true
            stats = StatisticsCalculator(trackers: trackers, records: records).calculate()
            setupStatCards()
        }
    }
    
    private func setupStatCards() {
        guard let stats = stats else { return }
        
        let values = [
            (String(stats.bestStreak), NSLocalizedString("statistick.bestPeriod", comment: "")),
            (String(stats.idealDays), NSLocalizedString("statistick.perfectDay", comment: "")),
            (String(stats.completedTrackers), NSLocalizedString("statistick.completedTracker", comment: "")),
            (String(Int(round(stats.averageCompletedPerDay))), NSLocalizedString("statistick.average", comment: ""))
        ]
        
        var previousCard: UIView? = nil
        for value in values {
            let card = StatisticCardView(number: value.0, title: value.1)
            view.addSubview(card)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                card.heightAnchor.constraint(equalToConstant: 90),
                card.topAnchor.constraint(equalTo: previousCard?.bottomAnchor ?? titleLabel.bottomAnchor, constant: previousCard == nil ? 77 : 12)
            ])
            
            previousCard = card
        }
    }
}
