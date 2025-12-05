import Foundation
import SwiftUI
import Combine

final class AppState: ObservableObject {
    // TODO: Implement session and system state management
    @Published var hasCompletedOnboarding: Bool = false
}
