import UIKit

final class CategoryCell: UITableViewCell {
    
    static let reuseId = "CategoryCell"
    
    private let titleLabel = UILabel()
    private let checkmark = UIImageView()
    private let separator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setup() {
        contentView.backgroundColor = .systemGray6
        backgroundColor = .clear
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        checkmark.image = UIImage(systemName: "checkmark")
        checkmark.tintColor = .systemBlue
        
        separator.backgroundColor = .systemGray4
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmark)
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(title: String, isSelected: Bool, isLast: Bool) {
        titleLabel.text = title
        checkmark.isHidden = !isSelected
        separator.isHidden = isLast
    }
}
