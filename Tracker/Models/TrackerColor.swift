import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    func toHexString() -> String {
        guard let components = self.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
    }
}

struct TrackerColors {
    static let all: [UIColor] = [
        UIColor(hex: "#FD4C49"),
        UIColor(hex: "#FF881E"),
        UIColor(hex: "#007BFA"),
        UIColor(hex: "#6E44FE"),
        UIColor(hex: "#33CF69"),
        UIColor(hex: "#E66DD4"),
        UIColor(hex: "#F9D4D4"),
        UIColor(hex: "#34A7FE"),
        UIColor(hex: "#46E69D"),
        UIColor(hex: "#35347C"),
        UIColor(hex: "#FF674D"),
        UIColor(hex: "#FF99CC"),
        UIColor(hex: "#F6C48B"),
        UIColor(hex: "#7994F5"),
        UIColor(hex: "#832CF1"),
        UIColor(hex: "#AD56DA"),
        UIColor(hex: "#8D72E6"),
        UIColor(hex: "#2FD058")
    ]
}
