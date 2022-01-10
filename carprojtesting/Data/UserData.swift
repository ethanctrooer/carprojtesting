//
//  UserData.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/4/22.
//

import Foundation
import SwiftUI
import NMAKit

class UserData: ObservableObject {
    
    @Published var startingDestination = "From: Stanford Shopping Mall"
    //@Published var endingDestination = "UC Berkeley"
    @Published var endingDestination = "To: 1200 Pine St"
    @Published var isShowingOnExternalDisplay = false
    
    @Published var startingLatitude = 37.44538395
    @Published var startingLongitude = -122.1411811620072
    
    //to uc berkeley
    /*
    @Published var endingLatitude  = 37.8713958
    @Published var endingLongitude = -122.2651394 */
    
    //to redwood city costco
    
    @Published var endingLatitude = 37.479366302490234
    @Published var endingLongitude = -122.21553802490234
    
    //to 1200 Pine
    /*
    @Published var endingLatitude  = 37.445384
    @Published var endingLongitude = -122.1411812 */
    
    
    
}
