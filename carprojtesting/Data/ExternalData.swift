//
//  ExternalData.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/7/22.
//

import Foundation
import SwiftUI
import NMAKit

class ExternalData: ObservableObject {
    
    @Published var maneuverImage = Image("left_arrow")
    @Published var currentRoadName = Text("Starting Road")
    @Published var maneuverRoadName = Text("Next Road")
    @Published var nextManeuverCoordinates = NMAGeoCoordinates(latitude: 37.8713958, longitude: -122.2651394)
    @Published var maneuverDistance = Text(String(format: ".0f", 0.0))
    @Published var currentSpeed = 0.0 //in m/s
    
}
