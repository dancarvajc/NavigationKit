import UIKit

class HideableStatusBarNavController: UINavigationController {
    var isStatusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var prefersStatusBarHidden: Bool {
        isStatusBarHidden
    }
}
