import UIKit

final class ScheduleViewController: UIViewController {
    private var selectedWeekDays: Set<Weekday> = []
    var onDone: ((Set<Weekday>) -> Void)? 
    
    private let doneButton = UIButton()
    private let titleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let weekdays = Weekday.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("schedule.title", comment: "")
        setupTableView()
        setupTitle()
        setupDoneButton()
        setupLayout()
    }
    
    private func setupTitle() {
        titleLabel.text = NSLocalizedString("schedule.title", comment: "")
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .secondarySystemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        tableView.register(WeekdayCell.self, forCellReuseIdentifier: WeekdayCell.reuseIdentifier)
        
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        
        tableView.separatorColor = Colors.separatorColorGray
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
    }
    
    private func setupDoneButton() {
        doneButton.setTitle(NSLocalizedString("schedule.doneButton.title", comment: ""), for: .normal)
        doneButton.setTitleColor(UIColor { $0.userInterfaceStyle == .dark ? .black : .white }, for: .normal)
        doneButton.backgroundColor = .label
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
        
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneButtonTapped() { // при нажатии на готово передает замыкание с выбранными днями
        onDone?(selectedWeekDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekdayCell.reuseIdentifier, for: indexPath) as? WeekdayCell else {
            return UITableViewCell()
        }
        
        let day = weekdays[indexPath.row] // Получаем конкретный день по индексу строки.
        let isOn = selectedWeekDays.contains(day) // Проверяем: выбран ли этот день.
        
        cell.configure(day: day, isOn: isOn) //Настраиваем ячейку.
        
        cell.onSwitchChanged = { [weak self] isOn in // Подписываемся на переключение switch.
            
            guard let self else {return}
            if isOn {
                self.selectedWeekDays.insert(day)
            }else {
                self.selectedWeekDays.remove(day)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == weekdays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        }
    }
}

extension ScheduleViewController: UITableViewDelegate {
    
}
