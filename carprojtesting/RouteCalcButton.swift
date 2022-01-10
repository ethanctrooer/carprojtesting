//
//  RouteCalcButton.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/6/22.
//

import SwiftUI

struct RouteCalcButton: View {
    
    @EnvironmentObject var userData: UserData
    @State public var buttonText = "Start Navigation"
    
    var body: some View {
        Button(action: {
            let routeCalcs = RouteCalcs(startingLatitude: userData.startingLatitude, startingLongitude: userData.startingLongitude, endingLatitude: userData.endingLatitude, endingLongitude: userData.endingLongitude)
            routeCalcs.createRoute()
            print("button is working")
        }) {
            Text(buttonText)
        }
    }
    
    /*
    static func setTitle(input: String) {
        buttonText = input
    } */
    
}

struct RouteCalcButton_Previews: PreviewProvider {
    static var previews: some View {
        RouteCalcButton()
    }
}
