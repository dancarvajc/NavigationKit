@testable import NavigationKit
import XCTest

final class NavigationKitTests: XCTestCase {
    var sut: NavigatorSUT!

    override func setUp() {
        super.setUp()
        sut = NavigatorSUT()
        sut.start(.home)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDismissNothingWhenOnlyPush() {
        let nextRoutes: [AppDestination] = [.library, .messageReorder, .messaging]
        let expectedRoutes: [AppDestination] = [.home, .library, .messageReorder, .messaging]
        nextRoutes.forEach { route in
            sut.push(route, animated: false)
        }
        sut.dismiss()
        sut.dismissAll()
        XCTAssertEqual(sut.routes.count, expectedRoutes.count)
        XCTAssertEqual(sut.navigationControllers.count, 1)
        XCTAssertEqual(sut.navigationControllers[0].viewControllers.count, expectedRoutes.count)
    }

    func testPopToSpecificScreenOnlyPush() {
        let nextRoutes: [AppDestination] = [.library, .messageReorder, .messaging]
        let expectedRoutes: [AppDestination] = [.home, .library]
        for nextRoute in nextRoutes {
            sut.push(nextRoute, animated: false)
        }
        sut.popTo(.library)
        XCTAssertEqual(sut.routes.count, expectedRoutes.count)
        XCTAssertEqual(sut.routes.last, expectedRoutes.last)
        XCTAssertEqual(sut.navigationControllers[0].viewControllers.count, expectedRoutes.count)
    }

    func testPopToSpecificScreenOnlyPresents() {
        let nextRoutes: [AppDestination] = [.library, .messageReorder, .messaging, .configuration]
        let expectedRoutes: [AppDestination] = [.home, .library]
        for nextRoute in nextRoutes {
            sut.present(nextRoute, animated: false)
        }
        sut.popTo(.library)
        XCTAssertEqual(sut.routes.count, expectedRoutes.count)
        XCTAssertEqual(sut.routes.last, expectedRoutes.last)
        XCTAssertEqual(sut.navigationControllers.count, expectedRoutes.count)
        for i in 0 ..< expectedRoutes.count {
            XCTAssertEqual(sut.navigationControllers[i].viewControllers.count, 1)
        }
    }

    func testPopToSpecificScreenPushAndPresents() {
        let expectedRoutes: [AppDestination] = [.home, .library, .messageReorder, .messaging, .configuration, .calibration]
        sut.present(.library, animated: false)
        sut.push(.messageReorder, animated: false)
        sut.push(.messaging, animated: false)
        sut.push(.configuration, animated: false)
        sut.present(.calibration, animated: false)
        sut.push(.messageReorder, animated: false)
        sut.push(.messaging, animated: false)
        sut.present(.postCalibration, animated: false)
        sut.popTo(.calibration)
        XCTAssertEqual(sut.routes.count, expectedRoutes.count)
        XCTAssertEqual(sut.routes.last, expectedRoutes.last)
        XCTAssertEqual(sut.navigationControllers.count, 3)
        XCTAssertEqual(sut.navigationControllers[0].viewControllers.count, 1)
        XCTAssertEqual(sut.navigationControllers[1].viewControllers.count, 4)
        XCTAssertEqual(sut.navigationControllers[2].viewControllers.count, 1)
    }

    func testPopToRoot() {
        let nextRoutes: [AppDestination] = [.library, .messageReorder, .messaging]
        let expectedRoutes: [AppDestination] = [.home]
        for nextRoute in nextRoutes {
            sut.push(nextRoute, animated: false)
        }
        sut.popToRoot()
        XCTAssertEqual(sut.routes.count, expectedRoutes.count)
        XCTAssertEqual(sut.routes.last, expectedRoutes.last)
        XCTAssertEqual(sut.navigationControllers.count, 1)
        XCTAssertEqual(sut.navigationControllers[0].viewControllers.count, expectedRoutes.count)
    }

    func testPopToRootInCurrentNavController() {
        let expectedRoutes: [AppDestination] = [.home, .library]
        sut.present(.library, animated: false)
        sut.push(.messageReorder, animated: false)
        sut.push(.messaging, animated: false)
        sut.push(.configuration, animated: false)
        sut.popToRootInCurrentNav()
        XCTAssertEqual(sut.routes.count, expectedRoutes.count)
        XCTAssertEqual(sut.routes.last, expectedRoutes.last)
        XCTAssertEqual(sut.navigationControllers.count, 2)
        XCTAssertEqual(sut.navigationControllers[0].viewControllers.count, 1)
        XCTAssertEqual(sut.navigationControllers[1].viewControllers.count, 1)
    }
}
