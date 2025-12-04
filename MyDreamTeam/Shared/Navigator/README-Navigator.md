# 🧭 Navigator System

## 📖 Overview

The Navigator is a centralized navigation system for SwiftUI applications that provides a clean and consistent way to handle all navigation patterns in your iOS app. It follows the Coordinator pattern principles adapted for SwiftUI.

### 🎯 Purpose

- **Centralized Navigation**: Single source of truth for all navigation states
- **Decoupled Logic**: Separates navigation logic from views and ViewModels
- **Multiple Navigation Types**: Supports push, modal, sheet, alerts, toasts, and more
- **Type-Safe**: Uses strongly typed navigation with Page wrapper
- **Module Independence**: Each module can navigate without knowing about others

## 🏗️ Architecture

### File Structure

```
Navigator/
├── Navigator.swift                  # Main navigator implementation (Singleton)
├── NavigatorProtocol.swift         # Protocol definition
├── Components/
│   ├── Router.swift                # Base router class
│   ├── NavigatorRootView.swift     # Generic root view for navigation
│   ├── Page.swift                  # Type-safe page wrapper
│   ├── NestedSheetHost.swift       # Sheet navigation handler
│   ├── NestedFullScreenHost.swift  # Full screen modal handler
│   ├── ToastView.swift             # Toast component
│   └── CustomTabBar.swift         # Tab bar implementation
└── Configuration/
    ├── AlertConfig.swift           # Alert configuration model
    ├── ToastConfig.swift           # Toast configuration model
    ├── ConfirmationDialogConfig.swift  # Dialog configuration
    └── FullOverScreenConfig.swift  # Full screen configuration
```

## 🚀 Features

- **Push Navigation** - Navigate to new screens in the navigation stack
- **Modal Sheets** - Present views as sheets
- **Full Screen Cover** - Present full screen modals
- **Alerts** - Show system alerts with predefined styles
- **Toast Messages** - Show temporary notifications with optional actions
- **Tab Bar Navigation** - Manage tab-based navigation with badges
- **Root Replacement** - Replace the entire navigation stack

## 💻 Implementation

### 1. Setup NavigatorRootView

In your main app file or module entry point:

```swift
@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            NavigatorRootView(root: YourInitialView())
        }
    }
}
```

**Note:** Some modules like Authentication provide their own specialized root views (e.g., `AuthNavigatorRootView`) with additional functionality specific to that module.

### 2. Create Module Router

All routers must inherit from the base `Router` class. The router is injected into ViewModels, not views:

```swift
// Router class for your module
class ProductCatalogRouter: Router {

    func navigateToProductDetail(productID: Int) {
        navigator.push(to: ProductDetailBuilder.build(productID: productID))
    }

    func navigateToCheckout() {
        navigator.push(to: CheckoutBuilder.build())
    }

    func presentCart() {
        navigator.presentSheet(CartBuilder.build())
    }

    func showProductAddedToast() {
        showToastWithCloseAction(
            with: "Product added to cart",
            closeAction: { }
        )
    }
}
```

### 3. Inject Router into ViewModel

The router is injected into the ViewModel, keeping views clean:

```swift
class ProductListViewModel: ObservableObject {
    // MARK: - Properties
    private let router: ProductCatalogRouter
    private let useCase: ProductCatalogUseCaseProtocol
    @Published var products: [Product] = []
    @Published var isLoading = false

    // MARK: - Init
    init(router: ProductCatalogRouter,
         useCase: ProductCatalogUseCaseProtocol) {
        self.router = router
        self.useCase = useCase
    }

    // MARK: - Navigation Methods
    func didSelectProduct(_ product: Product) {
        router.navigateToProductDetail(productID: product.id)
    }

    func didTapCheckout() {
        router.navigateToCheckout()
    }

    func didAddProductToCart() {
        router.showProductAddedToast()
    }
}
```

### 4. Use Builder Pattern

Builders are classes that create views with all dependencies properly injected:

```swift
class ProductListBuilder {
    static func build() -> some View {
        let router = ProductCatalogRouter()
        let useCase = ProductCatalogUseCase()
        let viewModel = ProductListViewModel(
            router: router,
            useCase: useCase
        )
        return ProductListView(viewModel: viewModel)
    }
}
```

### 5. View Implementation

Views remain clean, only calling ViewModel methods:

```swift
struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel

    init(viewModel: ProductListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.products) { product in
            ProductRow(product: product)
                .onTapGesture {
                    viewModel.didSelectProduct(product)
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Checkout") {
                    viewModel.didTapCheckout()
                }
            }
        }
    }
}
```

## 🔧 Base Router Methods

The `Router` base class provides these common methods:

### Alerts
```swift
// Basic alert with info style
showAlert(title: "Title", message: "Message", action: { })

// Alert with error (requires DetailErrorProtocol)
showAlert(with: error, action: { })
```

### Toasts
```swift
// Toast with close button
showToastWithCloseAction(
    with: "Message",
    closeAction: { }
)
```

### Navigation
```swift
// Dismiss current modal/sheet
dismiss()

// Dismiss sheet specifically
dismissSheet()

// Dismiss full screen cover
dismissFullOverScreen()
```

## 📱 Tab Bar Navigation

### Setup Custom Tab Bar
```swift
// In your router
func showMainTabBar() {
    navigator.replaceRoot(to: CustomTabbar(initialTab: .home))
}
```

### Change Tab Programmatically
```swift
// Navigate to specific tab
navigator.changeTab(index: TabItem.profile.rawValue)
```

### Update Tab Badges
```swift
// Set badge count
navigator.tabBadges[.notifications] = 5

// Clear badge
navigator.tabBadges[.notifications] = nil
```

## 📋 Best Practices

1. **Always Inherit from Router** - Don't access Navigator directly
2. **Inject Router into ViewModel** - Keep navigation logic in ViewModels, not Views
3. **Use Builder Pattern** - Centralize dependency injection in Builders
4. **Keep Views Simple** - Views should only call ViewModel methods
5. **Module Independence** - Routers should not import other modules
6. **Type Safety** - Navigator automatically wraps views in Page for type safety

## ⚠️ Important Notes

- `Navigator` is a singleton (`Navigator.shared`)
- `Router` base class provides common navigation functionality
- Router is injected into ViewModel, not View
- NavigatorRootView must be initialized at app launch
- Each screen typically has its own Router, ViewModel, and Builder

## 🔗 Navigator Protocol Methods

The NavigatorProtocol provides additional methods that can be called from your router:

| Method | Description |
|--------|-------------|
| `push(to:)` | Push view onto navigation stack |
| `presentSheet(_:)` | Present view as modal sheet |
| `presentFullOverScreen(_:)` | Present full screen modal |
| `pop()` | Go back one screen |
| `popToRoot()` | Return to root view |
| `replaceRoot(to:)` | Replace entire navigation stack |
| `showAlert(alertModel:)` | Show alert with AlertModel |
| `showToast(from:)` | Show toast with ToastConfig |
| `showConfirmationDialog(from:)` | Show action sheet |
| `changeTab(index:)` | Switch to specific tab |
| `dismissToast()` | Dismiss current toast |