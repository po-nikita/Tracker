import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    // MARK: UI
    private let cardView = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    
    private let daysLabel = UILabel()
    private let actionButton = UIButton()
    var onCompleteTapped: ((UUID) -> Void)?
    var trackerID: UUID?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func completeButtonTapped() {
        guard let trackerID else { return }
        onCompleteTapped?(trackerID)
    }
    
    //MARK: Setup
    private func setupViews() {
        contentView.backgroundColor = .clear
        
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        emojiLabel.font = .systemFont(ofSize: 24)
        cardView.addSubview(emojiLabel)
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        cardView.addSubview(titleLabel)
        
        daysLabel.font = .systemFont(ofSize: 12)
        daysLabel.textColor = .black
        contentView.addSubview(daysLabel)
        
        actionButton.layer.cornerRadius = 16
        actionButton.tintColor = .white
        
        actionButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(actionButton)
    }
    
    private func setupLayout() {
        [cardView, emojiLabel, titleLabel, daysLabel, actionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            daysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            actionButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(with tracker: Tracker, completedCount: Int, isCompleted: Bool) {
        trackerID = tracker.id
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = .systemGreen
        daysLabel.text = "\(completedCount) \(dayWord(for: completedCount))"
        
        let imageName = isCompleted ? "checkmark" : "plus"
        actionButton.setImage(UIImage(systemName: imageName), for: .normal)
        actionButton.backgroundColor = .systemGreen
    }
    
    
    private func dayWord(for count: Int) -> String {
        if count % 10 == 1 && count % 100 != 11 {
            return "день"
        }
        
        if (2...4).contains(count % 10) && !(12...14).contains(count % 100) {
            return "дня"
        }
        
        return "дней"
    }
    
}
