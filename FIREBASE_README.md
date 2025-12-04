# Firebase Integration - MyDreamTeam

**Status:** 🔄 Phase 1 In Progress
**Last Updated:** December 3, 2025

---

## 🎯 Quick Start

### What's Been Done ✅
- ✅ Created 7 Phase 1 authentication files
- ✅ Implemented Clean Architecture pattern
- ✅ Added error mapping (Firebase → AppError)
- ✅ Set up Dependency Injection

### What's Next ⚠️ (DO NOW)
- ⏳ Download GoogleService-Info.plist
- ⏳ Install Firebase SDK (CocoaPods)
- ⏳ Configure AppDelegate
- ⏳ Build and test

**Time to complete:** 15 minutes

---

## 📚 Documentation

### Start Here
👉 **[PHASE_1_NEXT_STEPS.md](./PHASE_1_NEXT_STEPS.md)** ← Read this FIRST
- Step-by-step instructions
- What to do RIGHT NOW
- Troubleshooting tips

### For Details
📖 **[FIREBASE_IMPLEMENTATION_GUIDE.md](./FIREBASE_IMPLEMENTATION_GUIDE.md)** ← Complete reference
- All 7 phases of implementation
- Complete code for each file
- Architecture explanations

### Current Status
📊 **[IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)** ← Overview
- What's been created
- Architecture diagrams
- Progress tracking

### Phase 1 Details
📋 **[PHASE_1_STATUS.md](./PHASE_1_STATUS.md)** ← Phase 1 summary
- All 7 files description
- Content overview
- Checklist

---

## 🏗️ Architecture Overview

### Clean Architecture Layers

```
VIEW LAYER
    ↓
VIEWMODEL + ROUTER
    ↓ (Injects)
USECASE (Domain)
    ↓ (Implements)
REPOSITORY (Protocol)
    ↓ (Calls)
DATASOURCE
    ↓ (Uses)
FIREBASE
```

### Phase 1 Files Created

```
Domain/
├── Entities/
│   └── AuthenticatedUser.swift ✅
├── Repositories/
│   └── AuthenticationRepositoryProtocol.swift ✅
└── UseCases/
    └── AuthenticationUseCase.swift ✅

Data/
├── Services/Firebase/Authentication/
│   ├── FirebaseAuthDataSource.swift ✅
│   └── AuthenticationDTO.swift ✅
└── Repositories/
    └── AuthenticationRepository.swift ✅

DI/
└── Containers/
    └── AuthenticationContainer.swift ✅
```

---

## ⚡ Next Steps (DO THESE NOW)

### Step 1: Download GoogleService-Info.plist (2 min)
```
1. Go: https://console.firebase.google.com
2. Select project "MyDreamTeam"
3. Click: Project Settings (⚙️)
4. Download: GoogleService-Info.plist
```

### Step 2: Add to Xcode (2 min)
```
1. Open: MyDreamTeam.xcodeproj
2. Drag: GoogleService-Info.plist to project
3. Check: "Copy items if needed"
4. Select: Target "MyDreamTeam"
```

### Step 3: Install Firebase SDK (5 min)
```bash
cd /Users/jordimiguelaguado/Desktop/Jordi/MyDreamTeam

# Edit Podfile and add:
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'

# Then run:
pod install
```

### Step 4: Configure AppDelegate (2 min)
Edit `MyDreamTeamApp.swift`:
```swift
import Firebase

@main
struct MyDreamTeamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
```

### Step 5: Build & Test (5 min)
```bash
# Close Xcode
open MyDreamTeam.xcworkspace  # NOT .xcodeproj!

# Build
⌘B (Product → Build)
```

---

## 📂 File Structure

All files have been created in the correct locations:

```
MyDreamTeam/
├── Domain/
│   ├── Entities/
│   │   └── AuthenticatedUser.swift ✅
│   ├── Repositories/
│   │   └── AuthenticationRepositoryProtocol.swift ✅
│   └── UseCases/
│       └── AuthenticationUseCase.swift ✅
│
├── Data/
│   ├── Services/
│   │   └── Firebase/
│   │       └── Authentication/
│   │           ├── FirebaseAuthDataSource.swift ✅
│   │           └── AuthenticationDTO.swift ✅
│   └── Repositories/
│       └── AuthenticationRepository.swift ✅
│
└── DI/
    └── Containers/
        └── AuthenticationContainer.swift ✅
```

---

## 🔐 What's Implemented

### Authentication Methods
- ✅ `signUp(email:password:)` - Create new account
- ✅ `signIn(email:password:)` - Login
- ✅ `signOut()` - Logout
- ✅ `getCurrentUser()` - Get session info
- ✅ `deleteAccount()` - Delete account

### Error Handling
Automatic Firebase error → AppError mapping:
- `invalidEmail` → Input error
- `weakPassword` → Input error
- `emailAlreadyInUse` → Custom error
- `userNotFound` → Bad credentials
- `wrongPassword` → Bad credentials
- `networkError` → No internet

### Protocols
- `FirebaseAuthDataSourceProtocol` - DataSource interface
- `AuthenticationRepositoryProtocol` - Repository interface
- `AuthenticationUseCaseProtocol` - UseCase interface

---

## 🧪 Testing Strategy

### Mock DataSource
```swift
class MockAuthDataSource: FirebaseAuthDataSourceProtocol {
    func signUp(email: String, password: String) async throws -> AuthUserDTO {
        return AuthUserDTO(
            id: "test-uid",
            email: email,
            displayName: "Test User",
            photoURL: nil,
            isEmailVerified: false,
            createdDate: Date()
        )
    }
}
```

### Test UseCase
```swift
let mockDataSource = MockAuthDataSource()
let repository = AuthenticationRepository(dataSource: mockDataSource)
let useCase = AuthenticationUseCase(repository: repository)

let user = try await useCase.signUp(email: "test@example.com", password: "pass123")
```

---

## 📊 Implementation Progress

| Phase | Status | Files | Duration |
|-------|--------|-------|----------|
| Phase 1: Auth | 🔄 In Progress | 7/7 ✅ | 30 min |
| Phase 1: Config | ⏳ Pending | - | 15 min |
| Phase 2: Users | ⏳ Pending | 7 | 1-2 hrs |
| Phase 3: Sports | ⏳ Pending | 21 | 2-3 hrs |
| Phase 4: Leagues | ⏳ Pending | 21 | 2-3 hrs |
| Phase 5: Advanced | ⏳ Pending | 15 | 2 hrs |
| Phase 6: Security | ⏳ Pending | 2 | 1 hr |

**Total Estimated Time:** 10-14 days

---

## 🚀 How to Use in Your App

### In a ViewModel
```swift
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""

    private let authUseCase = AuthenticationContainer.shared.makeUseCase()

    func signUp() {
        Task {
            do {
                let user = try await authUseCase.signUp(
                    email: email,
                    password: password
                )
                print("✅ Signed up: \(user.email)")
                // Navigate to next screen
            } catch let error as AppError {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
```

### In a View
```swift
struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
            SecureField("Password", text: $viewModel.password)

            Button("Sign Up") {
                viewModel.signUp()
            }

            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage).foregroundColor(.red)
            }
        }
    }
}
```

---

## ⚙️ Firebase Setup

### Requirements
- iOS 16.0+
- CocoaPods
- Firebase account

### Pods to Install
```ruby
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Functions'
pod 'Firebase/Analytics'
```

### Configuration
- AppDelegate: `FirebaseApp.configure()`
- GoogleService-Info.plist: Added to project
- Workspace: Open `.xcworkspace` not `.xcodeproj`

---

## 🎯 Next Phase: Users Collection

After Phase 1 is complete and builds successfully:

1. Create `User` entity
2. Create `UserDTO` with mappers
3. Create `FirebaseUsersDataSource`
4. Create `UserRepository`
5. Create `UserUseCase`
6. Create `UserContainer`
7. Implement user profile CRUD

**See:** FIREBASE_IMPLEMENTATION_GUIDE.md → Phase 2

---

## 🔗 Useful Resources

- 📖 [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- 📖 [Firebase Auth iOS](https://firebase.google.com/docs/auth/ios/start)
- 📖 [Firestore iOS](https://firebase.google.com/docs/firestore/ios/start)
- 📖 [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- 📖 [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)

---

## 📞 Troubleshooting

### "Cannot find 'Firebase' in scope"
- ✓ Add `import Firebase` to file
- ✓ Run `pod install`
- ✓ Open `.xcworkspace`

### "Module 'Firebase' not found"
- ✓ Close Xcode
- ✓ Run `pod install`
- ✓ Open `.xcworkspace` (not `.xcodeproj`)

### "FirebaseAuthDataSourceProtocol not found"
- ✓ Check files are in target "MyDreamTeam"
- ✓ Verify file paths match documentation
- ✓ Clean build folder (⇧⌘K)

### Build errors after pod install
- ✓ `pod deintegrate && pod install`
- ✓ Close Xcode
- ✓ Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`

---

## ✅ Completion Checklist

### Phase 1 Code (DONE ✅)
- [x] AuthenticatedUser.swift
- [x] FirebaseAuthDataSource.swift
- [x] AuthenticationDTO.swift
- [x] AuthenticationRepositoryProtocol.swift
- [x] AuthenticationRepository.swift
- [x] AuthenticationUseCase.swift
- [x] AuthenticationContainer.swift

### Phase 1 Setup (TODO)
- [ ] Download GoogleService-Info.plist
- [ ] Add plist to Xcode
- [ ] Update Podfile
- [ ] Run `pod install`
- [ ] Configure AppDelegate
- [ ] Build project

### Phase 1 Testing (TODO)
- [ ] Verify compilation
- [ ] Test sign-up
- [ ] Test sign-in
- [ ] Test sign-out

---

## 🎉 Summary

**Phase 1 is 100% code-complete!**

7 files created following Clean Architecture + MVVM.

**Your next task:** Configure Firebase (15 minutes)
- Download plist
- Install pods
- Configure AppDelegate
- Build & test

**Then:** Start Phase 2 - Users Collection

---

## 📝 Document Map

| Document | Purpose | Read When |
|----------|---------|-----------|
| **FIREBASE_README.md** | This file - Quick reference | NOW |
| **PHASE_1_NEXT_STEPS.md** | How to complete setup | NOW |
| **IMPLEMENTATION_SUMMARY.md** | Overview & timeline | After setup |
| **FIREBASE_IMPLEMENTATION_GUIDE.md** | Complete reference | Before each phase |
| **PHASE_1_STATUS.md** | Detailed phase 1 info | As needed |

---

**Ready to configure Firebase?** → Go to **PHASE_1_NEXT_STEPS.md**

