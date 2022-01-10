//
//  ContentView.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/4/22.
//
//command + option + p to refresh preview

import SwiftUI
import NMAKit

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Destination")) {
                        TextField("Text", text: $userData.endingDestination)
                    }
                }
                
                //RouteCalcsView()
                
                //RouteCalcButton()
                //    .environmentObject(userData)
                NavigationLink(destination: ExternalView()) {
                    Text("Start Navigation")
                }
            }
            .navigationTitle("HUD Testingg")
            .preferredColorScheme(.dark) //use preferredcolorscheme, not environment something
        }
        //end NavigationView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
