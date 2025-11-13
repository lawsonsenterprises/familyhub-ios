# FamilyHub iOS App - Claude Code Setup Instructions

## Context Summary
Building a modular family iOS app. First module: school timetable viewer for Amelia (two-week rotating schedule). Multi-user from start (Amelia, Rachel, Andy). Architecture designed for future modules (calendar, homework, etc.).

## Complete Specification
Full technical specification available at: `/mnt/user-data/uploads/FamilyHub-Project-Specification.md`

**READ THE FULL SPEC FIRST** - It contains all architectural decisions, data models, and implementation details.

## Immediate Tasks

### 1. Project Setup
Create new Xcode project:
- **Product Name:** FamilyHub
- **Team:** Lawsons Enterprises Ltd
- **Bundle ID:** com.lawsonsenterprises.familyhub
- **Interface:** SwiftUI
- **Storage:** SwiftData
- **Include Tests:** Yes
- **iOS Deployment Target:** 17.0+

### 2. Initial File Structure
Create this structure in Xcode:

```
FamilyHub/
├── Core/
│   ├── Models/
│   ├── Services/
│   ├── Protocols/
│   └── Extensions/
├── Features/
│   ├── Launch/
│   ├── UserSelection/
│   ├── Dashboard/
│   ├── Timetable/
│   └── Settings/
├── Shared/
│   ├── Components/
│   └── Theme/
└── Resources/
```

### 3. Phase 1 Implementation (Start Here)

**Step 1: SwiftData Models**
Implement these models (full code in specification):
- `User.swift` (with UserRole enum)
- `TimetableData.swift` (with WeekType enum)
- `ScheduleEntry.swift` (with DayOfWeek enum)
- `UserPreferences.swift` (with ViewMode enum)

**Step 2: Core Services**
- `DataService.swift` - SwiftData container management
- `TimetableCalculator.swift` - Week 1/2 logic
- `PDFService.swift` - PDF import/storage

**Step 3: App Entry Point**
- Configure `FamilyHubApp.swift` with SwiftData container
- Enable iCloud sync

**Step 4: User Selection**
- `UserSelectionView.swift` - Family member picker
- `UserCardView.swift` - Individual user cards

### 4. Phase 2: Timetable Module

**Phase 2.1 - Timetable Views:** ✅ COMPLETE
- All views implemented (Day, Week, Fortnight)
- Sample data generator working
- Week 1/2 selector functional
- Import button and delete option present

**Phase 2.2 - Data Import & Manual Entry:** 🚧 IN PROGRESS

**New Data Models Required:**

1. `Subject.swift` - Subject reference data
2. `Teacher.swift` - Teacher reference data
3. `Room.swift` - Room reference data
4. Update `ScheduleEntry.swift`:
   - Change `period` from `Int` to `String`
   - Add `subjectName: String`
   - Add `teacherCode: String?`
   - Add `roomNumber: String`
   - Add optional relationships to Subject/Teacher/Room

**Phase 2.2a - CSV File Import:**

Services:
- `CSVParser.swift` - Parse CSV to ScheduleEntry objects
- `ImportValidator.swift` - Validate CSV data
- `ReferenceDataManager.swift` - Manage Subject/Teacher/Room auto-creation

Views:
- `CSVImportView.swift` - File picker and import flow
- `ImportPreviewView.swift` - Show parsed data before import
- `ImportResultView.swift` - Show success/error summary

**Phase 2.2b - Manual Entry Foundation:**

Views:
- `PeriodEditorView.swift` - Add/edit single period form
- `RecentCombinationsView.swift` - Quick select from recent entries

Services:
- `RecentCombinationsCache.swift` - Store last 10 used combinations
- `UndoRedoManager.swift` - Basic undo/redo stack (20 actions)

**Phase 2.2c - Manual Entry Advanced:**

Views:
- `ReferenceDataListView.swift` - Manage subjects/teachers/rooms
- `AutocompleteView.swift` - Autocomplete dropdown component
- `DuplicatePeriodView.swift` - Copy period to other day/week
- `CopyDayView.swift` - Copy entire day
- `CopyWeekView.swift` - Copy Week 1 ↔ Week 2
- `BulkEditView.swift` - Bulk operations UI
- `ConflictWarningView.swift` - Show scheduling conflicts
- `TemplateManagerView.swift` - Save/load week templates

Services:
- `ConflictDetector.swift` - Detect scheduling conflicts
- `BulkOperationsManager.swift` - Handle bulk edit operations
- `TemplateManager.swift` - Template save/load logic
- `UndoRedoManager.swift` - Enhanced with branching support

**Phase 2.2d - Google Sheets Import:**

Services:
- `GoogleAuthService.swift` - OAuth 2.0 flow
- `GoogleSheetsService.swift` - Sheets API integration
- `KeychainManager.swift` - Secure token storage

Views:
- `GoogleSignInView.swift` - Sign in with Google
- `SheetSelectorView.swift` - Select sheet from workbook
- `GoogleImportView.swift` - Import flow

Configuration:
- Set up Google Cloud Project
- Configure OAuth consent screen
- Add Google Sign-In SDK
- Add Keychain entitlements

**Testing Checklist:**
- [ ] Import CSV with Amelia's data
- [ ] Manually create full day from scratch
- [ ] Test autocomplete with partial entries
- [ ] Copy period between weeks
- [ ] Copy entire day
- [ ] Copy Week 1 to Week 2
- [ ] Create and load template
- [ ] Test conflict detection (same teacher, two places)
- [ ] Bulk edit all occurrences of a room
- [ ] Undo/redo multiple operations
- [ ] Import from Google Sheets
- [ ] Test with malformed CSV (handle gracefully)

## Key Technical Decisions

| Aspect | Choice | Notes |
|--------|--------|-------|
| Architecture | MVVM + Modular | See specification §2 |
| Storage | SwiftData | iCloud sync enabled |
| Multi-user | Yes, from v1.0 | Each user has own TimetableData |
| PDF Storage | Per-user, in TimetableData model | Parents can view all timetables |
| Week Logic | Auto-calculate from start date + manual override | See TimetableCalculator |

## Critical Implementation Notes

### Week 1/2 Calculation
```swift
// Weeks alternate from a set start date
// If Amelia started on Week 1 on 2nd Sept 2024:
// - 2nd Sept = Week 1 (week 0)
// - 9th Sept = Week 2 (week 1)
// - 16th Sept = Week 1 (week 2)
// Calculate: weeksSinceStart % 2 == 0 ? .week1 : .week2
```

### Multi-User PDF Approach
- Students (Amelia): Import their own PDF timetable
- Parents (Rachel, Andy): View children's timetables, don't import their own
- Implement viewing permissions via `UserRole` enum

### PDF Storage
```swift
// Each user's timetable:
User → TimetableData (relationship) → pdfData: Data?

// Parents can query:
let children = users.filter { $0.role == .student }
// Then access children.timetableData?.pdfData
```

## Build Order (Follow This Sequence)

1. ✅ Models (SwiftData schema)
2. ✅ Services (DataService, TimetableCalculator, PDFService)
3. ✅ App configuration (FamilyHubApp.swift with SwiftData)
4. ✅ User selection screen
5. ✅ Timetable Day view (simplest)
6. ✅ Timetable Week view
7. ✅ Timetable Fortnight view
8. ✅ PDF import functionality
9. ✅ Week 1/2 toggle
10. ✅ Settings screen
11. ✅ Dashboard/Home screen
12. ✅ Testing & polish
13. ✅ TestFlight deployment

## Sample Data

### Amelia's Timetable Structure (from PDF)
- **Format:** Two-week rotation (Week 1 & Week 2)
- **Days:** Monday - Friday
- **Periods:** Varies by day (typically 5-6 periods)
- **Content:** Subject, Room, Teacher (e.g., "Maths, Room 12, KCO")

PDF attached in original chat - will be imported in the app.

## Common Pitfalls to Avoid

1. **Don't hardcode week logic** - Use TimetableCalculator service
2. **Don't skip SwiftData relationships** - User ↔ TimetableData properly linked
3. **Handle nil PDFs gracefully** - Show "Import PDF" state
4. **Test week calculation thoroughly** - Edge cases around date boundaries
5. **Don't forget iCloud entitlements** - Required for SwiftData cloud sync

## Development Principles

- **British English spelling** throughout (colour, organisation, etc.)
- **£ currency symbol** for any future pricing features
- **Do it right first time** - Andy prefers proper architecture upfront
- **Test on device** - Don't rely solely on simulator
- **Commit frequently** - Follow git commit conventions in spec

## Success Criteria (MVP)

✅ Multi-user support (Amelia, Rachel, Andy)
✅ PDF import working
✅ Week 1/2 toggle functional
✅ All three view modes (Day, Week, Fortnight)
✅ Current period highlighting
✅ Parents can view Amelia's timetable
✅ Settings for week start date
✅ Deployed to TestFlight

## Next Steps After MVP

Version 2.0 will add:
- Calendar integration module
- Homework tracker
- Push notifications
- Today widget

But focus on v1.0 first!

---

## To Claude Code: Start Here

1. **Read the full specification** (`FamilyHub-Project-Specification.md`)
2. **Create Xcode project** with settings above
3. **Implement Phase 1** (Foundation) following the build order
4. **Test incrementally** - don't build everything before testing
5. **Ask questions** if anything in the spec is unclear

The specification is comprehensive. Everything you need is documented. Build with quality in mind - this is for real users (Amelia and family).

**Original timetable PDF** is in the chat history - reference it when testing PDF import.

Good luck! 🚀
