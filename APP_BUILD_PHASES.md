# FamilyHub - App Build Phases

**Master tracking document for all development phases**

**Last Updated:** 2025-11-13 (Current session)
**Current Phase:** Phase 2.3 - Today View & Current Period Tracking (Complete)
**Project Location:** `~/Development/Apps/ios/familyhub-ios/`

---

## Phase Overview

### Phase 1: Foundation & Setup
- [x] **Phase 1.1** - Build Fixes ✅ *Complete*
- [x] **Phase 1.2** - Testing & Polish ✅ *Complete*

### Phase 2: Timetable Module
- [x] **Phase 2.1** - Timetable Views (Day, Week, Fortnight) ✅ *Complete*
- [x] **Phase 2.2** - CSV Import & Data Management ✅ *Complete*
- [x] **Phase 2.3** - Today View & Current Period Tracking ✅ *Complete*

### Phase 3: Settings & Polish
- [ ] **Phase 3.1** - Settings Implementation
- [ ] **Phase 3.2** - Final Testing & TestFlight Prep

### Phase 4: Authentication (Learning Exercise)
- [ ] **Phase 4.1** - Sign in with Apple Integration

### Phase 5: Health Integration (Fitness App Prep)
- [ ] **Phase 5.1** - HealthKit Setup & Permissions
- [ ] **Phase 5.2** - Health Data Display

---

## Phase 1.2 - Testing & Polish ✅ COMPLETE

### Status: Complete (12 Nov 2025)

### Completed Tasks
- [x] Add "Switch User" button to Settings
- [x] Create all three users (Amelia, Rachel, Andy)
- [x] Test switching between users
- [x] Thoroughly test all screens (light/dark mode)
- [x] Verify empty states display correctly
- [x] Check animations and transitions
- [x] Remove debug logging
- [x] Complete Phase 1 foundation git commit

### Test Results
✅ **Switch User functionality working perfectly**
✅ **All three test users created automatically on first launch**
✅ **Light/dark mode verified and rendering correctly**
✅ **Empty states displaying correctly** (Today and Timetable views)
✅ **Animations smooth and polished** (tab transitions, user selection)
✅ **Navigation flow verified** (user selection → tabs → switch user → back)

### Git Commits (Phase 1.2)
```
[commit-hash] - polish: remove debug logging from production code
faeeb74 - feat(phase-1.2): add user switching and test data setup
```

### What's Ready
- User selection with three test users
- Switch User button in Settings
- All navigation working smoothly
- Project configured (iOS 17.0, iCloud, correct bundle ID)
- Clean, production-ready code

### Ready for Phase 2.1
Phase 1 foundation is solid and fully tested. Ready to implement timetable views.

---

## Phase 2.1 - Timetable Views ✅ COMPLETE

### Status: Complete (12 Nov 2025)

### Completed Tasks
- [x] Implement TimetableModuleView with empty state
- [x] Create sample data generator for testing (50 entries)
- [x] Implement Day View with current period highlighting
- [x] Implement Week View with all weekdays
- [x] Implement Fortnight View with side-by-side comparison
- [x] Add Week 1/2 selector with toggle functionality
- [x] Add view mode picker (Day | Week | Fortnight)
- [x] Implement TimetableValidator for data integrity checks
- [x] Add "Load Sample Data" button for development testing
- [x] Create TESTING_GUIDE.md with comprehensive test scenarios
- [x] Test all three view modes with sample data
- [x] Verify week switching functionality
- [x] Verify current period detection logic

### Test Results
✅ **Sample data loading works perfectly** (50 entries, 25 per week)
✅ **Day view displays correctly** with period cards and time display
✅ **Week view shows all 5 weekdays** with entry counts and period details
✅ **Fortnight view side-by-side comparison** working with Week 1/Week 2 indicators
✅ **Week toggle functionality** switches between Week 1 (purple) and Week 2 (green)
✅ **View mode picker** smoothly transitions between Day/Week/Fortnight
✅ **TimetableValidator** reports correct entry counts and identifies issues
✅ **Empty state displays** when no timetable data exists

### Implementation Highlights

**Views Created:**
- `TimetableModuleView.swift` - Main container with empty state, PDF picker, sample data loader
- `DayView.swift` - Single day schedule with current period highlighting
- `WeekView.swift` - Full week (Mon-Fri) with all periods
- `FortnightView.swift` - Side-by-side Week 1 and Week 2 comparison
- `WeekSelector.swift` - Week 1/2 toggle with calculated week display

**Services Created:**
- `SampleTimetableData.swift` - Generates 50 realistic timetable entries for testing
- `TimetableValidator.swift` - Validates data integrity and generates reports
- `TimetableCalculator.swift` - Calculates current week based on start date

**Key Features:**
- **Sample Data**: 50 entries covering 2 weeks × 5 days with realistic subjects, teachers, rooms
- **Week Detection**: Automatic calculation of Week 1 vs Week 2 based on start date
- **Current Period**: Blue highlighting for active period during school hours (09:00-14:25)
- **Validation**: Console reports showing entry counts, distribution, and any issues
- **Empty State**: User-friendly import prompt with "Load Sample Data" dev button

### What's Ready
- All three timetable views fully implemented and tested
- Sample data generator for development/testing
- Week 1/2 logic foundation in place
- Validation and debugging tools
- Empty state with PDF import prompt
- TESTING_GUIDE.md documentation

### Ready for Phase 2.2
Phase 2.1 foundation is complete. All views are working with sample data. Now ready to implement PDF import functionality to populate real timetable data.

---

## Phase 2.3 - Today View & Current Period Tracking ✅ COMPLETE

### Status: Complete (13 Nov 2025)

### Overview
Phase 2.3 implemented the Today view dashboard card with real-time current period tracking, including breaks and lunch periods. Extended highlighting and auto-scroll functionality to all timetable views.

### Completed Tasks
- [x] Create TodayScheduleCard component for Dashboard
- [x] Implement ScheduleItem enum to mix periods, breaks, and lunch
- [x] Add fixed period times to TimetableCalculator (UK school schedule)
- [x] Implement break detection (10:45-11:05, 20 min)
- [x] Implement lunch detection (13:05-13:35, 30 min)
- [x] Add "Now" badge for current period/break/lunch
- [x] Implement blue accent highlighting for current items
- [x] Add current period highlighting to Day view
- [x] Add current period highlighting to Week view
- [x] Implement auto-scroll to current period (Day & Week views)
- [x] Unify card design across all views
- [x] Test and verify highlighting during lesson times

### Implementation Highlights

**TodayScheduleCard Features:**
- Shows all periods with breaks and lunch inserted at correct times
- Break after Period 2 (10:45-11:05)
- Lunch after Period 4 (13:05-13:35)
- Real-time highlighting of current period/break/lunch
- "Now" badge with blue background for active items
- Consistent card design matching timetable views

**Current Period Detection:**
- Fixed period times in TimetableCalculator.periodTimes dictionary
- Time-based detection using isTimeBetween() method
- Week and day validation for accurate highlighting
- Falls back to period times if entry times not set

**Auto-Scroll Functionality:**
- ScrollViewReader wraps all scrollable views
- Automatically scrolls to current period on view appear
- Falls back to first entry if no current period (during breaks/lunch)
- Smooth animation with 0.1s delay for reliable rendering

**Design Consistency:**
- Time column (50pt fixed width, right-aligned)
- Start/end times stacked vertically
- Vertical accent bar (3pt) - blue when current
- "Now" badge with blue background
- Subtle blue tint (0.08 opacity) for current period background
- Teacher names shown in Week/Day views (not in Today view)

### Key Files Modified
- `TodayScheduleCard.swift` - Today dashboard card with breaks/lunch
- `TimetableCalculator.swift` - Fixed period times and time detection
- `DayView.swift` - Current period highlighting and auto-scroll
- `WeekView.swift` - Current period highlighting and auto-scroll
- `DashboardView.swift` - Integration of TodayScheduleCard

### Design Decision: Breaks/Lunch Display
**Decision:** Show breaks and lunch ONLY on Today tab, NOT on Timetable views

**Rationale:**
- Today tab = Real-time schedule ("What's happening now?")
- Timetable tab = Reference schedule ("What classes do I have?")
- Cleaner timetable views without break clutter
- Easier to scan and compare days/weeks
- Separation of concerns: real-time vs reference

### Test Results
✅ **Today view shows breaks and lunch** between periods
✅ **Current period highlighting works** during lesson times (time-based)
✅ **Break highlighting works** during 10:45-11:05
✅ **Lunch highlighting works** during 13:05-13:35
✅ **Auto-scroll works** in Day and Week views
✅ **Design consistent** across all views
✅ **No highlighting during breaks** in Timetable views (correct behavior)

### What's Ready
- Complete Today view with real-time tracking
- Current period highlighting across all views
- Auto-scroll to current lesson
- Unified design system
- Production-ready code (debug logging removed)

### Ready for Phase 3
Phase 2.3 completes the core timetable functionality. App now has:
- Full timetable views (Day, Week, Fortnight)
- CSV import functionality
- Real-time current period tracking
- Today dashboard with breaks/lunch
- Auto-scroll and highlighting
Ready for Settings implementation and final polish.

---

## Phase 2.2 - Data Import & Manual Entry ✅ COMPLETE

### Status: In Progress (12 Nov 2025)

### Overview
Phase 2.2 implements multiple timetable data import methods and comprehensive manual entry capabilities. This phase was redesigned from PDF OCR (unreliable for scanned images) to robust multi-source import system.

### Phase 2.2a - CSV File Import (Week 1)

**Tasks:**
- [ ] Create CSVParser service to parse standard CSV format
- [ ] Implement file picker for CSV selection
- [ ] Build ImportPreviewView to show data before commit
- [ ] Add validation for Week/Day/Period values
- [ ] Handle malformed CSV gracefully (warn, import valid rows)
- [ ] Create ImportResultView showing success/errors
- [ ] Test with Amelia's timetable CSV
- [ ] Update existing import button to offer CSV option

**CSV Format:**
```csv
Week,Day,Period,Subject,Teacher,Room
1,Monday,AM Registration,KCO,,Room 512
1,Monday,1,English Lang,BBR,Room 053
1,Monday,2,History,ERE,Room 417
```

**Validation Rules:**
- Week: Must be "1" or "2"
- Day: Must be Monday/Tuesday/Wednesday/Thursday/Friday
- Period: Must be "AM Registration", "1"-"5", or "PM Registration"
- Subject: Required (non-empty)
- Teacher: Optional (can be blank)
- Room: Required (non-empty)

### Phase 2.2b - Manual Entry Foundation (Week 2)

**Tasks:**
- [ ] Implement PeriodEditorView (add/edit form)
- [ ] Create Subject/Teacher/Room data models
- [ ] Build ReferenceDataManager service
- [ ] Add CRUD operations for schedule entries
- [ ] Implement recent combinations cache (last 10)
- [ ] Build RecentCombinationsView for quick selection
- [ ] Add basic undo/redo (last 20 actions)
- [ ] Test creating full day manually

**Data Models:**
- Subject: name, shortCode, colourHex, icon, lastUsed
- Teacher: code, fullName, email, lastUsed
- Room: number, building, floor, capacity, lastUsed
- Updated ScheduleEntry: period now String, add optional relationships

### Phase 2.2c - Manual Entry Advanced (Week 3)

**Tasks:**
- [ ] Build ReferenceDataListView (manage subjects/teachers/rooms)
- [ ] Implement autocomplete for all reference fields
- [ ] Create DuplicatePeriodView (copy to other day/week)
- [ ] Build CopyDayView (copy entire day)
- [ ] Build CopyWeekView (copy entire week to other week)
- [ ] Implement ConflictDetector service (same teacher/room/time)
- [ ] Add ConflictWarningView for detected conflicts
- [ ] Build BulkEditView (change all occurrences)
- [ ] Implement full undo/redo tree with branching
- [ ] Add TemplateManager for saving/loading week templates
- [ ] Test all power features thoroughly

**Power Features:**
- Duplicate single period to another day/week
- Copy entire day to another day
- Copy Week 1 to Week 2 (or vice versa)
- Templates: "Save Week 1 as template", "Load from template"
- Bulk edit: Change all "Room 412" to "Library"
- Conflict detection: Warn if same teacher has two classes at once
- Full undo/redo with branching (not just linear)

### Phase 2.2d - Google Sheets Import (Week 4)

**Tasks:**
- [ ] Set up Google Cloud Project and OAuth credentials
- [ ] Implement GoogleAuthService with OAuth 2.0 flow
- [ ] Add GoogleSheetsService for API calls
- [ ] Build GoogleSignInView
- [ ] Create SheetSelectorView (list user's sheets)
- [ ] Implement RangeSelectorView (optional, default A:F)
- [ ] Parse sheet data using same CSV format
- [ ] Store auth token in Keychain
- [ ] Handle token refresh
- [ ] Add "Disconnect Google" in Settings
- [ ] Test with real Google Sheet

**Google Sheets Requirements:**
- OAuth 2.0 with Google Sign-In
- Sheets API v4 access
- Same CSV format as file import
- Authentication persistence in Keychain
- Online-only (show error if offline)
- Default: first sheet, columns A-F
- Optional: sheet selection UI

### Phase 2.2e - Testing & Polish (Week 5)

**Tasks:**
- [ ] Comprehensive testing of CSV import with various formats
- [ ] Test manual entry workflow (create full week from scratch)
- [ ] Test Google Sheets import end-to-end
- [ ] Test bulk operations (copy day, copy week)
- [ ] Verify conflict detection working
- [ ] Test undo/redo for all operations
- [ ] Edge case testing (malformed CSV, empty fields)
- [ ] Performance testing (large timetables)
- [ ] User acceptance testing with Amelia
- [ ] Update TESTING_GUIDE.md with new scenarios
- [ ] Remove debug logging

### Completed Tasks
- [x] Phase 2.1 - All timetable views (Day/Week/Fortnight)
- [x] Import button in TimetableModuleView
- [x] Delete timetable option (3-dot menu)
- [x] Week 1/2 terminology updated throughout

### Ready for Phase 3
Once Phase 2.2 is complete, app will have:
- Multiple robust import methods
- Full manual timetable creation
- Advanced editing capabilities
- Conflict detection
- Template system
- Ready for production use

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
- **In Scope:** Timetable tracking, Week 1/2, multi-user, iCloud sync
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
| 1.2 | Testing & Polish | 68K | 34% | 132K |

**Report thresholds:** 70%, 80%, 90%

**Status:** Well within budget. Phase 1 used 204K total (~102% of single chat budget, but completed across continuation).

---

## Next Phase Preview: 2.3 - Testing & Polish

**Focus:**
- Complete user acceptance testing with real PDF data
- Fix any UI/UX issues discovered during testing
- Optimize performance if needed
- Polish animations and transitions
- Verify all TESTING_GUIDE.md scenarios pass
- Prepare for Phase 3 (Settings implementation)

**Prerequisites:**
- Phase 2.1 complete ✅
- Phase 2.2 PDF import working ⚠️ (blocked on Y-span fix)
- Real timetable data successfully importing
- All three views displaying correctly with real data

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
