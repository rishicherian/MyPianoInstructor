import SwiftUI
import FirebaseCore

@main
struct MyPianoInstructorApp: App {
    init() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("✅ DEBUG: GoogleService-Info.plist found at: \(path)")
            
            FirebaseApp.configure()
            print("✅ DEBUG: Firebase Configured Successfully!")
        } else {
            print("❌ CRITICAL ERROR: GoogleService-Info.plist NOT FOUND in Bundle!")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
