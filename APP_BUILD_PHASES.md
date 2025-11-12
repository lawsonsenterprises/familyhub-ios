# FamilyHub - App Build Phases

**Master tracking document for all development phases**

**Last Updated:** 2025-11-12 11:15 GMT
**Current Phase:** Phase 1.2 - Testing & Polish
**Project Location:** `~/Development/Apps/ios/familyhub-ios/`

---

## Phase Overview

### Phase 1: Foundation & Setup
- [x] **Phase 1.1** - Build Fixes ✅ *Complete*
- [ ] **Phase 1.2** - Testing & Polish ← **YOU ARE HERE**

### Phase 2: Timetable Module
- [ ] **Phase 2.1** - Timetable Views (Day, Week, Fortnight)
- [ ] **Phase 2.2** - PDF Import & Week A/B Logic

### Phase 3: Settings & Polish
- [ ] **Phase 3.1** - Settings Implementation
- [ ] **Phase 3.2** - Final Testing & TestFlight Prep

### Phase 4: Authentication (Learning Exercise)
- [ ] **Phase 4.1** - Sign in with Apple Integration

### Phase 5: Health Integration (Fitness App Prep)
- [ ] **Phase 5.1** - HealthKit Setup & Permissions
- [ ] **Phase 5.2** - Health Data Display

---

## Current Phase: 1.2 - Testing & Polish

### Status: In Progress

### Primary Goals
1. [ ] Add "Switch User" button to Settings
2. [ ] Create all three users (Amelia, Rachel, Andy)
3. [ ] Test switching between users
4. [ ] Thoroughly test all screens (light/dark mode)
5. [ ] Verify empty states display correctly
6. [ ] Check animations and transitions
7. [ ] Remove debug logging
8. [ ] Complete Phase 1 foundation git commit

### Secondary Goals (If Time)
- [ ] Polish spacing, typography, colours
- [ ] Verify accessibility (VoiceOver, Dynamic Type)
- [ ] Test edge cases (long names, special characters)
- [ ] Performance check (smooth 60fps)

---

## Phase 1.1 - Build Fixes ✅ COMPLETE

### Completed Tasks
- [x] Initialize git repository and documentation
- [x] Create Xcode project structure
- [x] Implement all SwiftData models
- [x] Implement core services
- [x] Create user selection flow with Liquid Glass design
- [x] Fix 20+ build errors (duplicates, imports, Material usage)
- [x] Implement Button-based tap with visual feedback
- [x] Add comprehensive debug logging
- [x] Create DECISIONS.md master log
- [x] App builds and runs successfully
- [x] User selection and tab navigation working
- [x] Dark mode verified

### Git Commits (Phase 1.1)
```
67bf8e2 - feat(foundation): implement core architecture and UI components
a75b2a4 - docs: add comprehensive project status document
c5c8b7e - build: Add Xcode project and integrate source files
303640e - docs: Add Phase 1.2 handoff document
a91adcb - docs: Remove Phase 1.2 handoff document
```

---

## Key Project Information

### Project Details
| Setting | Value |
|---------|-------|
| **App Name** | FamilyHub |
| **Bundle ID** | com.lawsonsenterprises.familyhub |
| **Organization** | Lawsons Enterprises Ltd |
| **Developer** | Andy Lawson, London, UK |
| **Platform** | iOS 17.0+ |
| **Design System** | Liquid Glass (Apple 2025) |
| **Language** | British English throughout |

### Users
- **Amelia** - Student (primary user, timetable tracking)
- **Rachel** - Mum (parent, family overview)
- **Andy** - Dad (parent, family overview)

### Current App State

**What Works ✅**
- User creation and selection
- Tab navigation (Today, Timetable, Settings)
- Settings screen with user profile
- Light/dark mode switching
- Liquid Glass design rendering
- Navigation between views

**What's Empty (Expected) 📋**
- Today view (no timetable data yet - Phase 2)
- Timetable view (no PDF imported yet - Phase 2)
- Notifications settings (v2.0+ feature)
- Week Configuration (Phase 2 feature)

**What's Missing (To Add) ⚠️**
- Switch User functionality
- Multiple test users
- Debug logging cleanup

---

## Critical Decisions (from DECISIONS.md)

### Architecture
- **MVVM with SwiftUI** - Standard iOS pattern, modular design
- **Button-based tap** - More reliable than onTapGesture
- **SwiftData + iCloud** - Local-first with automatic sync

### Key Product Decisions
- **PDF Permissions (Option C)** - Any family member can import/manage any student's timetable
- **Authentication (Path A)** - Ship MVP first (Phase 1-3), then add Apple ID (Phase 4)
- **Profile Photos** - Deferred to v1.1+ (after MVP)
- **HealthKit** - Phase 5 feature (fitness app prep)

### Scope
- **In Scope:** Timetable tracking, Week A/B, multi-user, iCloud sync
- **Out of Scope:** Backend, multi-family support, complex auth (until Phase 4)
- **Future:** Sign in with Apple (Phase 4), HealthKit (Phase 5)

---

## Reference Documents

**Available in Project (`/mnt/project/`):**
1. `FamilyHub-Project-Specification.md` - Complete technical spec
2. `iOS-Apple-Best-Practices-2025.md` - Primary iOS design guide
3. `FamilyHub-Apple-Best-Practices.md` - App-specific customizations
4. `DECISIONS.md` - **Master decision log** (READ THIS FIRST)
5. `AmeliaTimeTable09112025.PDF` - Sample timetable for Phase 2

**In Repository:**
- `README.md` - Project overview
- `docs/ARCHITECTURE.md` - Detailed architecture
- `docs/CHANGELOG.md` - Version history
- `PROJECT_STATUS.md` - Current status
- `DEBUG_LOGGING_GUIDE.md` - Testing instructions

---

## Phase 1.2 Implementation Notes

### Switch User Button Implementation

**Approach:** Add @Binding to views to pass selectedUser state down

**Required Changes:**
1. **ContentView.swift** - Already has `@State private var selectedUser: User?`
2. **MainTabView.swift** - Add `@Binding var selectedUser: User?` parameter
3. **SettingsView.swift** - Add `@Binding var selectedUser: User?` parameter
4. **Switch User action** - Set `selectedUser = nil` to return to UserSelectionView

**Code Pattern:**
```swift
// In SettingsView
Section {
    Button {
        selectedUser = nil // This returns to UserSelectionView
        HapticManager.light()
    } label: {
        Label("Switch User", systemImage: "arrow.left.arrow.right")
    }
}
```

### Debug Logging Cleanup

**Files with print statements:**
- `ContentView.swift` (lines 19, 23, 26, 29)
- `UserSelectionView.swift` (lines 21, 39-41, 96-97, 100-101)

**Search patterns to remove:**
- `print("📱`
- `print("👥`
- `print("🔵`
- `print("🟠`
- `print("🟢`
- `print("🟡`
- `let _ = print(`

---

## Token Usage Tracking

| Phase | Chat | Tokens Used | % Used | Remaining |
|-------|------|-------------|--------|-----------|
| 1.1 | Build Fixes | 136K | 68% | 64K |
| 1.2 | Testing & Polish | TBD | TBD | TBD |

**Report thresholds:** 70%, 80%, 90%

---

## Next Phase Preview: 2.1 - Timetable Views

**Focus:**
- Empty state designs for timetable views
- Week A/B navigation UI
- Day view (today's classes)
- Week view (Monday-Friday)
- Fortnight view (both weeks side-by-side)
- Current period highlighting

**Prerequisites:**
- Phase 1 foundation complete ✅
- Switch User working
- All debugging cleaned up
- Git commit with clean state

---

## Reminders & Best Practices

### Development Standards
- ✅ **British English** spelling throughout (colour, organisation, etc.)
- ✅ **Production quality** - No shortcuts or placeholder code
- ✅ **Liquid Glass design** - Follow iOS 2025 standards
- ✅ **Accessibility** - VoiceOver labels, Dynamic Type support
- ✅ **WCAG AA** - 4.5:1 contrast minimum

### Git Workflow
- ✅ **Frequent commits** with clear messages
- ✅ **Conventional commits** format (feat, fix, docs, style, refactor, test)
- ✅ **Update DECISIONS.md** when making architectural choices

### Documentation
- ✅ **Update this file** when completing phases
- ✅ **Document decisions** in DECISIONS.md
- ✅ **Keep PROJECT_STATUS.md current**

---

## Chat Naming Convention

Use this format for all development chats:

```
FamilyHub Phase 1.1 - Build Fixes
FamilyHub Phase 1.2 - Testing & Polish
FamilyHub Phase 2.1 - Timetable Views
FamilyHub Phase 2.2 - PDF Import
FamilyHub Phase 3.1 - Settings Implementation
FamilyHub Phase 4.1 - Sign in with Apple
FamilyHub Phase 5.1 - HealthKit Setup
```

---

## Starting a New Phase

### Before Starting
1. [ ] Commit all current changes
2. [ ] Update DECISIONS.md with any new decisions
3. [ ] Update this file (mark current phase complete)
4. [ ] Review next phase scope

### When Starting New Chat
**Paste this context:**
```
Continuing FamilyHub development.

Current phase: [Phase X.X - Name]
Previous phase: [Phase X.X - Name] ✅ Complete

Key context from DECISIONS.md:
- [List 2-3 most relevant decisions]

Current status from APP_BUILD_PHASES.md:
- [Brief status summary]

Project location: ~/Development/Apps/ios/familyhub-ios/

Ready to begin Phase X.X tasks.
```

---

**Document Type:** Master Phase Tracker
**Status:** Living Document (update after each phase)
**Created:** 2025-11-12
**Author:** Andy Lawson, Lawsons Enterprises Ltd
