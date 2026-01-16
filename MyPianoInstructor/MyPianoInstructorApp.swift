import SwiftUI
import FirebaseCore

@main
struct MyPianoInstructorApp: App {
    init() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("Warning: GoogleService-Info.plist not found.")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
