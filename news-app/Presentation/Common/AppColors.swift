//
//  AppColors.swift
//  news-app
//
//  Created by Vokal-Ican on 07/11/26.
//

import UIKit

enum AppColors {
    static let background  = UIColor(hex: "#FFFFFF") //white
    static let softBackground  = UIColor(hex: "#767680") //gray
    static let primary     = UIColor(hex: "#007AFF") //blue
    static let textPrimary = UIColor(hex: "#000000") //black
    static let secondTextPrimary = UIColor(hex: "#8E8E93") //grey
}

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
