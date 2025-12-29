import UIKit

extension UITextField {
    func setLeftPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: 0))
        leftView = paddingView
        leftViewMode = .always
    }
}
