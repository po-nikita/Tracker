import UIKit

final class FiltersViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let tableContainer = UIView()
    
    var onSelectFilter: ((TrackerFilter) -> Void)?
    var currentFilter: TrackerFilter = .all
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let filters = TrackerFilter.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitle()
        setupTableView()
        setupLayout()
    }
    
    private func setupTitle() {
        titleLabel.text = NSLocalizedString("filters.title", comment: "")
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupTableView() {
        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        tableContainer.backgroundColor = Colors.dimanicWeekdayCell
        tableContainer.layer.cornerRadius = 16
        tableContainer.clipsToBounds = true
        view.addSubview(tableContainer)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableContainer.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.isScrollEnabled = false
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView

        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Colors.separatorColorGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        tableView.rowHeight = 75
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableContainer.heightAnchor.constraint(equalToConstant: CGFloat(filters.count) * 75),
            
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor)
        ])
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = filters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)

        cell.textLabel?.text = filter.displayName
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        let shouldShowCheckmark: Bool = {
            switch filter {
            case .completed, .uncompleted:
                return filter == currentFilter
            case .all, .today:
                return false
            }
        }()

        cell.accessoryType = shouldShowCheckmark ? .checkmark : .none
        cell.tintColor = .systemBlue

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]
        onSelectFilter?(selectedFilter)
        dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
