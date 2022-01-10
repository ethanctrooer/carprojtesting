//
//  RouteCalcs.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/6/22.
//

import Foundation
import NMAKit
import SwiftUI
//import CLLocationManager

class RouteCalcs: NSObject {
    
    var startingLatitude: Double
    var startingLongitude: Double
    var endingLatitude: Double
    var endingLongitude: Double
    
    //core handles calculations
    private var router = NMACoreRouter()
    private var route: NMARoute?
    private var mapRoute: NMAMapRoute?
    private lazy var navigationManager = NMANavigationManager.sharedInstance()
    private var mapView: NMAMapView!
    private var geoBoundingBox : NMAGeoBoundingBox?
    
    //@Published var externalText = "String example"
    
    init(startingLatitude: Double, startingLongitude: Double, endingLatitude: Double, endingLongitude: Double){
        self.startingLatitude = startingLatitude
        self.startingLongitude = startingLongitude
        self.endingLatitude = endingLatitude
        self.endingLongitude = endingLongitude
        
        //below reaaaaally sketch
        super.init()
        
        //must make something conform to uiviewrepresentable in order to send delegate messages
        navigationManager.delegate = self
        navigationManager.isSpeedWarningEnabled = true
        
        print("initialization complete")
        
        let geoCoordCenter = NMAGeoCoordinates(latitude: startingLatitude,
                                               longitude: endingLatitude)
        
        //createRoute()
        initCheck()
        
        print("create route activated")
    }
    
    private func initCheck() {
        if route == nil {
            createRoute()
            return
        }

        navigationManager.stop()

        if !(NMAPositioningManager.sharedInstance().dataSource is NMADevicePositionSource) {
            NMAPositioningManager.sharedInstance().dataSource = nil
        }

        // Restore the map orientation to show entire route on screen
        geoBoundingBox.map{ mapView.set(boundingBox: $0, animation: .linear) }
        mapView.orientation = 0
        enableMapTracking(false)

        route = nil
        if mapRoute != nil {
            _ = mapRoute.map{ mapView.remove(mapObject: $0) }
        }
        mapRoute = nil
        geoBoundingBox = nil
    }

    // MARK: Route Calculations
    public func createRoute() {

        // Create an NSMutableArray to add two stops
        var stops = [Any]()
        
        //make GeoCoordinates
        let startingDestination = NMAGeoCoordinates(latitude: self.startingLatitude, longitude: self.startingLongitude)
        let endingDestination = NMAGeoCoordinates(latitude: self.endingLatitude, longitude: self.endingLongitude)
        
        //add stops to array
        stops.append(startingDestination)
        stops.append(endingDestination)
        
        //set routingMode options
        let routingMode = NMARoutingMode(routingType: .fastest, transportMode: .car, routingOptions: .avoidDirtRoad)
        
        // Trigger the route calculation

        router.calculateRoute(withStops: stops, routingMode: routingMode,
                                      { [self] (result, error) in
                    // check error and unwrap route
                    guard let route = result?.routes?.first, error == NMARoutingError.none else {
                        print("error \(error)")
                        return
                    }
            //strong reference may cause memory leaks
            //taken from https://stackoverflow.com/questions/68045796/cannot-use-loop-on-nmacorerouter-swift-heremap-sdk
            self.route = route
            
            self.updateMapRoute(with: self.route)
            
            print("navigation starting")
            self.startNavigation()
            
        })

    }
    
    private func startNavigation() {
        navigationManager.map = mapView
        //use simualted route
        self.startTurnByTurnNavigation(with: self.route!, useSimulation: false)
 
    }
    
    private func startTurnByTurnNavigation(with route: NMARoute, useSimulation: Bool) {
        
        if let error = navigationManager.startTurnByTurnNavigation(route) {
            //showMessage("Error:start navigation returned error code \(error._code)")
            //NotificationCenter.default.post(name: Notification.Name("Error"), object: nil, userInfo: ["error": error._code])
            print("error: \(error._code)")
        } else {
            // Set the map tracking properties
            enableMapTracking(true)
            if useSimulation {
                // Simulation navigation by init the PositionSource with route and set movement speed
                let source = NMARoutePositionSource(route: route)
                source.movementSpeed = 10
                NMAPositioningManager.sharedInstance().dataSource = source
            }
        }
    }
    
    // MARK: Non-essential functions
    private func enableMapTracking(_ enabled: Bool) {
        navigationManager.mapTrackingAutoZoomEnabled = enabled
        navigationManager.mapTrackingEnabled = enabled
        print("maptrackingenabled")
    }
    
    private func updateMapRoute(with route: NMARoute?) {
        // remove previously created map route from map
        if let previousMapRoute = mapRoute {
            mapView.remove(mapObject:previousMapRoute)
        }

        guard let unwrappedRoute = route else {
            return
        }

        mapRoute = NMAMapRoute(unwrappedRoute)
        mapRoute?.traveledColor = .clear
        _ = mapRoute.map{ mapView?.add(mapObject: $0) }

        /*
        // In order to see the entire route, we orientate the
        // map view accordingly
        if let boundingBox = unwrappedRoute.boundingBox {
            geoBoundingBox = boundingBox
            mapView.set(boundingBox: boundingBox, animation: .linear)
        }
         */
    }
}

extension RouteCalcs : NMANavigationManagerDelegate {
    
    // MARK: NotificationCenter for driving events (NavigationManager)
    func navigationManagerWillReroute(_ navigationManager: NMANavigationManager) {
        //showMessage("New navigation route will be created")
    }

    func navigationManager(_ navigationManager: NMANavigationManager,
                           didUpdateRoute routeResult: NMARouteResult) {

        let result = routeResult
        guard let routes = result.routes, routes.count > 0 else {
            // The routeResult doesn't contain route for redraw.
            // It might occur when navigation stop was called.
            return
        }

        // Let's add the 1st result onto the map
        route = routes[0]
        updateMapRoute(with: route)
    }

    func navigationManager(_ navigationManager: NMANavigationManager, didRerouteWithError error: NMARoutingError) {
        var message : String
        if error == NMARoutingError.none {
            message = "successfully"
        } else {
            message = "with error \(error)"
        }
        //showMessage("Navigation manager finished attempt to route " + message)
    }

    // Signifies that there is new instruction information available
    
    func navigationManager(_ navigationManager: NMANavigationManager,
                           didUpdateManeuvers currentManeuver: NMAManeuver?,
                           _ nextManeuver: NMAManeuver?) {
        //showMessage("New maneuver is available")
        //externalText = "new maneuver avaliable"
        print("new manuver avaliable")
        //https://stackoverflow.com/questions/48924754/here-maps-sdk-ios-swift-4-turn-by-turn-navigation-takes-too-long-to-start
        //var something: String
        //something = nextManeuver?.roadName as String? ?? "
        //print(currentManeuver. as String?)
        //print(something)
        //https://stackoverflow.com/questions/40691184/expression-implicitly-coerced-from-string-to-any
        NotificationCenter.default.post(name: Notification.Name("maneuverNotif"), object: nil, userInfo: ["maneuver": currentManeuver!])
        //currentManeuver.

    }

    // Signifies that the system has found a GPS signal
    func navigationManagerDidFindPosition(_ navigationManager: NMANavigationManager) {
        //showMessage("New position has been found")
    }

}

extension NSNotification {
    static let maneuverNotif = Notification.Name.init("maneuverNotif")
}
