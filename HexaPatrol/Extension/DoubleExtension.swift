//
//  DoubleExtension.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 04/02/25.
//

import Foundation

extension Double {
    func roundToPlaces(_ places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
