import UIKit

enum Colors {
    
    static var searchText: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark
                ? .white
                : .gray
            }
        }
    static var separatorColor: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? .secondaryLabel
            : .systemGray4
        }
    }
    
    static var separatorColorGray: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? .secondaryLabel
            : .systemGray
        }
    }
    
    static var chevronColor: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? .secondaryLabel
            : .systemGray2
        }
    }
    
    static var createButtonEnabled: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark ? .white : .black
            }
        }

        static var createButtonDisabled: UIColor {
            UIColor { _ in
                    .ypGrayText
            }
        }

        static var createButtonTitleEnabled: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark ? .black : .white
            }
        }

        static var createButtonTitleDisabled: UIColor {
            UIColor { _ in
                .white
            }
        }
    
    static let buttonDisabled: UIColor = .ypGrayText

        static var buttonEnabled: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark ? .white : .black
            }
        }

        static var buttonEnabledText: UIColor {
            UIColor { trait in
                trait.userInterfaceStyle == .dark ? .black : .white
            }
        }

        static let buttonDisabledText: UIColor = .white
    
    static var dimanicWeekdayCell = UIColor { trait in
          trait.userInterfaceStyle == .dark
              ? UIColor.secondarySystemBackground
              : UIColor.systemGray6               
      }
    
    static var daySwitch: UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : .systemGray6
        }
    }
    
    static var WhiteNight = UIColor(
            red: 26/255,
            green: 27/255,
            blue: 34/255,
            alpha: 1
        )
}
