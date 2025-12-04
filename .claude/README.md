# Claude Code Configuration - MyDreamTeam Project

Welcome to the MyDreamTeam development environment! This directory contains configuration files to help Claude Code assist you effectively on this iOS project.

---

## 📚 Start Here

### First Time Opening This Project?
1. **Read this file** (you are here)
2. **Open `.claude/QUICK_START.md`** - 5 minute overview
3. **Open `.claude/context.md`** - Quick reference guide
4. **Then start coding!**

### Returning to the Project?
1. **Check `.claude/FAQ.md`** for quick answers
2. **Check `PR_VALIDATION_REPORT.md`** for current issues
3. **Pick an agent** based on your task
4. **Ask Claude Code** - it has this context!

---

## 📋 Files in This Directory

| File | Purpose | Read Time |
|------|---------|-----------|
| `README.md` | This file - Navigation guide | 2 min |
| `QUICK_START.md` | 30-second overview + key concepts | 5 min |
| `context.md` | Detailed quick reference | 10 min |
| `FAQ.md` | Answers to common questions | Browse |
| `commands/init.md` | Session initialization guide | 3 min |

---

## 📁 What's in the Project Root

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Complete architecture documentation |
| `PR_VALIDATION_REPORT.md` | Current compilation errors and fixes |
| `MyDreamTeam.xcodeproj` | Xcode project file |
| `MyDreamTeam/` | Source code directory |

---

## 🚀 Quick Navigation

### I want to...

**Understand the project**
→ Read `QUICK_START.md` then `../CLAUDE.md`

**Find something in the code**
→ Use **Explore Agent**: "Find all uses of AppError"

**Add a new feature**
→ Use **Plan Agent**: "Design the authentication system"

**Fix compilation errors**
→ Read `../PR_VALIDATION_REPORT.md`

**Understand architecture patterns**
→ Read `../CLAUDE.md` (architecture section)

**Get quick answers**
→ Search `FAQ.md` (Ctrl+F)

**Know what's broken**
→ Check `../PR_VALIDATION_REPORT.md`

---

## 🔍 Project Overview

**Name**: MyDreamTeam
**Type**: iOS Fantasy Football Application
**Language**: Swift/SwiftUI
**Architecture**: Clean Architecture + MVVM + Custom Navigator
**Status**: 🟡 Ready to work (25 compilation errors need fixing)

### Key Facts
- 4-layer architecture (Presentation, Domain, Data, Shared)
- Custom Navigator system (replaces SwiftUI NavigationStack)
- Firebase Firestore for data persistence
- Protocol-based design throughout
- Async/await for concurrency

---

## 🤖 Which Agent Should I Use?

```
Your Task → Pick an Agent
├─ "Find where X is implemented" → Explore Agent
├─ "Design a new feature" → Plan Agent
├─ "Generate code for X" → General-Purpose Agent
├─ "How do I use Claude Code feature Y?" → Claude Code Guide Agent
└─ Not sure? → Just ask Claude Code!
```

### Agent Availability
Agents are NOT automatically loaded. When you ask Claude Code a question:
1. Describe what you need
2. Claude will suggest which agent is best
3. Approve and it runs automatically

For manual control:
```
[In chat] "Use Explore Agent to find all AppError references"
[In chat] "Use Plan Agent to design the notification system"
```

---

## 🛠️ Build & Run

```bash
# Build for simulator
xcodebuild -scheme MyDreamTeam -configuration Debug \
  -destination 'generic/platform=iOS Simulator'

# Run tests
xcodebuild test -scheme MyDreamTeam

# Clean build artifacts
xcodebuild clean -scheme MyDreamTeam
```

See `QUICK_START.md` for more commands.

---

## 📊 Current Status

### What Works ✅
- Domain layer (Entities, UseCases)
- Data layer (Firebase, DTOs, Repositories)
- Presentation layer (Views, ViewModels, Routers)
- Seed data system
- Debug menu

### What's Broken ❌
- **25 compilation errors** blocking build:
  - 19x `AppError.generalError(message:)` - wrong syntax
  - 2x `ErrorHandlerManagerProtocol` - undefined
  - 4x Immutable property mutations - bad design

### Time to Fix
**Estimated**: 20-30 minutes for all errors

See `../PR_VALIDATION_REPORT.md` for details.

---

## 📖 Documentation Structure

```
MyDreamTeam/
├── .claude/                    ← You are here
│   ├── README.md               ← Navigation hub
│   ├── QUICK_START.md          ← 5-min overview
│   ├── context.md              ← Quick reference
│   ├── FAQ.md                  ← Q&A
│   └── commands/init.md        ← Setup guide
│
├── CLAUDE.md                   ← Full architecture guide
├── PR_VALIDATION_REPORT.md     ← Build errors & fixes
└── MyDreamTeam/                ← Source code

```

### Reading Order
1. Start here: `.claude/README.md` (this file)
2. Quick overview: `.claude/QUICK_START.md`
3. Detailed ref: `.claude/context.md`
4. Answers: `.claude/FAQ.md`
5. Full details: `../CLAUDE.md`
6. Bug tracking: `../PR_VALIDATION_REPORT.md`

---

## 🎯 Common Tasks with File References

### "I need to understand the architecture"
Files to read:
- `.claude/QUICK_START.md` (patterns overview)
- `../CLAUDE.md` (full architecture guide)
- `.claude/context.md` (quick reference)

### "I need to fix compilation errors"
Files to read:
- `../PR_VALIDATION_REPORT.md` (all 25 errors listed)
- `.claude/FAQ.md` (search "Build says...")
- `../CLAUDE.md` (coding standards section)

### "I need to add a new feature"
Steps:
1. Read `../CLAUDE.md` (creating new feature section)
2. Use **Plan Agent** to design
3. Follow the 4-layer approach in `.claude/context.md`

### "I need to find something in code"
Use **Explore Agent** with descriptive query:
- "Find all uses of AppError in repositories"
- "Where is Firebase initialization?"
- "How are errors handled in the app?"

### "I got a compilation error"
1. Search `.claude/FAQ.md` for the error message
2. Read `../PR_VALIDATION_REPORT.md` (complete error list)
3. Check `../CLAUDE.md` (coding standards)

---

## 🚨 Emergency Reference

### Build Won't Compile?
→ Check `../PR_VALIDATION_REPORT.md`

### Error About AppError?
→ Search `.claude/FAQ.md` for "AppError"

### Can't Find Protocol?
→ Use Explore Agent: "Find definition of X"

### Property Assignment Error?
→ Search `.claude/FAQ.md` for "immutable"

### Navigation Not Working?
→ Search `.claude/FAQ.md` for "navigation"

---

## 💡 Tips for Using Claude Code

### Work Smarter
1. **Reference these files** when asking questions
2. **Use the right agent** for your task
3. **Check FAQ first** for common issues
4. **Describe your goal**, not just the error

### Example Good Questions
```
"Use Explore Agent to find all AppError usage in repositories"
"Use Plan Agent to design authentication flow"
"Fix the 25 compilation errors in PR_VALIDATION_REPORT.md"
"According to context.md, how should I implement X?"
```

### Example Less Good Questions
```
"It doesn't work"
"What's wrong?"
"Help me"
```

---

## 📞 Getting Help

### Within Claude Code
Just ask! Provide:
1. What you're trying to do
2. What error you're getting (if any)
3. Which file/line if relevant
4. Context from `.claude/` if relevant

### Before You Ask
Check:
1. `.claude/FAQ.md` - Search for your question
2. `.claude/QUICK_START.md` - Common issues section
3. `../PR_VALIDATION_REPORT.md` - Current build errors
4. `../CLAUDE.md` - Architecture details

---

## 🔄 Keeping Files Updated

These files are living documents. When you:
- Fix the compilation errors → Update `../PR_VALIDATION_REPORT.md`
- Learn something new → Add to `.claude/FAQ.md`
- Change architecture → Update `.claude/context.md`
- Add commands → Update `.claude/commands/init.md`

Keep them current so future you (and others) benefit!

---

## 📌 Bookmarks to Remember

- **Architecture guide**: `../CLAUDE.md`
- **Current errors**: `../PR_VALIDATION_REPORT.md`
- **Quick answers**: `.claude/FAQ.md`
- **30-sec overview**: `.claude/QUICK_START.md`
- **Build commands**: `.claude/QUICK_START.md` (Build Commands section)

---

## ✅ Checklist: First Time in Project

- [ ] Read this file (README.md)
- [ ] Read `.claude/QUICK_START.md`
- [ ] Skim `.claude/context.md` for reference
- [ ] Check `../PR_VALIDATION_REPORT.md` for current status
- [ ] Pick a task from this project
- [ ] Use the right agent (ask Claude Code if unsure)
- [ ] Reference these files when needed
- [ ] Update this files as you learn new things

---

## 🎓 Next Steps

1. **Read `.claude/QUICK_START.md`** (5 minutes)
2. **Check `../PR_VALIDATION_REPORT.md`** (current issues)
3. **Pick a task** (fixing errors, adding features, etc.)
4. **Ask Claude Code** with context from these files
5. **Keep docs updated** as you work

---

**Welcome to MyDreamTeam development!**

Questions? Check `.claude/FAQ.md` or ask Claude Code!

**Last Updated**: 2025-12-01
**Version**: 1.0
**Status**: Ready to use

---

## Quick Links (Copy/Paste to Reference)

- `../CLAUDE.md` - Architecture documentation
- `../PR_VALIDATION_REPORT.md` - Build errors and fixes
- `.claude/QUICK_START.md` - 5-minute overview
- `.claude/context.md` - Quick reference
- `.claude/FAQ.md` - Frequently asked questions
