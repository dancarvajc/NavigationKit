import Combine
import SwiftUI
import UIKit

// TODO: Fix title flickkering when push a view. Se puede pasar el titulo por parametro al VC cuando hacemos push. Verificar otra forma.

open class BaseNavigator<Destination: Equatable>: NSObject, NavigatorProtocol, UIAdaptivePresentationControllerDelegate, UINavigationControllerDelegate {
    public private(set) var routes: [Destination] = [] {
        didSet {
            print("---- Current route: \(routes)")
            routesPublisher.send(routes)
        }
    }

    public private(set) var routesPublisher = PassthroughSubject<[Destination], Never>()
    public private(set) var navigationControllers: [UINavigationController] = [UINavigationController()]
    public var lastVCisPresented: Bool {
        return navigationControllers.last?.viewControllers.last?.presentingViewController != nil
    }

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

    func present(_ destination: Destination, fullScreen: Bool = false) {
        let view = mapDestinationToView(destination)
        let viewController = viewToViewController(view)

        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = fullScreen ? .fullScreen : .automatic
        navController.presentationController?.delegate = self
        navigationControllers.last?.present(navController, animated: true) {
            navController.delegate = self
        }
        navigationControllers.append(navController)
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
        navigationControllers.first?.dismiss(animated: animated)
        routes = destination
    }

    func dismiss(animated: Bool = true) {
        navigationControllers.last?.dismiss(animated: animated)
        routes.removeLast()
        navigationControllers.removeLast()
    }

    func pop(animated: Bool = true) {
        guard routes.count > 1 else { return }
        navigationControllers.last?.popViewController(animated: animated)
        routes.removeLast()
    }

    func popOrDismiss(animated: Bool = true) {
        if let navigationController = navigationControllers.last, navigationController.viewControllers.count > 1 {
            pop()
        } else {
            guard lastVCisPresented else { return }
            dismiss(animated: animated)
        }
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
                    routes.removeLast(viewControllersPopped?.count ?? 0)
                    guard (navIndex + 1) < navigationControllers.endIndex else {
                        navController.dismiss(animated: animated)
                        return
                    }
                    navigationControllers[(navIndex + 1)...].forEach {
                        routes.removeLast($0.viewControllers.count)
                    }
                    navigationControllers.removeSubrange((navIndex + 1)...)
                    navController.dismiss(animated: animated)
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
