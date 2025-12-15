//
//  4.swift
//  LoggingKit
//
//  Created by Denis Esie on 11.12.2025.
//

import LoggingKit

#if canImport(SwiftUI)
import SwiftUI

struct DayView: View, @MainActor Loggable {
    static let subsystem = "DayView"
    
    var body: some View {
        VStack {
            Text("Day View")
                .onTapGesture {
                    onTap()
                    #logInfo("Tapped")
                }
        }
    }
    
    func onTap() {
        #logInfo("On Tap")
    }
}

struct WeekView: View {
    init() {
        Log.defaultSubsystem = "WeekView"
    }
    
    var body: some View {
        VStack {
            Text("Day View")
                .onTapGesture {
                    #logInfo("Rendering day with index")
                }
        }
    }
}
#endif // canImport(SwiftUI)

func globalFunction() {
    #logInfo("Rendering day with index")
}
