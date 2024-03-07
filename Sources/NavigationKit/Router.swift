//
//  SwiftUIView.swift
//
//
//  Created by Daniel Carvajal on 06-03-24.
//

import SwiftUI

public struct Router<Destination: Equatable>: View {
    private let navigator: BaseNavigator<Destination>

    public init(navigator: BaseNavigator<Destination>) {
        self.navigator = navigator
    }

    public var body: some View {
        NavigationControllerView(navigationController: navigator.navigationControllers[0])
    }
}

struct NavigationControllerView: UIViewControllerRepresentable {
    let navigationController: UINavigationController

    func makeUIViewController(context _: Context) -> UINavigationController {
        return navigationController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}

// #Preview {
//    Router()
// }
