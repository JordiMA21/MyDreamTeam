# Initialize MyDreamTeam Development Session

This command sets up the development environment for MyDreamTeam project work.

## What This Does

1. Loads the project context from `.claude/context.md`
2. Initializes specialized agents for code analysis
3. Sets up references to key documentation files
4. Prepares tools for common development tasks

## Commands to Run

```bash
# After this command, you have access to:

# 1. Browse the context documentation
cat .claude/context.md

# 2. Check build status
xcodebuild -scheme MyDreamTeam -configuration Debug -destination 'generic/platform=iOS Simulator' 2>&1 | grep -E "error:|warning:"

# 3. View validation report
cat PR_VALIDATION_REPORT.md

# 4. Run specific tests
xcodebuild test -scheme MyDreamTeam -only-testing MyDreamTeamTests/TestClass
```

## Available Agents

After initialization, you can use these specialized agents:

### 1. **Explore Agent** - Code Navigation & Analysis
For exploring the codebase, finding files, understanding structure:
```
Use for: "Find all uses of AppError", "What files handle navigation?", "How is error handling implemented?"
```

### 2. **Plan Agent** - Implementation Planning
For designing new features or major refactors:
```
Use for: "Plan the authentication system", "How should we implement caching?", "Design the notification system"
```

### 3. **General-Purpose Agent** - Complex Multi-Step Tasks
For research, code generation, complex implementations:
```
Use for: "Research how to implement X", "Generate DTOs from schema", "Refactor the repository layer"
```

### 4. **Claude Code Guide Agent** - Claude Code Help
For questions about Claude Code features and SDK:
```
Use for: "How do I create a slash command?", "Can Claude Code do X?", "How does the MCP system work?"
```

## Key Files to Know

- `CLAUDE.md` - Architecture documentation
- `PR_VALIDATION_REPORT.md` - Current compilation errors and fixes needed
- `.claude/context.md` - Quick reference for project setup
- `.claude/commands/` - Command palette commands

## Next Steps

1. **Read the context**: Start with `.claude/context.md` for quick reference
2. **Check build status**: Run a build to see current errors
3. **Use appropriate agent**: Pick an agent based on your task
4. **Reference architecture**: Check `CLAUDE.md` for detailed patterns

## Quick Fixes Needed

Based on the latest PR validation report, you need to fix:

1. **AppError usage** (19 locations): Change `AppError.generalError(message:)` to `AppError.generalError`
2. **ErrorHandlerManagerProtocol** (2 locations): Remove unused property
3. **Immutable properties** (4 locations): Refactor setCaptain() method

See `PR_VALIDATION_REPORT.md` for complete details.

---

**Session initialized**: $(date)
**Project**: MyDreamTeam (iOS Fantasy Football)
**Ready for**: Development, debugging, feature implementation
