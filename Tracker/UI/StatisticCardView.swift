import UIKit

final class StatisticCardView: UIView {
    
    private let numberLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let gradientBorder = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()
    
    init(number: String, title: String) {
        super.init(frame: .zero)
        setup(number: number, title: title)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup(number: String, title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        gradientBorder.colors = [
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor
        ]
        gradientBorder.startPoint = CGPoint(x: 0, y: 0)
        gradientBorder.endPoint = CGPoint(x: 1, y: 0)
        layer.addSublayer(gradientBorder)
        
        shapeLayer.strokeColor = UIColor.label.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1
        gradientBorder.mask = shapeLayer
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.font = .systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .label
        numberLabel.text = number
        addSubview(numberLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .label
        titleLabel.text = title
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            numberLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: numberLabel.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 4)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorder.frame = bounds
        shapeLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath
    }
}
