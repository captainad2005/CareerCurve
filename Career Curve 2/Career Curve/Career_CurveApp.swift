//  Created by Aradhya Dubey and Ritesh Yadav on 02/01/25.
//

import SwiftUI

@main
struct Career_CurveApp: App {
    @StateObject private var viewModel = ProspectViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(viewModel)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .dynamicTypeSize(.large)
                .environment(\.sizeCategory, ContentSizeCategory(fontSize: fontSize))
        }
    }
}

private extension ContentSizeCategory {
    init(fontSize: Double) {
        switch fontSize {
        case ...0.9:
            self = .small
        case 0.9..<1.1:
            self = .medium
        case 1.1..<1.3:
            self = .large
        default:
            self = .extraLarge
        }
    }
}
