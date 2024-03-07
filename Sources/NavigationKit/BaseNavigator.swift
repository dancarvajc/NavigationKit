import SwiftUI
import UIKit

open class BaseNavigator<Destination: Equatable>: NSObject, UIAdaptivePresentationControllerDelegate, UINavigationControllerDelegate {
    public private(set) var routes: [Destination] = [] {
        didSet {
            print("--- routes: \(routes)")
        }
    }

    public private(set) var navigationControllers: [UINavigationController] = [UINavigationController()]

    override public init() {
        super.init()
        navigationControllers[0].delegate = self
    }

    // MARK: - UIAdaptivePresentationControllerDelegate

    public func presentationControllerDidDismiss(_: UIPresentationController) {
        guard let navController = navigationControllers.last else { return }
        routes.removeLast(navController.viewControllers.count)
        navigationControllers.removeLast()
    }

    // MARK: - UINavigationControllerDelegate

    public func navigationController(_ navigationController: UINavigationController, didShow _: UIViewController, animated _: Bool) {
        guard let fromViewController =
            navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(fromViewController)
        else { return }
        guard let navIndex = navigationControllers.firstIndex(where: { $0 == navigationController }) else { return }
        var viewControllerCount = 0
        navigationControllers[..<navIndex].forEach { nav in
            viewControllerCount += nav.viewControllers.count
        }
        guard routes.count - viewControllerCount > navigationController.viewControllers.count else { return }
        routes.removeLast()
    }

    open func start(_ destination: Destination) {
        replaceStack([destination])
    }

    open func mapDestinationToView(_: Destination) -> any View {
        fatalError("mapDestinationToView(_:) has not been implemented")
    }
}

// MARK: - Navigation methods

public extension BaseNavigator {
    func push(_ destination: Destination) {
        let view = mapDestinationToView(destination)
        let viewController = viewToViewController(view)
        navigationControllers.last?.pushViewController(viewController, animated: true)
        routes.append(destination)
    }

    func present(_ destination: Destination, inNavController: Bool = true, fullScreen: Bool = false) {
        let view = mapDestinationToView(destination)
        let viewController = viewToViewController(view)

        if inNavController {
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = fullScreen ? .fullScreen : .automatic
            navController.presentationController?.delegate = self
            navigationControllers.last?.present(navController, animated: true) {
                navController.delegate = self
            }
            navigationControllers.append(navController)
        } else {
            viewController.modalPresentationStyle = fullScreen ? .fullScreen : .automatic
            navigationControllers.last?.present(viewController, animated: true)
        }
        routes.append(destination)
    }

    func replaceStack(_ destination: [Destination], animated: Bool = false) {
        guard !destination.isEmpty else { return }
        if navigationControllers.count > 1 {
            navigationControllers.removeSubrange(1...)
        }
        let viewControllers = destination.map { destination in
            let view = mapDestinationToView(destination)
            return viewToViewController(view)
        }
        navigationControllers.first?.setViewControllers(viewControllers, animated: animated)
        navigationControllers[0].dismiss(animated: animated)
        routes = destination
    }

    func pop(animated: Bool = true) {
        guard routes.count > 1 else { return }
        navigationControllers.last?.popViewController(animated: animated)
        routes.removeLast()
    }

    func popToRoot(animated: Bool = true) {
        guard !routes.isEmpty else { return }
        popTo(routes[0], animated: animated)
    }

    func popToRootInCurrentNav() {
        guard let viewControllersPopped = navigationControllers.last?.popToRootViewController(animated: true) else { return }
        routes.removeLast(viewControllersPopped.count)
    }

    func popTo(_ destination: Destination, animated: Bool = true) {
        guard let destIndex = routes.lastIndex(of: destination) else { return }
        var accumulatedIndex = 0
        for (navIndex, navController) in navigationControllers.enumerated() {
            let nextAccumulatedIndex = accumulatedIndex + navController.viewControllers.count
            if destIndex <= nextAccumulatedIndex - 1 {
                let controllerIndex = destIndex - accumulatedIndex
                if let viewControllerToPop = navController.viewControllers[safe: controllerIndex] {
                    let viewControllersPopped = navController.popToViewController(viewControllerToPop, animated: animated)
                    guard navIndex != navigationControllers.count - 1 else {
                        navController.dismiss(animated: animated)
                        routes.removeLast((viewControllersPopped?.count ?? 0) + 1)
                        return
                    }
                    navigationControllers[navIndex].dismiss(animated: animated)
                    navigationControllers[(navIndex + 1)...].forEach {
                        routes.removeLast($0.viewControllers.count)
                    }
                    navigationControllers.removeSubrange((navIndex + 1)...)
                    routes.removeLast(viewControllersPopped?.count ?? 0)
                }
                break
            }
            accumulatedIndex = nextAccumulatedIndex
        }
    }
}

private extension BaseNavigator {
    func viewToViewController(_ view: some View) -> UIViewController {
        return UIHostingController(rootView: view)
    }
}
