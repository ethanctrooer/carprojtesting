//
//  RouteCalcsView.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/7/22.
//

import SwiftUI
import UIKit
import NMAKit

struct RouteCalcsView: UIViewRepresentable {
    
    @EnvironmentObject var userData: UserData
    
    private let mapView = NMAMapView.init(frame: .zero)
    
    func makeUIView(context: Self.Context) -> NMAMapView {
        // Use coordinator approach to pass UIKit events to SwiftUI
        mapView.gestureDelegate = context.coordinator

        // Setup rest of mapView settins
        mapView.copyrightLogoPosition = .topRight
        
        //initialization stuff for visuals
        mapView.set(geoCenter: NMAGeoCoordinates(latitude: userData.startingLatitude, longitude: userData.startingLongitude), animation: .none)
        mapView.positionIndicator.isVisible = true
        
        return mapView
    }
    
    func updateUIView(_ uiView: NMAMapView, context: Context) {
        //updating code here
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(startingLatitude: userData.startingLatitude, startingLongitude: userData.startingLongitude, endingLatitude: userData.endingLatitude, endingLongitude: userData.endingLongitude)
    }
    
    class Coordinator: RouteCalcs, NMAMapGestureDelegate {
        
    }
    
}

struct RouteCalcsView_Previews: PreviewProvider {
    static var previews: some View {
        RouteCalcsView()
    }
}
