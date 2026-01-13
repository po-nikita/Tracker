import UIKit

final class WeekdayCell: UITableViewCell {
    static let reuseIdentifier = "WeekdayCell"
    
    private let titleLabel = UILabel()
    private let daySwitch = UISwitch()
    
    var onSwitchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder){
        nil
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.backgroundColor = Colors.dimanicWeekdayCell
        backgroundColor = Colors.dimanicWeekdayCell
        
        daySwitch.onTintColor = .systemBlue
        daySwitch.backgroundColor = Colors.daySwitch
        daySwitch.layer.cornerRadius = daySwitch.frame.height / 2
        daySwitch.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 17)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        daySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        accessoryView = daySwitch
    }
    
    func configure(day: Weekday, isOn: Bool) {
        titleLabel.text = day.title
        daySwitch.isOn = isOn
        
    }
    
    @objc private func switchChanged() {
        onSwitchChanged?(daySwitch.isOn) 
    }
}
