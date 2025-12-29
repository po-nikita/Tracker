import UIKit

final class WeekdayCell: UITableViewCell {
    static let reuseIdentifier = "WeekdayCell" // Идентификатор переиспользованной ячейки
    
    private let titleLabel = UILabel()
    private let daySwitch = UISwitch()
    
    var onSwitchChanged: ((Bool) -> Void)? // closure, которое передает true/false во внешний код
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { // инициализатор
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder){ 
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.backgroundColor = .systemGray6
        backgroundColor = .systemGray6
        
        daySwitch.onTintColor = .systemBlue
        daySwitch.tintColor = .systemBlue
        
        titleLabel.font = .systemFont(ofSize: 17)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        daySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged) // Подписываемся на изменение состояния switch.
        accessoryView = daySwitch // switch справа, как в настройках.
    }
    
    func configure(day: Weekday, isOn: Bool) { // Метод для настройки ячейки извне.
        titleLabel.text = day.title // Берём название дня из enum.
        daySwitch.isOn = isOn //Устанавливаем состояние переключателя.
        
    }
    
    @objc private func switchChanged() {
        onSwitchChanged?(daySwitch.isOn) //Если closure установлен — передаём новое состояние наружу.
    }
}
