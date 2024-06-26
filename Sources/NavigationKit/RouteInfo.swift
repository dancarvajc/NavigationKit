import UIKit

struct RouteInfo<Destination> {
    let screen: Destination
    let index: Int
    let viewController: UIViewController
    let navController: UINavigationController
}
