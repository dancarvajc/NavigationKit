import Combine
import SwiftUI
import UIKit

public protocol NavigatorProtocol<Destination> {
    associatedtype Destination: Equatable

    var routes: [Destination] { get }
    var routesPublisher: PassthroughSubject<[Destination], Never> { get }
    var navigationControllers: [UINavigationController] { get }
    var lastVCisPresented: Bool { get }

    func start(_ destination: Destination)
    func mapDestinationToView(_ destination: Destination) -> any View
    func push(_ destination: Destination, animated: Bool)
    func present(_ destination: Destination, fullScreen: Bool, animated: Bool, hideStatusBar: Bool)
    func replaceStack(_ destinations: [Destination], animated: Bool)
    func dismiss(animated: Bool)
    func dismissAll()
    func pop(animated: Bool)
    func popOrDismiss(animated: Bool)
    func popToRoot(animated: Bool)
    func popToRootInCurrentNav(animated: Bool)
    func popTo(_ destination: Destination, animated: Bool)
}
