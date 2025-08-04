//
//  Color.swift
//  GymSeed
//
//  Created by Abraham may on 7/13/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        let r, g, b: Double

        if hex.hasPrefix("#") {
            _ = scanner.scanCharacter()
        }

        if scanner.scanHexInt64(&hexNumber) {
            r = Double((hexNumber & 0xff0000) >> 16) / 255
            g = Double((hexNumber & 0x00ff00) >> 8) / 255
            b = Double(hexNumber & 0x0000ff) / 255

            self.init(red: r, green: g, blue: b)
            return
        }

        self.init(.gray)
    }
}

