//
//  SupportingFile.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import Foundation
import SwiftUI
import Combine

func isValidEmail(_ email: String) -> Bool {
    // Regular expression pattern for validating email
    let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
    
    // Creating a regular expression object
    if let regex = try? NSRegularExpression(pattern: emailRegex) {
        // Matching the email string with the regular expression pattern
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
    }
    return false
}

func isValidPassword(_ password: String) -> Bool {
    let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[^A-Za-z0-9]).{8,}$"
    
    if let regex = try? NSRegularExpression(pattern: passwordRegex) {
        return regex.firstMatch(in: password, options: [], range: NSRange(location: 0, length: password.utf16.count)) != nil
    }
    
    return false
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
extension String {
    
    var hasUppercaseCharacter: Bool {
        return rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    var hasLowercaseCharacter: Bool {
           return rangeOfCharacter(from: .lowercaseLetters) != nil
       }
    
    var hasNumberCharacter: Bool {
            return rangeOfCharacter(from: .decimalDigits) != nil
        }
    
    var hasSpecialCharacter: Bool {
            let characterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?")
            return rangeOfCharacter(from: characterSet) != nil
        }
}
extension Double {
    func formattedString(maxFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.minimumFractionDigits = 0 // Ensure at least 0 decimal places
        
        // Convert Double to NSNumber to use NumberFormatter
        let number = NSNumber(value: self)
        
        // Use the formatter to get a formatted string
        if let formattedString = formatter.string(from: number) {
            return formattedString
        } else {
            // Fallback to default string conversion if formatting fails
            return "\(self)"
        }
    }
}

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { self.keyboardHeight(from: $0) }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .subscribe(on: RunLoop.main)
            .assign(to: \.currentHeight, on: self)
            .store(in: &cancellableSet)
    }
    
    private func keyboardHeight(from notification: Notification) -> CGFloat {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 0
        }
        return keyboardFrame.height
    }
}
