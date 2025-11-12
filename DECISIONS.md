# FamilyHub - Master Decision Log

## How to Use This Document
- Every architectural/design decision gets recorded here
- Format: Date | Decision | Rationale | Chat Reference
- Update this BEFORE starting new phase chat
- Read this FIRST when starting new phase chat

---

## Phase 1 Decisions

### 2025-11-12 | Navigation Architecture
**Decision:** MVVM with SwiftUI, MainTabView pattern
**Rationale:** Standard iOS pattern, easy to extend
**Chat:** Phase 1.1 - Build Fixes
**Status:** ✅ Implemented

### 2025-11-12 | User Selection with Button-Based Tap
**Decision:** Use Button with CardButtonStyle instead of onTapGesture
**Rationale:** More reliable tap detection, provides visual feedback (scale + opacity)
**Chat:** Phase 1.1 - Build Fixes
**Status:** ✅ Implemented

### 2025-11-12 | Debug Logging Strategy
**Decision:** Emoji-prefixed console logs for navigation flow diagnosis
**Rationale:** Easy to spot in console, helps debug binding/state issues
**Chat:** Phase 1.1 - Build Fixes
**Status:** ✅ Implemented (to be removed after testing)

### 2025-11-12 | PDF Timetable Permissions (Option C)
**Decision:** Any family member can import/manage any student's timetable
**Rationale:** Flexible for family use, parent can help, single source of truth
**Chat:** Phase 1.1 - Build Fixes
**Status:** 📋 To implement in Phase 2.2

### 2025-11-12 | Profile Photos
**Decision:** Deferred to v1.1+ (after MVP ships)
**Rationale:** Nice-to-have, focus on timetable first
**Chat:** Phase 1.1 - Build Fixes
**Status:** 🔮 Future

### 2025-11-12 | Authentication Strategy
**Decision:** Path A - Ship MVP first (Phase 1-3), then add Apple ID (Phase 4) + HealthKit (Phase 5)
**Rationale:** Learn in isolated steps, lower risk, Amelia gets working app sooner
**Chat:** Phase 1.1 - Build Fixes
**Status:** ✅ Confirmed

### 2025-11-12 | HealthKit Integration
**Decision:** Add after MVP as testbed for fitness app patterns
**Rationale:** Learn HealthKit + auth in simpler context before big fitness app
**Chat:** Phase 1.1 - Build Fixes
**Status:** 📋 Phase 5 feature (after timetable complete)

---

## Phase 2 Decisions
(To be filled in Phase 2.1/2.2 chats)

## Phase 3 Decisions
(To be filled in Phase 3 chat)

## Phase 4 Decisions - Apple ID
(To be filled when we reach this phase)

## Phase 5 Decisions - HealthKit
(To be filled when we reach this phase)

---

## Technical Debt / Future Considerations

### User Switching
**Current:** Kill app to switch users
**Proposed:** "Switch User" button in Settings
**Priority:** Low (Phase 1.2 or later)

### Authentication
**Current:** None (trust-based, local only)
**Future Options:**
- v1.1: PIN/password per user
- v2.0: Sign in with Apple (Phase 4)

**Decision Point:** After Phase 3 complete

### Backend
**Current:** Local SwiftData + iCloud only
**Future:** Not needed for family app, consider for fitness app
**Decision:** No backend for FamilyHub

---

## Scope Changes

### Added to Roadmap
- Phase 4: Sign in with Apple (learning exercise)
- Phase 5: HealthKit integration (fitness app prep)

### Removed from Scope
- Backend user management (out of scope)
- Multi-family support (not needed)

---

## Design System Decisions

### Colours
- British spelling throughout ✅
- System colours with semantic meanings ✅
- Liquid Glass design language (Apple 2025) ✅

### Typography
- SF Pro (system font) ✅
- Proper hierarchy ✅

### Materials
- `.regularMaterial` for period cards ✅
- `.thinMaterial` for navigation/week selector ✅
- **Note:** Material cannot be used directly with `.listRowBackground()` - use `Color.backgroundTertiary` instead

---

## Open Questions
(Things we need to decide but haven't yet)

### Navigation Tap Issue
**Question:** Why isn't user card tap triggering navigation to MainTabView?
**Status:** 🔍 Investigating with debug logging
**Next Step:** Run app, capture console output, diagnose binding flow
**Chat:** Phase 1.1 - Build Fixes

### HealthKit Metrics
**Question:** Which health metrics to display in Health tab?
**Options:** Steps, sleep, heart rate, workouts, active energy, VO2 Max
**Decision Date:** TBD (Phase 5 chat)
**Priority:** Medium

---

## Chat Reference Map

| Chat Name | Token Status at End | Key Decisions | Files Changed |
|-----------|---------------------|---------------|---------------|
| Phase 1.1 - Build Fixes | ~62% (118K/200K) | Button tap fix, Debug logging, Option C, Apple ID Path A | UserSelectionView, ContentView, SettingsView, MainTabView |
| Phase 1.2 - Testing & Polish | TBD | TBD | TBD |

---

## Workflow: How to Use This

### When Starting New Chat
**Your first message should include:**
```
Continuing FamilyHub development.

Key context from DECISIONS.md:
- [List 2-3 most relevant decisions from previous chats]
- [Current phase focus]
- [Any open questions to resolve]

Current task: [What you're working on]
```

### During Any Chat
**When making a decision:**
1. Stop and update DECISIONS.md immediately
2. Commit the change to git
3. Reference in chat: "Documented in DECISIONS.md"

### When Switching Phases
1. **User:** Create handoff document
2. **Assistant:** Update DECISIONS.md with any decisions from current chat
3. **Assistant:** Git commit
4. **User:** Start new chat with context from DECISIONS.md

---

## Additional Tracking Documents

### 1. DECISIONS.md (Strategic)
**What:** Architectural and design decisions
**When:** Any time we make a choice that affects future work
**Who Updates:** Assistant (with user guidance)

### 2. PROJECT_STATUS.md (Tactical)
**What:** Current implementation status, what's working/broken
**When:** End of each coding session
**Who Updates:** Assistant

### 3. Phase Handoff Documents (Transition)
**What:** Context for moving between chats
**When:** When switching to new phase chat
**Who Updates:** User (creates these)

### 4. CHANGELOG.md (History)
**What:** Version history, what changed when
**When:** Each git commit or release
**Who Updates:** Assistant

---

## Current Status

### Phase 1.1 Progress
- ✅ Git repository initialized
- ✅ All SwiftData models implemented
- ✅ Core services (DataService, TimetableCalculator, PDFService)
- ✅ User selection flow with Liquid Glass design
- ✅ Main tab navigation structure
- ✅ Placeholder views (Dashboard, Timetable, Settings)
- ✅ Xcode project created and building successfully
- ✅ Fixed duplicate folder issues
- ✅ Fixed Material/listRowBackground compatibility
- ✅ Fixed import statements (SwiftData)
- ✅ Implemented Button-based tap with visual feedback
- ✅ Added comprehensive debug logging
- 🔍 **Current Issue:** Navigation from user selection to MainTabView not working (under investigation)

### Next Immediate Tasks
1. Run app in simulator with debug logging enabled
2. Capture console output when tapping user card
3. Diagnose where navigation flow breaks
4. Fix the binding/state issue preventing navigation
5. Remove debug logging once fixed
6. Complete Phase 1.1 testing
7. Commit all changes to git

---

**Last Updated:** 12 November 2025, 10:00
**Current Phase:** 1.1 - Build Fixes & Testing
**Token Usage:** ~62% (118K/200K used)
