# MyDreamTeam - Quick Start Guide for Claude Code

**Read this first when opening a new Claude Code session on this project.**

---

## 30-Second Overview

**Project**: iOS Fantasy Football App (MyDreamTeam)
**Architecture**: Clean Architecture + MVVM + Custom Navigator
**Language**: Swift/SwiftUI
**Status**: 🔴 Build broken - 25 compilation errors to fix

---

## Before You Start

### 1. Read the Context
```
.claude/context.md  ← Read this first!
```

### 2. Check the Project Architecture
```
CLAUDE.md  ← Detailed architecture guide
```

### 3. Know the Current Issues
```
PR_VALIDATION_REPORT.md  ← What's broken and why
```

---

## Current Status (Dec 1, 2025)

### ✅ What Works
- Domain layer entities (Teams, Players, FantasySquads, Leagues)
- Data layer (Firebase DataSources, Repositories, DTOs)
- Presentation layer (PlayerSelection UI, ViewModels, Routers)
- Seed data system (for testing)
- Debug menu

### ❌ What's Broken
- **25 compilation errors** preventing build
- **19x** `AppError.generalError(message:)` - wrong syntax
- **2x** `ErrorHandlerManagerProtocol` - undefined
- **4x** Immutable property mutations - incorrect code

### ⏱️ Time to Fix
Estimated: **20-30 minutes** for all compilation errors

---

## Directory Structure (Key Locations)

```
MyDreamTeam/
├── Domain/
│   ├── Entities/              ← Business models
│   ├── Usecases/              ← Business logic
│   └── Repositories/          ← Protocol definitions
│
├── Data/
│   ├── Datasources/Firebase/  ← Firestore integration
│   ├── Repositories/          ← Protocol implementations
│   └── DTOs/                  ← Data transfer objects
│
├── Presentation/
│   ├── Screens/               ← Feature screens
│   │   ├── PlayerSelection/
│   │   └── Debug/
│   └── Shared/
│       └── Components/        ← Reusable UI components
│
├── Shared/
│   ├── Navigator/             ← Navigation system (custom)
│   ├── Error/                 ← Error definitions
│   └── Configuration/         ← Firebase, TripleA setup
│
├── DI/
│   └── Containers/            ← Dependency injection
│
├── CLAUDE.md                  ← Architecture guide
├── PR_VALIDATION_REPORT.md    ← Build errors & fixes
└── .claude/
    ├── context.md             ← Context documentation
    ├── QUICK_START.md         ← This file
    └── commands/
        └── init.md            ← Session initialization
```

---

## Common Tasks

### ❓ "I need to understand the architecture"
→ Read `CLAUDE.md` (full guide with examples)

### ❓ "I need to add a new feature"
→ Use **Plan Agent** to design, then implement in layers:
1. Domain (Entities + UseCases)
2. Data (DTOs + DataSources + Repositories)
3. Presentation (Views + ViewModels + Routers)

### ❓ "Where is code for X feature?"
→ Use **Explore Agent** to search codebase:
```
"Find all files related to player management"
"Where is Firebase integration?"
"How are errors handled?"
```

### ❓ "Why won't this compile?"
→ Check `PR_VALIDATION_REPORT.md` first, then:
1. Verify `AppError` usage is correct
2. Check for undefined protocols
3. Look for immutable property mutations

### ❓ "How do I run/build the app?"
→ See **Build Commands** section below

### ❓ "I need to fix the compilation errors"
→ See `PR_VALIDATION_REPORT.md` for exact fixes needed

---

## Build Commands

```bash
# Clean build artifacts
xcodebuild clean -scheme MyDreamTeam

# Build for simulator
xcodebuild -scheme MyDreamTeam -configuration Debug \
  -destination 'generic/platform=iOS Simulator'

# Show only errors
xcodebuild build 2>&1 | grep "error:"

# Show errors and warnings
xcodebuild build 2>&1 | grep -E "error:|warning:"

# Run tests
xcodebuild test -scheme MyDreamTeam

# Run specific test
xcodebuild test -scheme MyDreamTeam \
  -only-testing MyDreamTeamTests/PlayerSelectionViewModelTests

# Open in Xcode
open MyDreamTeam.xcodeproj
```

---

## Architecture Patterns (TL;DR)

### Router in ViewModel, NOT in View
```swift
// ✅ CORRECT
class PlayerViewModel: ObservableObject {
    let router: PlayerRouter  // Injected into ViewModel

    func didTapPlayer() {
        router.navigateToDetail(id: player.id)
    }
}

// ❌ WRONG
struct PlayerView: View {
    let router: PlayerRouter  // Don't put in View!
}
```

### Use AppError Correctly
```swift
// ✅ CORRECT
throw AppError.generalError
throw AppError.customError("Error message", errorCode)
throw AppError.badCredentials("reason")

// ❌ WRONG
throw AppError.generalError(message: "...")
throw AppError.customError(message: "...")
```

### Map DTOs to Entities at Repository Layer
```swift
func getPlayer(id: String) async throws -> PlayerEntity {
    let dto = try await dataSource.getPlayer(id: id)
    return dto.toDomain()  // ← Map here, not in DataSource
}
```

### Builder for Dependency Injection
```swift
struct PlayerDetailBuilder {
    static func build(playerId: String) -> some View {
        let router = PlayerDetailRouter()
        let useCase = PlayerContainer.shared.makeUseCase()
        let viewModel = PlayerDetailViewModel(router: router, useCase: useCase)
        return PlayerDetailView(viewModel: viewModel)
    }
}
```

---

## Key Files Reference

| File | Purpose | Location |
|------|---------|----------|
| `CLAUDE.md` | Full architecture guide | Project root |
| `PR_VALIDATION_REPORT.md` | Compilation errors & fixes | Project root |
| `context.md` | Quick reference | `.claude/` |
| `AppError.swift` | Error definitions | `Shared/Error/` |
| `Navigator.swift` | Navigation system | `Shared/Navigator/` |
| `ConfigFirebase.swift` | Firebase setup | `Shared/Configuration/` |
| `SeedDataManager.swift` | Test data generation | `Shared/SeedData/` |

---

## Which Agent to Use?

### 🔍 Explore Agent
**When**: You need to find code, understand existing implementation
**Examples**:
- "Find all AppError usage in repositories"
- "Where is Firestore integration?"
- "How are players loaded in PlayerSelection?"

### 📋 Plan Agent
**When**: You need to design a new feature before implementation
**Examples**:
- "Plan the authentication system"
- "Design the notification feature"
- "How should we implement caching?"

### 🛠️ General-Purpose Agent
**When**: Complex multi-step tasks, research, code generation
**Examples**:
- "Generate all the layers for a new feature"
- "Refactor this code"
- "Research how to implement push notifications"

### 💬 Claude Code Guide Agent
**When**: Questions about Claude Code itself
**Examples**:
- "How do I create a slash command?"
- "How does MCP integration work?"
- "Can Claude Code run tests?"

---

## Emergency Reference

### Build Won't Compile?
1. Check `PR_VALIDATION_REPORT.md`
2. Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/MyDreamTeam*`
3. Run: `xcodebuild clean -scheme MyDreamTeam`

### Compilation Error About AppError?
→ See AppError enum definition in `Shared/Error/AppError.swift`
→ Check `PR_VALIDATION_REPORT.md` for exact fixes

### Can't Find a Protocol?
→ Use Explore Agent: "Find definition of X protocol"
→ Check if it's supposed to exist in codebase

### Immutable Property Error?
→ Probably trying to mutate a `let` struct property
→ Create new instance instead: `FantasyPlayerEntity(..., isCaptain: newValue)`

---

## Developer Checklist

When starting work on this project:

- [ ] Read `.claude/context.md` for quick reference
- [ ] Check `PR_VALIDATION_REPORT.md` for current issues
- [ ] Understand the 4-layer architecture (see `CLAUDE.md`)
- [ ] Know the Router pattern (Router in ViewModel, not View)
- [ ] Review `AppError` enum for correct syntax
- [ ] Check Firebase structure in context.md
- [ ] Pick the right agent for your task

---

## Quick Links

- **Architecture Deep Dive**: `CLAUDE.md`
- **Current Issues**: `PR_VALIDATION_REPORT.md`
- **Quick Reference**: `.claude/context.md`
- **Build Guide**: See "Build Commands" section above
- **Feature Locations**: See "Directory Structure" section above

---

## Need Help?

1. **Architecture question?** → Read `CLAUDE.md`
2. **Build issue?** → Check `PR_VALIDATION_REPORT.md`
3. **Don't know what to do?** → Use **Explore Agent**
4. **Need to plan something?** → Use **Plan Agent**
5. **Stuck on a bug?** → Check this file's "Emergency Reference" section

---

**Last Updated**: 2025-12-01
**Project Status**: 🔴 Build broken, ready to fix (20-30 min)
**Next Step**: Fix the 25 compilation errors and build will work!
