//
//  carprojtestingApp.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/4/22.
//

import SwiftUI
import Combine
import UIKit
import NMAKit

// MARK: AppDelegate Implementation
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // To obtain the application credentials, please register at https://developer.here.com/develop/mobile-sdks
    let credentials = (
        appId: "Kku7IlzT5sFUkiJjWplh",
        appCode: "7gjHqbyiai3l1DiGvN-lIg",
        licenseKey: "QlXByqIeXs+Brv2qoTisk4xt24zEf+Sbly2prFYdoxWXVkT+ldxXkjZhyE9ZrslmwupHYlBSpp3rgg5JD9Cria4PhONqjMlozIztJELMJDYeYGX+XtpeGF5hPh1mfhZwjOXuh6ikkWnf2yXwW17/rAMoLwEZpqyOH70t2a+X+2zE3hkArgu9SfYk+xgCkgfc+mfY8EUHrEe39AQVFIjK/gSecfERNEkEKcIifiH3EiebZ4eDxJAlBuKk1z7UwOxHPEj3Q3hjyrfWgxDjEhrfKFV9egpKbt8oSpmcZuluUxCF3WdOgsJ3sNaQ8kAunEREoATSxNdK0AY38e8726BGd/cGAapY8j8J7rnmYERhPwcsI0fBrC8lx4oHE4ClkllLDU8bzL4oaR7Sx9igCnwT+9FrecLKT4PoxelBm85WV4pZocblQUoXR9ENJRtrn8Y2XBOycl7ZyWloIqxmgTDfts5g8eSF9gEhVSMhf2kLRs1z/6yCVQI0KWe3LaaK+puYSXwmnVFEWyLrVd+uuQZNY9/PpucG9IJLlUgF5jXovIOBxs7E/JK7W5zIsaBiYL687Qh5oTuv+juk7xPRos4orH4TdrWIrYfr2j04cZY9e5JHCjbwCXwtPrBSQyrNKUIo6t9Zy+5IgggeI78hq5VsE8OETlDIrgDgus+zG0rbOYM="
    )

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        NMAApplicationContext.setAppId(credentials.appId, appCode: credentials.appCode, licenseKey: credentials.licenseKey)
        return true
    }
}

//MARK: Main App
@main
struct carprojtestingApp: App {
    
    //AppDelegate Inclusion
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject var userData = UserData()
    @ObservedObject var externalData = ExternalData()
    @State var additionalWindows: [UIWindow] = []
    
    // MARK: Notification Centers for I/O
    private var screenDidConnectPublisher: AnyPublisher<UIScreen, Never> {
        NotificationCenter.default
            .publisher(for: UIScreen.didConnectNotification)
            .compactMap{ $0.object as? UIScreen }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private var screenDidDisconnectPublisher: AnyPublisher<UIScreen, Never> {
            NotificationCenter.default
                .publisher(for: UIScreen.didDisconnectNotification)
                .compactMap { $0.object as? UIScreen }
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }
    
    // MARK: Main Body
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
                .environmentObject(externalData)
                .onReceive(
                    screenDidConnectPublisher,
                    perform: screenDidConnect
                )
                .onReceive(
                    screenDidDisconnectPublisher,
                    perform: screenDidDisconnect
                )
        }
    }
    
    // MARK: Notification Reactions
    private func screenDidConnect(_ screen: UIScreen) {
        let window = UIWindow(frame: screen.bounds)
        
        //nab the first elem on shared screens, this is the incoming screen, and set it as the window's scene
        window.windowScene = UIApplication.shared.connectedScenes
            .first { ($0 as? UIWindowScene)?.screen == screen }
            as? UIWindowScene
        
        //create new view (this one is "ExternalView"), make controller and use that view as the root view controller
        //basically, tell the new window (connected projector/screen) to mimic the ExternalView view
        let view = ExternalView()
            .environmentObject(userData)
            .environmentObject(externalData)
        let controller = UIHostingController(rootView: view)
        window.rootViewController = controller
        window.isHidden = false
        additionalWindows.append(window) //must store reference to window to prevent deallocation of memory
        
        userData.isShowingOnExternalDisplay = true
    }
    
    private func screenDidDisconnect(_ screen: UIScreen) {
        additionalWindows.removeAll { $0.screen == screen } //remove window from reference in array to deallocate memory
        userData.isShowingOnExternalDisplay = false
    }
}
