
# NavigationKit for SwiftUI

Yes! Another SwiftUI navigation library to try and improve the navigation experience. Don't get me wrong, the standard navigation in SwiftUI works, but sometimes it can be a little tricky. This library aims to simplify navigation and provide additional possibilities easily.

It is highly inspired by other greats community-made packages like [Coordinator](https://github.com/canopas/UIPilot) and [UIPilot](https://github.com/canopas/UIPilot).

## Features

- Define and manage navigation routes.
- Perform various navigation actions such as push, present, dismiss, pop, and more.
- Pop to anywhere in your stack independently if you did a push or present.

## Requirements

- iOS 13.0+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/dancarvajc/NavigationKit.git", from: "1.0.0")
]
```

## Usage

### 1) Define Destinations

Define your destinations conforming to `Equatable`:

```swift
enum MyDestination: Equatable {
    case home
    case detail(id: Int)
    case settings
}
```

### 2) Subclass BaseNavigator

You can create a singleton to have a single access point to manage the navigation. Next, you have to override `mapDestinationToView(_)`, which will define the views corresponding to your destinations (`MyDestination`):

```swift
class Navigator: BaseNavigator<MyDestination> {
    static let shared = Navigator(root: .home)

    private init(root: AppDestination) {
        super.init()
        start(root) // Initialize your root view
    }

    override func mapDestinationToView(_ screen: MyDestination) -> any View {
        switch screen {
        case .home:
            HomeView()
        case .detail(let id):
            DetailView(elementID: id)
        case .settings:
				 SettingsView()
    		}
    }
}

```

### 3) Set root view

In your app's entry point, set the first view to `Router`:

```swift
@main
struct MySuperApp: App {
   var body: some Scene {
        WindowGroup {
          	Router(navigator: Navigator.shared)
        }
}
```



### 4) Navigate to your destination

Now you can simply call your `Navigator` class from anywhere you need:

```swift
// Example 1
Button("Go to Settings") {
  Navigator.shared.push(.settings)
}
}
// Example 2
Button("Go to DetailView") {
  Navigator.shared.present(.detail(id: 123), fullScreen: true, hideStatusBar: true)
}

// Example 3
// Current navigation stack: [.home, .details(id: 1), .details(id: 2), .settings]
Button("Back to Home") {
  Navigator.shared.popTo(.home)
}
// After navigation stack: [.home]
```



## License

This project is licensed under the MIT License.

For any issues, please let me know. 
