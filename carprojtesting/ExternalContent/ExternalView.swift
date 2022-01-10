//
//  ExternalView.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/4/22.
//

import Foundation
import SwiftUI
import NMAKit

struct ExternalView: View {
    
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var externalData: ExternalData
    //@State var turnImage: Image
    
    // MARK: View
    var body: some View {
        VStack {
            HStack {
                Text(userData.startingDestination)
                Spacer()
                Text(userData.endingDestination)
            }
            
            Spacer()
            
            HStack {
                
                //road names of current road & road that maneuver takes place on
                VStack {
                    externalData.currentRoadName
                    externalData.maneuverRoadName
                    externalData.maneuverDistance
                }
                
                externalData.maneuverImage
                    .resizable() //must be first or it won't work
                    .colorInvert()
                   // .aspectRatio(contentMode: .fit)
                    .scaledToFill()
                    .frame(width: 150, height: 150) //this is hardcoded, use GeometryReader for percentages
                        //see https://www.hackingwithswift.com/books/ios-swiftui/resizing-images-to-fit-the-screen-using-geometryreader
                
                //Text(String(externalData.currentSpeed) + " m/s")
                Text(String(format: "%.0f", (externalData.currentSpeed * 2.237)) + " MPH")
            }
            
            Spacer()
            
            //load the view, but dont have it visible (change 0-1 to make visible)
            RouteCalcsView()
                .opacity(0)
            
        }
        .environment(\.colorScheme, .dark)
        //.edgesIgnoringSafeArea(.all)
        //.statusBar(hidden: true)
        
        // MARK: Notification
        //https://stackoverflow.com/questions/58818046/how-to-set-addobserver-in-swiftui, second answer 27 upvote
        //listens for a notification from RouteCalcs that a new NMAManuever is avaliable, takes the object as a userInfo from NSNotification and sets the get'ted object to "info".
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.maneuverNotif))
        { obj in
            if let userInfo = obj.userInfo, let info = userInfo["maneuver"] as! NMAManeuver? {
                displayManeuverImage(iconInput: info.icon)
                updateCurrentRoadName(maneuver: info)
                
                //this is handled in the didupdateposition notification
                //updateManeuverDistance(maneuver: info)
                updateManeuverRoadName(maneuver: info)
                
                //variable is stored in UserData in order to get default values, probably change later
                //print(info.coordinates?.distance(to: <#T##NMAGeoCoordinates#>))
                externalData.nextManeuverCoordinates = info.coordinates!
            }
        }
        
        //update distance to next maneuver; didupdateposition listener
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.NMAPositioningManagerDidUpdatePosition))
        { obj in
            //print("hello")
            //put .object b/c obj is a Notification.name and contains both the name of the notif and the actual object
            guard let positionManager = obj.object as AnyObject as? NMAPositioningManager else {
                return
            }
            let currentPosition = positionManager.rawPosition
            //print(currentPosition?.speed)
            let currentSpeed = (currentPosition?.speed ?? -1) as Double
            externalData.currentSpeed = currentSpeed
            let currentCoordinates = currentPosition?.coordinates
            //print(currentCoordinates.distance(to: externalData.nextManeuverCoordinates)) //need here
            let distanceDouble = currentCoordinates?.distance(to: externalData.nextManeuverCoordinates)
            var distanceDoubleText = String("default value")
            if distanceDouble != nil {
                distanceDoubleText = String("In " + String(format: "%.0f", distanceDouble!) + " meters")
            }
            
            externalData.maneuverDistance = Text(distanceDoubleText)
            //print("bye")
        }
        
    }
    
    // MARK: Functions
    //used to be "displayCurrentRoadName"
    func updateCurrentRoadName(maneuver: NMAManeuver) {
        externalData.currentRoadName = Text("Currently on: " + (maneuver.roadName! as String))
    }
    
    func updateManeuverRoadName(maneuver: NMAManeuver) {
        //call updateManeuverDistance before this to get accurate distance reading
        //let distance = String(format: "%f", externalData.maneuverDistance)
        //externalData.maneuverRoadName = Text("Turn onto: " + (maneuver.nextRoadName! as String) + " in " + distance + " meters.")
        externalData.maneuverRoadName = Text("Turn onto: " + (maneuver.nextRoadName! as String))
    }
    
    func updateManeuverDistance(maneuver: NMAManeuver) {
        //externalData.maneuverDistance = Double(maneuver.distanceToNextManeuver)
    }
    
    //switch enum for maneuvers, see https://developers.here.com/documentation/ios-premium/3.18/content/api_reference_jazzy/Enums/NMAManeuverIcon.html
    //here is configured to take a NMAManeuver.icon, or a NMAManeuverIcon object
    func displayManeuverImage(iconInput: NMAManeuverIcon) {
        switch iconInput {
        case .goStraight:
            print("go straight")
        case .uTurnRight:
            print("u turn right")
        case .uTurnLeft:
            print("u turn left")
        case .keepRight:
            print("keep right")
        case .lightRight:
            print("light right turn")
        case .quiteRight:
            externalData.maneuverImage = Image("right_arrow")
            print("normal right turn")
        case .heavyRight:
            print("heavy right")
        case .keepMiddle:
            print("keep to the left") //????
        case .keepLeft:
            print("keep to the middle lane")
        case .lightLeft:
            print("light left turn")
        case .quiteLeft:
            externalData.maneuverImage = Image("left_arrow")
            print("normal left turn")
        case .heavyLeft:
            print("heavy left turn")
        case .enterHighwayRightLane:
            print("enter highway right lane")
        case .enterHighwayLeftLane:
            print("enter highway left lane")
        case .leaveHighwayRightLane:
            print("leave highway right lane")
        case .leaveHighwayLeftLane:
            print("leave highway left lane")
        case .highwayKeepRight:
            print("highway keep right")
        case .highwayKeepLeft:
            print("highway keep left")
        case .roundabout1:
            print("roundabout exit 1")
        case .roundabout2:
            print("roundabout exit 2")
        case .roundabout3:
            print("roundabout exit 3")
        case .roundabout4:
            print("roundabout exit 4")
        case .roundabout5:
            print("roundabout exit 5")
        case .roundabout6:
            print("roundabout exit 6")
        case .roundabout7:
            print("roundabout exit 7")
        case .roundabout8:
            print("roundabout exit 8")
        case .roundabout9:
            print("roundabout exit 9")
        case .roundabout10:
            print("roundabout exit 10")
        case .roundabout11:
            print("roundabout exit 11")
        case .roundabout12:
            print("roundabout exit 12")
        case .roundabout1LH:
            print("roundabout exit 1 counter-clockwise")
        case .roundabout2LH:
            print("roundabout exit 2 counter-clockwise")
        case .roundabout3LH:
            print("roundabout exit 3 counter-clockwise")
        case .roundabout4LH:
            print("roundabout exit 4 counter-clockwise")
        case .roundabout5LH:
            print("roundabout exit 5 counter-clockwise")
        case .roundabout6LH:
            print("roundabout exit 6 counter-clockwise")
        case .roundabout7LH:
            print("roundabout exit 7 counter-clockwise")
        case .roundabout8LH:
            print("roundabout exit 8 counter-clockwise")
        case .roundabout9LH:
            print("roundabout exit 9 counter-clockwise")
        case .roundabout10LH:
            print("roundabout exit 10 counter-clockwise")
        case .roundabout11LH:
            print("roundabout exit 11 counter-clockwise")
        case .roundabout12LH:
            print("roundabout exit 12 counter-clockwise")
        case .start:
            print("starting point")
        case .end:
            print("ending point")
        case .ferry:
            print("board the ferry")
        case .passStation:
            print("pass the station")
        case .headTo:
            print("head to")
        case .changeLine:
            print("change lane")
        case .undefined:
            print("undefined")
        @unknown default:
            print("error")
        }
    }
}

struct ExternalView_Previews: PreviewProvider {
    @State static var exampleImage = Image("right_arrow")
    static var previews: some View {
        ExternalView()
            .environmentObject(UserData())
            .environmentObject(ExternalData())
        
    }
}
