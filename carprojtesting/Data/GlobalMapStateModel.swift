//
//  GlobalMapStateModel.swift
//  carprojtesting
//
//  Created by Ethan Chen on 1/5/22.
//

import Foundation

class GlobalMapStateModel : ObservableObject {
    @Published var zoom: Float = 0
    @Published var tilt: Float = 0

    //Add another settigns for observation here
}
