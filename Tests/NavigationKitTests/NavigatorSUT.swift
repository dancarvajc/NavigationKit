@testable import NavigationKit
import SwiftUI
import XCTest

class NavigatorSUT: BaseNavigator<AppDestination> {
    override func mapDestinationToView(_: AppDestination) -> any View {
        Text(UUID().uuidString)
    }
}

enum AppDestination: Equatable {
    case onboarding
    case calibration
    case postCalibration
    case postCalibrationAlert
    case home
    case library
    case messaging
    case configuration
    case bookImporter
    case bookReOrder
    case messageReorder
}
