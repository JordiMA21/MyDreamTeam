# MyDreamTeam - Frequently Asked Questions

Use Ctrl+F to search for your question.

---

## Architecture & Design

### Q: What is the architecture of this project?
**A**: Clean Architecture + MVVM + Custom Navigator System

4 layers:
1. **Presentation**: Views, ViewModels, Routers, Builders
2. **Domain**: Entities, UseCases, Repository Protocols
3. **Data**: DataSources, Repositories, DTOs
4. **Shared**: Navigator, Error handling, Configuration

See `CLAUDE.md` for detailed guide.

---

### Q: Why is the Router injected into ViewModels, not Views?
**A**:
- Keeps Views dumb (presentation only)
- Centralizes navigation logic in ViewModels
- Makes Views reusable and testable
- Follows MVVM pattern correctly

Views should only:
- Display state from ViewModel
- Call ViewModel methods on user interaction

---

### Q: What's the difference between a DTO and an Entity?
**A**:
- **DTO (Data Transfer Object)**: Maps to API/Database schema (Firebase)
- **Entity**: Domain model used throughout app

DTOs are mapped to Entities at the Repository layer:
```swift
let dto = try await dataSource.getPlayer(id)
return dto.toDomain()  // ← Map here
```

---

### Q: How do I create a new feature?
**A**: Follow this layer-by-layer approach:

1. **Domain Layer** (no Firebase/networking knowledge):
   - Create Entity in `Domain/Entities/`
   - Create protocol in `Domain/Repositories/`
   - Create UseCase in `Domain/Usecases/`

2. **Data Layer** (handles Firebase/API):
   - Create DTO in `Data/DTOs/`
   - Create DataSource in `Data/Datasources/Firebase/`
   - Create Repository in `Data/Repositories/`

3. **Presentation Layer** (UI):
   - Create View in `Presentation/Screens/`
   - Create ViewModel in same folder
   - Create Router in same folder
   - Create Builder in same folder

4. **DI Setup**:
   - Create Container in `DI/Containers/`

---

### Q: What's the Navigator system?
**A**: Custom centralized navigation (replaces SwiftUI's NavigationStack)

**Location**: `Shared/Navigator/`

**Why custom?**: More control, supports complex navigation patterns, works with our Router system

**Usage**:
```swift
// In Router:
navigator.push(to: DetailBuilder.build(id: id))
navigator.presentSheet(SheetBuilder.build())
showAlert(with: error, action: { })
showToastWithCloseAction(with: "Message")
```

---

## Coding Standards

### Q: How should I handle errors?
**A**: Use AppError enum with correct syntax:

```swift
// ✅ CORRECT
throw AppError.generalError
throw AppError.customError("Error message", 500)
throw AppError.badCredentials("Invalid password")
throw AppError.noInternet
throw AppError.inputError("fieldName", "error message")

// ❌ WRONG
throw AppError.generalError(message: "...")
throw AppError.customError(message: "...")
throw AppError.badCredentials  // Missing parameter
```

**Error Flow**:
1. DataSource catches Firestore error
2. DataSource maps to AppError in `mapFirestoreError()`
3. Repository catches and rethrows AppError
4. ViewModel catches and shows via Router

See `Shared/Error/AppError.swift` for definitions.

---

### Q: How do I update UI from async operations?
**A**: Use @MainActor + @Published:

```swift
class PlayerViewModel: ObservableObject {
    @Published var players: [PlayerEntity] = []

    @MainActor
    func loadPlayers() {
        Task {
            do {
                let data = try await useCase.getPlayers()
                self.players = data  // Updates UI
            } catch let error as AppError {
                router.showAlert(with: error, action: { })
            }
        }
    }
}
```

---

### Q: Should I use structs or classes for entities?
**A**: **Use structs** for:
- Entities (domain models)
- DTOs (data transfer objects)
- Value types generally

**Use classes** for:
- ViewModels (@ObservableObject)
- Repositories
- UseCases
- DataSources

---

### Q: How do I make a struct property mutable while keeping others immutable?
**A**: Create new instance instead of mutating:

```swift
// ❌ WRONG
var mutablePlayer = player
mutablePlayer.isCaptain = true  // Error: Can't assign to let property

// ✅ CORRECT
let updatedPlayer = FantasyPlayerEntity(
    id: player.id,
    firstName: player.firstName,
    // ... all other properties ...
    isCaptain: true
)
```

---

## Compilation & Building

### Q: Build says "AppError.generalError has no associated values"
**A**: You're calling it with parameters. AppError.generalError takes NO parameters.

Change:
```swift
// ❌ WRONG
throw AppError.generalError(message: "Error")

// ✅ CORRECT
throw AppError.generalError
// OR for messages:
throw AppError.customError("Error message", errorCode)
```

See `PR_VALIDATION_REPORT.md` for all affected locations.

---

### Q: Build says "Cannot find type 'ErrorHandlerManagerProtocol'"
**A**: This protocol doesn't exist. The code references it but it's not defined.

**Solution**: Remove the unused property:
```swift
// ❌ REMOVE THESE
private let errorHandler: ErrorHandlerManagerProtocol
```

See `PR_VALIDATION_REPORT.md` for affected files.

---

### Q: Build says "Cannot assign to property 'isCaptain' is a 'let' constant"
**A**: You're trying to mutate a let property in a struct.

**Solution**: Create a new instance instead:
```swift
// Instead of:
var mutablePlayer = player
mutablePlayer.isCaptain = true  // ❌ Error

// Do this:
let updatedPlayer = FantasyPlayerEntity(
    // ... copy all properties except isCaptain ...
    isCaptain: true
)
```

---

### Q: How do I clean the build?
**A**:
```bash
# Simple clean
xcodebuild clean -scheme MyDreamTeam

# Deep clean (remove derived data)
rm -rf ~/Library/Developer/Xcode/DerivedData/MyDreamTeam*
```

---

### Q: Why is the build so slow?
**A**: Firebase SDK and protobuf compilation are heavy. Normal for this setup. Use `-showBuildTiming` to analyze:
```bash
xcodebuild -scheme MyDreamTeam -showBuildTiming
```

---

## Firebase & Data

### Q: How is Firestore organized?
**A**:
```
firestore/
├── leagues/{leagueId}/
│   ├── Document: league data
│   └── subcollection: members/{userId}/
│
├── fantasySquads/{squadId}/
│   ├── Document: squad data
│   └── subcollection: transfers/{transferId}/
│
├── teams/{teamId}/
│   └── Document: team data
│
└── players/{playerId}/
    └── Document: player data
```

See `.claude/context.md` for more detail.

---

### Q: How do I add a new field to Firestore?
**A**:
1. Update the DTO in `Data/DTOs/`
2. Add mapper logic (toDomain/toDTO)
3. Update Entity in `Domain/Entities/`
4. Update Repository if needed

Example:
```swift
// DTO
struct FirebasePlayerDTO: Codable {
    @DocumentID var id: String?
    var newField: String  // ← Add here
    // ...
}

// Entity
struct PlayerEntity {
    let newField: String  // ← Add here
    // ...
}

// Mappers
func toDomain() -> PlayerEntity {
    PlayerEntity(
        // ...
        newField: self.newField  // ← Map here
    )
}
```

---

### Q: How do I create test data?
**A**: Use `SeedDataManager` in `Shared/SeedData/`:

```swift
// In DebugView:
Task {
    try await SeedDataManager.shared.seedAllData()
}
```

Or extend it to add more data:
```swift
// In SeedDataManager:
func seedNewFeature() async throws {
    // Create test data
    let dto = FirebasePlayerDTO(...)
    try await dataSource.addPlayer(dto)
}
```

---

## Testing

### Q: How do I test a ViewModel?
**A**: Mock the Router and UseCase:

```swift
class MockRouter: PlayerSelectionRouter {
    var navigatedToDetail = false
    override func navigateToDetail(id: String) {
        navigatedToDetail = true
    }
}

class MockUseCase: PlayerUseCaseProtocol {
    func getPlayers() async throws -> [PlayerEntity] {
        return [createMockPlayer()]
    }
}

// Test
let mockRouter = MockRouter()
let mockUseCase = MockUseCase()
let viewModel = PlayerSelectionViewModel(
    router: mockRouter,
    useCase: mockUseCase
)

viewModel.loadPlayers()
XCTAssertTrue(viewModel.players.count > 0)
```

---

### Q: How do I run tests?
**A**:
```bash
# All tests
xcodebuild test -scheme MyDreamTeam

# Specific test class
xcodebuild test -scheme MyDreamTeam -only-testing MyDreamTeamTests/PlayerTests

# Specific test method
xcodebuild test -scheme MyDreamTeam -only-testing MyDreamTeamTests/PlayerTests/testPlayerCreation
```

---

## Common Issues

### Q: My view isn't updating when state changes
**A**: Did you:
1. Make property @Published in ViewModel?
2. Use @StateObject in View?
3. Update the property on main thread?

```swift
class ViewModel: ObservableObject {
    @Published var items: [Item] = []  // ← Must be @Published

    @MainActor  // ← Updates must be on main thread
    func loadItems() {
        Task {
            self.items = try await useCase.fetch()
        }
    }
}

struct View: View {
    @StateObject var viewModel: ViewModel  // ← Must be @StateObject
}
```

---

### Q: Navigation doesn't work
**A**: Did you:
1. Inject Router into ViewModel (not View)?
2. Use navigator.push/presentSheet in Router?
3. Create Builder for the destination?

```swift
// ✅ Correct
class MyRouter: Router {
    func goToNext() {
        navigator.push(to: NextBuilder.build())
    }
}

// In ViewModel
viewModel.goToNext()  // Calls router method
```

---

### Q: @Published property isn't working
**A**: Common issues:
1. Forgot @Published keyword
2. Forgot @StateObject in View
3. Updating on background thread (use @MainActor)

```swift
// ✅ Correct
class ViewModel: ObservableObject {
    @Published var state: String = ""  // Must have @Published

    @MainActor
    func updateState() {
        self.state = "new value"  // Updates UI
    }
}
```

---

## Git & Workflow

### Q: What should I include in a commit message?
**A**:
```
[Feature/Fix/Refactor] Brief description

More detailed explanation if needed.

Fixes #123  (if applicable)
```

Examples:
```
[Feature] Add player filtering to PlayerSelection view
[Fix] Correct AppError.generalError usage throughout codebase
[Refactor] Extract player mapper to separate file
```

---

### Q: What files shouldn't I commit?
**A**:
- `.DS_Store`
- `*.xcworkspace/xcuserdata/`
- `DerivedData/`
- `.swiftpm/`
- `Pods/` (if using CocoaPods)
- Configuration files with secrets

---

### Q: How do I review my changes before committing?
**A**:
```bash
# Check current status
git status

# See changes to files
git diff

# See only certain changes
git diff MyDreamTeam/Path/To/File.swift

# Stage changes interactively
git add -i
```

---

## Tools & Debugging

### Q: How do I see print statements in the console?
**A**: Use console output:
```swift
print("Debug: \(variable)")  // Shows in Xcode console
```

Or use os.log for production:
```swift
import os.log

os_log("Debug message: %{public}@", log: .default, type: .debug, variable)
```

---

### Q: How do I debug a crashing feature?
**A**:
1. Check the crash log in Xcode
2. Use breakpoints (click line number)
3. Use LLDB debugger: `po variable` to print object
4. Add guard statements to find where it breaks

```swift
func problematicFunction() {
    guard let data = optionalData else {
        print("Data is nil!")
        return
    }
    // Continue...
}
```

---

### Q: Where are the app logs?
**A**:
- Console output: Xcode's Console window
- Device logs: Settings → Privacy → Analytics → Analytics Data
- Crash logs: Xcode Organizer → Crashes tab

---

## Performance

### Q: How can I improve build speed?
**A**:
1. Use incremental builds (don't clean every time)
2. Disable unnecessary dependencies
3. Use `-parallelizeTargets` flag:
```bash
xcodebuild -scheme MyDreamTeam -parallelizeTargets
```

---

### Q: How do I profile app performance?
**A**:
1. Product → Profile (⌘I)
2. Select profiling tool (Time Profiler, Memory, etc.)
3. Run your feature
4. Analyze the results

---

## General

### Q: How do I know which agent to use?
**A**: Check the task:
- **Exploring code**: Use Explore Agent
- **Planning feature**: Use Plan Agent
- **Complex task**: Use General-Purpose Agent
- **Claude Code question**: Use Claude Code Guide Agent

Or just ask! The right agent will usually be picked automatically.

---

### Q: Where do I ask questions?
**A**: In the chat! But first check:
1. `.claude/context.md` - Quick reference
2. This FAQ - Search your question
3. `PR_VALIDATION_REPORT.md` - Current issues
4. `CLAUDE.md` - Architecture details

---

### Q: Can I modify the .claude files?
**A**: Yes! Keep them updated:
- `context.md` - Update when major changes happen
- `QUICK_START.md` - Update status section
- `FAQ.md` - Add new questions
- `commands/init.md` - Update when setup changes

---

### Q: How do I stay organized?
**A**: Use the TodoWrite tool:
```
Use TodoWrite to track:
- What you're working on
- Subtasks to complete
- Bugs to fix
- Features to implement
```

Check progress with `/help` or just ask!

---

**Last Updated**: 2025-12-01
**Questions added**: 25+
**Search this file for your answer!**
