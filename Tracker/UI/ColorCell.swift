import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCell"
    
    private let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        colorView.layer.cornerRadius = 16
        colorView.layer.masksToBounds = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
                    colorView.widthAnchor.constraint(equalToConstant: 40),
                    colorView.heightAnchor.constraint(equalToConstant: 40),
                    colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
                ])
    }
    
    func colorConfigure(with color: UIColor, isSelected: Bool){
        colorView.backgroundColor = color
        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = isSelected ? color.cgColor : nil
    }
}
