# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**MyDreamTeam** is an iOS application built with SwiftUI that follows Clean Architecture + MVVM patterns. The codebase features a sophisticated custom Navigator system for centralized navigation management, protocol-based dependency injection, and clear separation of concerns across presentation, domain, and data layers.

## Building and Running

### Open Project in Xcode
```bash
open MyDreamTeam.xcodeproj
```

### Build from Command Line
```bash
xcodebuild -scheme MyDreamTeam -configuration Debug
```

### Run Simulator
```bash
xcodebuild -scheme MyDreamTeam -configuration Debug -destination 'generic/platform=iOS Simulator'
```

### Run Tests
```bash
xcodebuild test -scheme MyDreamTeam
```

### Run Single Test Class
```bash
xcodebuild test -scheme MyDreamTeam -only-testing MyDreamTeamTests/ClassName
```

### Run Single Test Method
```bash
xcodebuild test -scheme MyDreamTeam -only-testing MyDreamTeamTests/ClassName/testMethodName
```

## Architecture Overview

The project is organized into four main layers:

### 1. **Presentation Layer** (`/MyDreamTeam/Presentation`)
- **Views**: SwiftUI components (presentation-only, no business logic)
- **ViewModels**: `@ObservableObject` with `@Published` properties
- **Routers**: Module-specific classes extending `Router` base class
- **Builders**: Factory classes for dependency injection and view composition

**Key Pattern**: Router injected into ViewModel, NOT into View. Views only call ViewModel methods.

**Example Screen Structure**:
```
Presentation/Screens/Establishment/
├── EstablishmentView.swift       # UI layer
├── EstablishmentViewModel.swift  # Logic & @Published state
├── EstablishmentRouter.swift     # Navigation (extends Router)
└── EstablishmentBuilder.swift    # Dependency graph factory
```

### 2. **Domain Layer** (`/MyDreamTeam/Domain`)
- **Entities**: Core business models (Establishment, City)
- **UseCases**: Business logic orchestrators (EstablishmentUseCase)
- **Repositories**: Protocol definitions for data access abstraction

**Key Pattern**: Protocol-based for testability. Domain knows nothing about external frameworks.

### 3. **Data Layer** (`/MyDreamTeam/Data`)
- **DataSources**: API communication via TripleA networking library
- **Repositories**: Implementation of domain protocols, bridges data sources to domain
- **DTOs**: Data Transfer Objects (API response models) with mappers to domain entities

**Key Pattern**: DTOs map to domain entities at repository level. Error handling transforms at this layer.

### 4. **Shared/Infrastructure** (`/MyDreamTeam/Shared`)
Critical cross-cutting systems:

#### Navigator System (Custom Navigation)
The app uses a **centralized, singleton Navigator** instead of SwiftUI's default NavigationStack/NavigationLink:

**Location**: `/MyDreamTeam/Shared/Navigator`

**Core Components**:
- `Navigator.swift`: Main Observable singleton managing all navigation state
- `NavigatorProtocol.swift`: Three-protocol system (NavigatorProtocol, NavigatorManagerProtocol, ModalPresenterProtocol)
- `Router.swift`: Base class for all module-specific routers (provides common methods like `showAlert`, `showToast`, `dismiss`)
- `NavigatorRootView.swift`: Root container handling all navigation states (stacks, sheets, modals, alerts, toasts)
- `Page.swift`: Type-safe view wrapper (UUID-based identification)
- `NestedSheetHost.swift` & `NestedFullScreenHost.swift`: Handle cascading modals
- `CustomTabBar.swift`: Tab bar with badge support

**Navigation Types Supported**:
- Push navigation (stack-based)
- Modal sheets (can nest multiple levels)
- Full-screen modals (can nest multiple levels)
- System alerts with custom styling
- Toast notifications with actions
- Confirmation dialogs
- Tab switching with badge updates

**Usage Pattern**:
```swift
// In Router subclass
class ProductRouter: Router {
    func navigateToDetail(id: Int) {
        navigator.push(to: DetailBuilder.build(id: id))
    }

    func showCart() {
        navigator.presentSheet(CartBuilder.build())
    }

    func showError(_ error: AppError) {
        showAlert(with: error, action: { /* handle */ })
    }
}
```

#### Error Handling (`/MyDreamTeam/Shared/Error`)
- `AppError.swift`: Custom enum with DetailErrorProtocol for structured error handling
- `ErrorHandlerManager.swift`: Transforms TripleA network/auth errors to AppError
- Error types: generalError, noInternet, badCredentials, customError, inputError

**Flow**: NetworkError → ErrorHandlerManager → AppError → Router.showAlert()

#### Configuration (`/MyDreamTeam/Shared/Configuration`)
- `Config.swift`: App-wide constants (baseURL, apiKeys, appName)
- `ConfigTripleA.swift`: TripleA networking setup with OAuth configuration and token management

#### DeeplinkManager (`/MyDreamTeam/Shared/DeeplinkManager`)
Full MVVM implementation for URL scheme routing. Follows same modular pattern as features with ViewModel, Router, Builder.

#### Shared Domain (`/MyDreamTeam/Shared/Domain`)
- `ServiceType.swift`: Enum for delivery/takeaway/reservation modes
- `Coordinates.swift`: Location data
- `Address.swift`: Address modeling

#### Shared UI Components (`/MyDreamTeam/Presentation/Shared/Components`)
Reusable SwiftUI components used across multiple screens:
- `InfoRow.swift`: Generic row component for displaying label-value pairs (used in PlayerDetail, TeamDetail)

### 5. **Dependency Injection** (`/MyDreamTeam/DI/Containers`)
- Each feature has a Container class (e.g., `EstablishmentSelectionContainer`)
- Containers expose factory methods like `makeUseCase()`, `buildView()`
- Entire dependency graph constructed in one place per feature

## Key Design Patterns

### Builder Pattern (Dependency Injection)
Every screen has a builder that constructs the entire view hierarchy with all dependencies:

```swift
class EstablishmentBuilder {
    static func build(with serviceType: ServiceType) -> some View {
        let router = EstablishmentRouter()
        let useCase = EstablishmentSelectionContainer.shared.makeUseCase()
        let viewModel = EstablishmentViewModel(router: router, useCase: useCase)
        return EstablishmentView(viewModel: viewModel)
    }
}
```

### MVVM with Injected Router
- Views: State-driven, no business logic, call ViewModel methods
- ViewModels: @ObservableObject with @Published properties, business logic, routing logic
- Router: Injected into ViewModel, encapsulates navigation calls to Navigator

```swift
// ViewModel
class EstablishmentViewModel: ObservableObject {
    @Published var establishments: [Establishment] = []
    private let router: EstablishmentRouter

    func didSelectEstablishment(_ establishment: Establishment) {
        router.navigateToDetail(id: establishment.id)
    }
}

// View
struct EstablishmentView: View {
    @StateObject var viewModel: EstablishmentViewModel

    var body: some View {
        List(viewModel.establishments) { item in
            Text(item.name).onTapGesture {
                viewModel.didSelectEstablishment(item)
            }
        }
    }
}
```

### Repository Pattern
- DataSource: API communication only
- Repository: Implements domain protocol, calls DataSource, maps DTOs to entities, handles errors
- UseCase: Receives protocol, doesn't know about concrete repository

### UseCase Pattern
Business logic orchestration with service-type awareness. UseCases coordinate repositories and apply domain rules (e.g., including coordinates for delivery service).

### Type-Safe Navigation
`Page` struct wraps views with UUID for strongly-typed navigation destinations. No stringly-typed navigation.

## Common Development Tasks

### Creating a New Feature Screen

1. **Create the Layer Stack** (follow the pattern: Presentation → Domain → Data):
   ```
   Presentation/Screens/FeatureName/
   ├── FeatureNameView.swift       # UI only
   ├── FeatureNameViewModel.swift  # @ObservableObject, @Published, logic
   ├── FeatureNameRouter.swift     # Extends Router, has navigate* methods
   └── FeatureNameBuilder.swift    # Creates view with dependencies
   ```

2. **Define Domain Layer**:
   ```
   Domain/UseCases/
   └── FeatureNameUseCase.swift (+ Protocol)
   Domain/Repositories/
   └── FeatureNameRepositoryProtocol.swift
   ```

3. **Implement Data Layer**:
   ```
   Data/DataSources/FeatureName/Remote/
   └── FeatureNameRemoteDataSource.swift
   Data/Repositories/
   └── FeatureNameRepository.swift
   Data/DTOs/
   └── FeatureNameDTO.swift
   ```

4. **Create DI Container**:
   ```
   DI/Containers/
   └── FeatureNameContainer.swift
   ```

5. **Inject Router into ViewModel**:
   ```swift
   init(router: FeatureNameRouter, useCase: FeatureNameUseCaseProtocol)
   ```

### Navigating Between Screens

Always use Router subclass methods in ViewModel:

```swift
// In Router subclass
func navigateToDetail(id: Int) {
    navigator.push(to: DetailBuilder.build(id: id))
}

// In ViewModel
viewModel.didSelectItem() // calls router.navigateToDetail(id)
```

### Showing Alerts/Errors

Use Router base class methods:

```swift
// Basic alert
showAlert(title: "Title", message: "Message", action: { })

// Error alert (auto-formats AppError)
showAlert(with: appError, action: { })

// Toast
showToastWithCloseAction(with: "Message", closeAction: { })
```

### Working with Async Data Loading

ViewModels use `async/await` with `@MainActor`:

```swift
@MainActor
func loadData() {
    Task {
        do {
            let data = try await useCase.fetchData()
            self.items = data
        } catch let error as AppError {
            router.showAlert(with: error, action: { })
        }
    }
}
```

## Important Architecture Rules

1. **Router in ViewModel, NOT in View**: Navigation logic belongs in ViewModels, routers are never passed to views.

2. **Views are Dumb**: Views only display state from ViewModel and call ViewModel methods on user interaction.

3. **Protocol-First Design**: All repositories, use cases, and data sources are protocol-based for testability.

4. **DTO Mapping at Repository Layer**: API models (DTOs) are converted to domain entities only in the repository.

5. **Error Transformation**: Errors are transformed from TripleA → AppError at repository layer.

6. **Use Builders for DI**: Never instantiate ViewModels directly in views. Always use Builders.

7. **Navigator is Singleton**: All navigation goes through `Navigator.shared` via Router subclass methods.

8. **Module Independence**: Module routers should not import other modules. Navigate via generic builders.

9. **Type-Safe Navigation**: Use Page-wrapped views for navigation. Never use string-based navigation.

10. **ServiceType Awareness**: Data layer methods may require ServiceType parameter. UseCases handle this and pass conditionally (e.g., coordinates for delivery).

## Testing Strategy

- Test ViewModels by mocking Router and UseCase
- Test UseCases by mocking Repository
- Test Repositories by mocking DataSource
- Test DataSources with actual network calls or mock URLSession
- Protocol-based design enables easy mocking throughout

## Networking

The app uses **TripleA** networking library configured in `/MyDreamTeam/Shared/Configuration/ConfigTripleA.swift`:

- OAuth authentication with automatic token refresh
- Base URL and endpoints configured in Config.swift
- Network errors caught and transformed to AppError
- Language headers and other standard headers configured

## File Organization Best Practices

- **One feature, one folder**: All screens in Presentation/Screens/FeatureName
- **Parallel layer structure**: Mirror folder structure across Presentation, Domain, Data
- **Builders with screens**: Builders live with the View they build (same folder)
- **Routers with screens**: Routers live with ViewModels they're injected into
- **Shared infrastructure centralized**: Navigation, Config, Error handling in Shared
- **DI containers in one place**: All containers in DI/Containers for discoverability

## Notes

- Navigator system replaces SwiftUI's default NavigationStack for centralized control
- CustomTabBar supports badges via `navigator.tabBadges` dictionary
- Multiple levels of sheets/modals can be nested (NestedSheetHost, NestedFullScreenHost)
- All screens use builder pattern for consistent dependency injection
- Protocol-based design throughout enables testing and modular development
