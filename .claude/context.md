# MyDreamTeam - Claude Code Context & Quick Start

**Last Updated**: 2025-12-01
**Project**: iOS Fantasy Football Application (MyDreamTeam)
**Architecture**: Clean Architecture + MVVM + Custom Navigator
**Language**: Swift / SwiftUI

---

## Quick Reference

### Project Structure
```
MyDreamTeam/
├── Presentation/          # SwiftUI Views, ViewModels, Routers, Builders
├── Domain/               # Entities, UseCases, Repository Protocols
├── Data/                 # DataSources, Repositories, DTOs
├── Shared/               # Configuration, Navigation, Error Handling
├── DI/                   # Dependency Injection Containers
└── .claude/              # Claude Code configuration
```

### Build Commands
```bash
# Open in Xcode
open MyDreamTeam.xcodeproj

# Build for simulator
xcodebuild -scheme MyDreamTeam -configuration Debug -destination 'generic/platform=iOS Simulator'

# Run tests
xcodebuild test -scheme MyDreamTeam
```

---

## Architecture Quick Primer

### 4-Layer Architecture
1. **Presentation**: Views, ViewModels (@ObservableObject), Routers, Builders
2. **Domain**: Entities, UseCases, Repository Protocols (no external dependencies)
3. **Data**: DataSources (API/Firestore), Repositories (implementation), DTOs
4. **Shared**: Navigator, Error handling, Configuration, Infrastructure

### Key Patterns
- **Router Injection**: Routers injected into ViewModels (NOT Views)
- **Protocol-Based**: All repositories/datasources/usecases use protocols
- **DTO Mapping**: DTOs map to entities at repository layer
- **Builder Pattern**: Each screen has a builder for DI
- **Custom Navigator**: Centralized navigation management (not SwiftUI NavigationStack)

### Example Screen Structure
```swift
// View (UI only, no logic)
struct PlayerSelectionView: View {
    @StateObject var viewModel: PlayerSelectionViewModel
    // ...
}

// ViewModel (logic, @Published state)
class PlayerSelectionViewModel: ObservableObject {
    @Published var players: [PlayerEntity] = []
    private let router: PlayerSelectionRouter
    // ...
}

// Router (navigation)
class PlayerSelectionRouter: Router {
    func navigateToDetail(id: String) {
        navigator.push(to: PlayerDetailBuilder.build(id: id))
    }
}

// Builder (DI)
class PlayerSelectionBuilder {
    static func build() -> some View {
        let router = PlayerSelectionRouter()
        let useCase = PlayerContainer.shared.makeUseCase()
        let viewModel = PlayerSelectionViewModel(router: router, useCase: useCase)
        return PlayerSelectionView(viewModel: viewModel)
    }
}
```

---

## Current Status

### Features Implemented ✅
- Teams management (CRUD operations)
- Players management with full statistics
- Fantasy Squad creation and management
- League system with member management
- Player selection UI with filters and search
- Seed data system for testing
- Debug menu for development

### Known Issues & PRs
See `PR_VALIDATION_REPORT.md` for detailed compilation error report.

**Current Build Status**: ❌ 25 compilation errors (as of 2025-12-01)
- 19x `AppError.generalError(message:)` - incorrect parameters
- 2x `ErrorHandlerManagerProtocol` - undefined protocol
- 4x Immutable property assignments in `setCaptain()` method

**Estimated Fix Time**: 20-30 minutes

---

## Data Layer Details

### Firebase Structure
```
firestore/
├── leagues/
│   ├── {leagueId}/
│   │   ├── members/{userId}/
│   │   └── ...
├── fantasySquads/
│   ├── {squadId}/
│   │   └── transfers/
├── teams/
│   └── {teamId}/
└── players/
    └── {playerId}/
```

### DTOs & Mappers
- `FirebaseTeamDTO` ↔ `TeamEntity`
- `FirebasePlayerDTO` ↔ `PlayerEntity`
- `FirebaseFantasySquadDTO` ↔ `FantasySquadEntity`
- `FirebaseLeagueDTO` ↔ `LeagueEntity`
- `FirebaseLeagueMemberDTO` ↔ `LeagueMemberEntity`

### Error Handling
```swift
enum AppError {
    case generalError          // No parameters
    case noInternet
    case badCredentials(String)
    case customError(String, Int?)
    case inputError(String, String)
    case inputsError([String], [String])
}
```

**Important**: Always use correct enum syntax:
```swift
throw AppError.generalError                    // ✅
throw AppError.customError("msg", code)       // ✅
throw AppError.badCredentials("reason")       // ✅
```

---

## Common Tasks

### Adding a New Feature
1. Create entities in `Domain/Entities/`
2. Create protocols in `Domain/Repositories/` and `Domain/Usecases/`
3. Create DTOs in `Data/DTOs/`
4. Implement DataSources in `Data/Datasources/`
5. Implement Repositories in `Data/Repositories/`
6. Create Views/ViewModels in `Presentation/Screens/`
7. Create Builder in same folder as View
8. Create DI Container in `DI/Containers/`

### Navigating Between Screens
```swift
// In Router subclass
func goToDetail(id: String) {
    navigator.push(to: DetailBuilder.build(id: id))
}

// In ViewModel
viewModel.goToDetail(id: item.id)
```

### Showing Alerts
```swift
// In Router (inherited from Router base class)
showAlert(title: "Title", message: "Message", action: { })
showAlert(with: appError, action: { })
showToastWithCloseAction(with: "Message", closeAction: { })
```

### Working with Async Data
```swift
@MainActor
func loadData() {
    Task {
        do {
            let data = try await useCase.fetch()
            self.items = data
        } catch let error as AppError {
            router.showAlert(with: error, action: { })
        }
    }
}
```

---

## File Locations Reference

### Critical Configuration Files
- `Shared/Configuration/ConfigFirebase.swift` - Firebase setup
- `Shared/Configuration/ConfigTripleA.swift` - TripleA networking setup
- `Shared/Configuration/Config.swift` - App constants

### Navigation System
- `Shared/Navigator/Navigator.swift` - Main singleton
- `Shared/Navigator/Router.swift` - Base class for all routers
- `Shared/Navigator/NavigatorRootView.swift` - Root container

### Error Handling
- `Shared/Error/AppError.swift` - Error enum definition
- `Shared/Error/ErrorHandlerManager.swift` - Error transformation

### Seed Data (for testing)
- `Shared/SeedData/SeedDataManager.swift` - Test data generation
- `Presentation/Screens/Debug/DebugView.swift` - Debug UI

### Main Features
- **Teams**: `Domain/Entities/TeamEntity.swift`, `Data/Repositories/Team/`
- **Players**: `Domain/Entities/PlayerEntity.swift`, `Data/Repositories/Player/`
- **Fantasy Squads**: `Domain/Entities/FantasySquadEntity.swift`, `Data/Repositories/FantasySquadRepository.swift`
- **Leagues**: `Domain/Entities/LeagueEntity.swift`, `Data/Repositories/LeagueRepository.swift`
- **Player Selection UI**: `Presentation/Screens/PlayerSelection/`

---

## Debugging Tips

### Build Errors
1. Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/MyDreamTeam*`
2. Check AppError usage - it's a common source of errors
3. Verify protocol names match exactly (watch for typos)
4. Check if properties are `let` (immutable) vs `var` (mutable)

### Runtime Issues
1. Check Firebase initialization in `AppDelegate` / `App.swift`
2. Verify Firestore rules allow the operation
3. Check network connectivity in simulator
4. Use DebugView to seed test data

### Common Mistakes
- ❌ Passing Router to View (should be in ViewModel only)
- ❌ Using `AppError.generalError(message:)` (no parameters)
- ❌ Mutating `let` properties in structs
- ❌ Forgetting @MainActor on UI update methods
- ❌ Not properly mapping DTOs to entities

---

## Testing Strategy

### Unit Test Pattern
```swift
// Mock dependencies
let mockRouter = MockRouter()
let mockUseCase = MockPlayerUseCase()

// Create ViewModel
let viewModel = PlayerSelectionViewModel(
    router: mockRouter,
    useCase: mockUseCase
)

// Test
viewModel.loadPlayers()
XCTAssertEqual(viewModel.players.count, 5)
```

### What to Test
- ViewModels (mock Router + UseCase)
- UseCases (mock Repository)
- Repositories (mock DataSource)
- DataSources (mock URLSession or actual API)

---

## Git Workflow

### Before Committing
1. Run build: `xcodebuild -scheme MyDreamTeam -configuration Debug`
2. Run tests: `xcodebuild test -scheme MyDreamTeam`
3. Check for compiler warnings
4. Verify no hardcoded strings (use localizable strings)

### Commit Message Format
```
[Feature/Fix/Refactor] Brief description

More detailed explanation if needed.

Fixes #123 (if applicable)
```

---

## External Dependencies

### Firebase
- FirebaseCore
- FirebaseFirestore
- FirebaseAuth
- FirebaseDatabase
- FirebaseAnalytics

### Third-party Libraries
- TripleA (Networking with OAuth)
- SwiftProtobuf (Firebase dependency)

### iOS Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

---

## Recent Changes (2025-12-01)

### Implemented
- ✅ Teams & Players feature (Domain + Data + UI layers)
- ✅ Player selection screen with filters
- ✅ Seed data system
- ✅ Debug menu

### Identified Issues
- ❌ 19x AppError.generalError() incorrect usage
- ❌ 2x Undefined ErrorHandlerManagerProtocol
- ❌ 4x Immutable property assignments

### Next Steps
1. Fix compilation errors (20-30 min)
2. Run full test suite
3. Merge to develop branch

---

## Quick Navigation Commands

```bash
# Open project
open MyDreamTeam.xcodeproj

# Clean build
xcodebuild clean -scheme MyDreamTeam

# Build simulator
xcodebuild -scheme MyDreamTeam -configuration Debug -destination 'generic/platform=iOS Simulator'

# Run specific test class
xcodebuild test -scheme MyDreamTeam -only-testing MyDreamTeamTests/PlayerSelectionViewModelTests

# Analyze code
xcodebuild analyze -scheme MyDreamTeam
```

---

## Contact & Documentation

- **Architecture Reference**: See `CLAUDE.md` in project root
- **PR Validation Report**: See `PR_VALIDATION_REPORT.md`
- **Firebase Setup**: See configuration files in `Shared/Configuration/`
- **Navigation System**: See `Shared/Navigator/` directory

---

**Remember**: This context file is your reference. Always check here before asking questions about the project structure or patterns.
