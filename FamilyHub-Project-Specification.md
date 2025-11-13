# FamilyHub iOS App - Project Specification & Setup Instructions

## Project Overview

**App Name:** FamilyHub  
**Primary User:** Amelia (school timetable tracking)  
**Secondary Users:** Rachel (mum), Andy (dad)  
**Platform:** iOS (SwiftUI)  
**Distribution:** TestFlight → App Store (future)  
**Development Approach:** Claude Code + Xcode

## Core Concept

A modular family app where each family member has their own profile and can use different feature modules. The first module is a school timetable viewer for Amelia's two-week rotating schedule (Week 1/2). The architecture is designed to easily add new modules (calendar integration, homework tracker, activities, etc.) without major refactoring.

---

## Architecture Overview

### Design Pattern
- **MVVM** (Model-View-ViewModel) with SwiftUI
- **Modular architecture** - each feature is a self-contained module
- **Protocol-oriented** - modules conform to `AppModule` protocol
- **Local-first** with cloud sync capability (iCloud via SwiftData)

### Navigation Structure
```
Launch Screen
└── User Profile Selector (family members)
    └── Tab Navigation
        ├── Dashboard/Home (today's overview)
        ├── Timetable Module
        ├── [Future] Calendar Module
        ├── [Future] Activities Module
        └── Settings
```

---

## Data Architecture

### Technology
- **SwiftData** (modern Apple persistence framework)
- **iCloud sync** enabled by default
- **PDFKit** for PDF handling

### Core Data Models

#### User Model
```swift
@Model
class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var role: UserRole // student, parent
    var avatarData: Data?
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade) var timetableData: TimetableData?
    @Relationship(deleteRule: .cascade) var preferences: UserPreferences?
    
    init(name: String, role: UserRole) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.createdAt = Date()
    }
}

enum UserRole: String, Codable {
    case student
    case parent
}
```

#### TimetableData Model
```swift
@Model
class TimetableData {
    @Attribute(.unique) var id: UUID
    var pdfData: Data?
    var currentWeek: WeekType
    var weekStartDate: Date // Date when Week 1 started
    var lastUpdated: Date
    
    @Relationship var scheduleEntries: [ScheduleEntry]
    @Relationship(inverse: \User.timetableData) var owner: User?
    
    init(owner: User) {
        self.id = UUID()
        self.currentWeek = .week1
        self.weekStartDate = Date()
        self.lastUpdated = Date()
        self.owner = owner
    }
}

enum WeekType: String, Codable, CaseIterable {
    case week1 = "Week 1"
    case week2 = "Week 2"
}
```

#### ScheduleEntry Model (Updated for Import System)
```swift
@Model
class ScheduleEntry {
    @Attribute(.unique) var id: UUID
    var dayOfWeek: DayOfWeek
    var period: String                  // CHANGED: Now String ("AM Registration", "1"-"5", "PM Registration")
    var week: WeekType

    // String fields - always populated, used for display and import
    var subjectName: String             // "English Lang" - required
    var teacherCode: String?            // "BBR" - optional (nil for Registration)
    var roomNumber: String              // "Room 512" - required

    // Time fields - optional
    var startTime: String?              // "09:00" - optional
    var endTime: String?                // "10:00" - optional

    // Optional relationships to reference data (for advanced features)
    @Relationship var subjectRef: Subject?
    @Relationship var teacherRef: Teacher?
    @Relationship var roomRef: Room?

    @Relationship(inverse: \TimetableData.scheduleEntries)
    var timetableData: TimetableData?

    init(dayOfWeek: DayOfWeek, period: String, subject: String, teacher: String?, room: String, week: WeekType) {
        self.id = UUID()
        self.dayOfWeek = dayOfWeek
        self.period = period
        self.subjectName = subject
        self.teacherCode = teacher
        self.roomNumber = room
        self.week = week
    }
}

enum DayOfWeek: String, Codable, CaseIterable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
}

// Period values enum for validation
enum PeriodValue: String, CaseIterable {
    case amRegistration = "AM Registration"
    case period1 = "1"
    case period2 = "2"
    case period3 = "3"
    case period4 = "4"
    case period5 = "5"
    case pmRegistration = "PM Registration"
}
```

#### UserPreferences Model
```swift
@Model
class UserPreferences {
    @Attribute(.unique) var id: UUID
    var enableNotifications: Bool
    var notificationMinutesBefore: Int
    var preferredViewMode: ViewMode
    
    @Relationship(inverse: \User.preferences) var user: User?
    
    init() {
        self.id = UUID()
        self.enableNotifications = true
        self.notificationMinutesBefore = 10
        self.preferredViewMode = .day
    }
}

enum ViewMode: String, Codable {
    case day
    case week
    case fortnight
}
```

#### Subject Model
```swift
@Model
class Subject {
    @Attribute(.unique) var id: UUID
    var name: String                    // "English Lang", "Mathematics"
    var shortCode: String?              // "ENG", "MATH" - optional
    var colourHex: String?              // For visual colour coding
    var icon: String?                   // SF Symbol name for icon
    var lastUsed: Date                  // For sorting by recency

    @Relationship(inverse: \ScheduleEntry.subjectRef)
    var scheduleEntries: [ScheduleEntry]?

    init(name: String, shortCode: String? = nil) {
        self.id = UUID()
        self.name = name
        self.shortCode = shortCode
        self.lastUsed = Date()
    }
}
```

#### Teacher Model
```swift
@Model
class Teacher {
    @Attribute(.unique) var id: UUID
    var code: String                    // "BBR", "KDN" - teacher code
    var fullName: String?               // "Ms. B. Roberts" - optional full name
    var email: String?                  // Optional contact email
    var lastUsed: Date                  // For sorting by recency

    @Relationship(inverse: \ScheduleEntry.teacherRef)
    var scheduleEntries: [ScheduleEntry]?

    init(code: String, fullName: String? = nil) {
        self.id = UUID()
        self.code = code
        self.fullName = fullName
        self.lastUsed = Date()
    }
}
```

#### Room Model
```swift
@Model
class Room {
    @Attribute(.unique) var id: UUID
    var number: String                  // "Room 512", "Library"
    var building: String?               // "Science Block" - optional
    var floor: Int?                     // Floor number - optional
    var capacity: Int?                  // Room capacity - optional
    var lastUsed: Date                  // For sorting by recency

    @Relationship(inverse: \ScheduleEntry.roomRef)
    var scheduleEntries: [ScheduleEntry]?

    init(number: String) {
        self.id = UUID()
        self.number = number
        self.lastUsed = Date()
    }
}
```

---

## Module System Architecture

### AppModule Protocol
```swift
protocol AppModule: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var iconName: String { get } // SF Symbol name
    var description: String { get }
    var isAvailable: Bool { get }
    
    @ViewBuilder
    func mainView(for user: User) -> any View
    
    @ViewBuilder
    func settingsView(for user: User) -> any View
}
```

### Initial Modules

#### 1. Timetable Module (MVP)
**Purpose:** Display and manage school timetables with Week 1/2 rotation

**Features:**
- PDF import (via Files app or drag-and-drop)
- Week 1/2 toggle with smart detection
- Manual week override capability
- Three view modes: Day, Week, Fortnight
- Current period highlighting
- "What's next" display

**Views:**
- `TimetableModuleView` (main container)
- `DayView` (today's schedule)
- `WeekView` (Monday-Friday for current week)
- `FortnightView` (both weeks side-by-side)
- `PDFImportView` (initial setup)

#### 2. Settings Module (Core)
**Purpose:** User preferences, app settings, PDF management

**Features:**
- User profile management
- Notification preferences
- Week start date configuration
- PDF re-import option
- About/Help

---

## Project Structure

```
FamilyHub/
├── FamilyHubApp.swift                 # App entry point
├── Core/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── TimetableData.swift
│   │   ├── ScheduleEntry.swift
│   │   ├── UserPreferences.swift
│   │   └── Enums.swift
│   ├── Services/
│   │   ├── DataService.swift          # SwiftData container management
│   │   ├── PDFService.swift           # PDF handling
│   │   └── TimetableCalculator.swift  # Week 1/2 logic
│   ├── Protocols/
│   │   └── AppModule.swift
│   └── Extensions/
│       ├── Date+Extensions.swift
│       └── Color+Theme.swift
├── Features/
│   ├── Launch/
│   │   └── LaunchView.swift           # Initial loading screen
│   ├── UserSelection/
│   │   ├── UserSelectionView.swift    # Family member picker
│   │   └── UserCardView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift        # Home/Today overview
│   │   └── DashboardViewModel.swift
│   ├── Timetable/
│   │   ├── TimetableModule.swift      # Module definition
│   │   ├── ViewModels/
│   │   │   └── TimetableViewModel.swift
│   │   ├── Views/
│   │   │   ├── TimetableModuleView.swift
│   │   │   ├── DayView.swift
│   │   │   ├── WeekView.swift
│   │   │   ├── FortnightView.swift
│   │   │   ├── PDFImportView.swift
│   │   │   └── WeekSelectorView.swift
│   │   └── Components/
│   │       ├── PeriodCard.swift
│   │       └── EmptyTimetableView.swift
│   └── Settings/
│       ├── SettingsModule.swift
│       ├── SettingsView.swift
│       └── UserProfileEditView.swift
├── Shared/
│   ├── Components/
│   │   ├── CustomTabBar.swift
│   │   └── LoadingView.swift
│   └── Theme/
│       └── AppTheme.swift
└── Resources/
    ├── Assets.xcassets
    ├── Info.plist
    └── SampleData/
        └── AmeliaTimeTable.pdf         # Initial PDF for testing
```

---

## MVP Scope - Version 1.0 (TestFlight)

### Must Have ✅
1. **Multi-user support**
   - User profile creation (name, role)
   - User selection screen
   - Profile switching

2. **Timetable Module**
   - PDF import per user
   - Week 1/2 toggle
   - Day view (today's classes)
   - Week view (Mon-Fri current week)
   - Fortnight view (both weeks)
   - Current period highlighting
   - Manual week override

3. **Settings**
   - Week start date configuration
   - User profile editing
   - PDF re-import

### Nice to Have (v1.1) 🎯
- Today widget (iOS home screen)
- Notifications for next class
- Dark mode support
- Period time display
- "What's on now" dashboard

### Explicitly Out of Scope (v1.0) ❌
- Calendar integration (v2.0)
- Homework tracking (v2.0)
- Apple Watch companion (v3.0)
- Family shared events (v2.0)

---

## User Flows

### First Time User Experience
1. Launch app → Welcome screen
2. Create first user profile (Amelia)
3. Import PDF timetable
4. Set Week 1 start date
5. View timetable (defaults to Day view)

### Adding Additional Family Members
1. Settings → Add User
2. Enter name, select role (student/parent)
3. If student: Import their timetable PDF
4. If parent: Access to view all family timetables

### Daily Usage - Amelia
1. Open app → Auto-selects Amelia
2. Dashboard shows today's schedule
3. Tap Timetable → See full week
4. Switch to Fortnight view to plan ahead

### Daily Usage - Rachel/Andy
1. Open app → Select profile
2. Dashboard shows Amelia's current/next class
3. Quick view of what she's doing
4. Can switch to their own profile if needed later

---

## Technical Implementation Details

### Week 1/2 Calculation Logic

```swift
class TimetableCalculator {
    static func currentWeek(startDate: Date) -> WeekType {
        let calendar = Calendar.current
        let weeksSinceStart = calendar.dateComponents([.weekOfYear],
                                                      from: startDate,
                                                      to: Date()).weekOfYear ?? 0
        return weeksSinceStart % 2 == 0 ? .week1 : .week2
    }
    
    static func isCurrentPeriod(entry: ScheduleEntry, date: Date) -> Bool {
        // Implementation to check if given period is happening now
        // Based on time ranges and current time
    }
}
```

### Timetable Data Import & Entry

**Import Methods:**

1. **CSV File Import**
   - Standard iOS file picker (UIDocumentPickerViewController)
   - Format: `Week,Day,Period,Subject,Teacher,Room`
   - Validation with helpful error messages
   - Preview screen before confirming import
   - Replaces existing timetable data (with confirmation)

2. **Manual Entry System**
   - Full CRUD for individual schedule entries
   - Reference data management (Subject/Teacher/Room databases)
   - Autocomplete for all fields
   - Recent combinations memory (quick re-use)
   - Bulk operations:
     - Duplicate period to another day/week
     - Copy entire day to another day
     - Copy Week 1 to Week 2 (or vice versa)
   - Template system (save/load week configurations)
   - Conflict detection (same teacher/room at same time)
   - Full undo/redo tree with branching

3. **Google Sheets Import**
   - OAuth 2.0 authentication (Sign in with Google)
   - Google Sheets API v4 integration
   - Sheet selection UI (if multiple sheets in workbook)
   - Same CSV format as file import
   - Authentication persistence (Keychain)
   - Online-only (requires internet connection)

**Import Strategy:**
- All imports replace existing timetable data (prevents merge conflicts)
- User confirms before replacement
- Manual edits can be made after any import
- Reference data (Subject/Teacher/Room) auto-created on import
- Validation warnings shown but doesn't block import of valid rows

**CSV Format Specification:**
```csv
Week,Day,Period,Subject,Teacher,Room
1,Monday,AM Registration,KCO,,Room 512
1,Monday,1,English Lang,BBR,Room 053
1,Monday,2,History,ERE,Room 417
1,Monday,3,PE,MRO,Room 7
1,Monday,4,Computer Sc,ALW,Room 247
1,Monday,PM Registration,KCO,,Room 512
1,Monday,5,Mathematics,KDN,Room 113
```

**Validation Rules:**
- Week: "1" or "2"
- Day: "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
- Period: "AM Registration", "1", "2", "3", "4", "5", "PM Registration"
- Subject: Required (non-empty string)
- Teacher: Optional (can be blank/empty)
- Room: Required (non-empty string)

### SwiftData Configuration

```swift
@main
struct FamilyHubApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            TimetableData.self,
            ScheduleEntry.self,
            UserPreferences.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic // iCloud sync
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

---

## Design Guidelines

### Design System: Apple 2025 + Liquid Glass

**Core Principle:** Follow Apple's Human Interface Guidelines and embrace Liquid Glass design language for a modern, native iOS 18/19 feel.

**Key Resources:**
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines
- Adopting Liquid Glass: https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass
- Applying Liquid Glass to SwiftUI: https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views
- Materials & Depth: https://developer.apple.com/design/human-interface-guidelines/materials

### Liquid Glass Implementation

**What is Liquid Glass:**
- Apple's 2025 design language
- Translucent, depth-aware materials
- Dynamic, context-sensitive backgrounds
- Smooth, fluid animations
- Enhanced visual hierarchy through depth

**Where to Apply:**
- **Timetable cards** - Use glass material for period cards with depth
- **Navigation bars** - Translucent materials that adapt to content
- **Tab bars** - Glass effect with proper blur
- **Modals/Sheets** - Appropriate material thickness
- **Week selector** - Glass segmented control style
- **Settings panels** - Grouped lists with glass backgrounds

**SwiftUI Implementation:**
```swift
// Liquid Glass card example
VStack {
    // Content
}
.background(.regularMaterial) // or .thinMaterial, .thickMaterial
.clipShape(RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.1), radius: 10, y: 5)
```

### Colour Palette

**System Colours (Primary):**
```swift
extension Color {
    // Use semantic colours that adapt to light/dark mode
    static let primaryApp = Color.blue        // iOS system blue
    static let secondaryApp = Color.cyan      // Accent colour
    static let accentApp = Color.orange       // Call-to-action
    
    // Week identification
    static let week1 = Color.purple           // Week 1 indicator
    static let week2 = Color.green            // Week 2 indicator
    
    // Semantic colours
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
}
```

**Adaptive Colours:**
- All colours must support both light and dark mode
- Use system colour palette where possible
- Maintain WCAG AA contrast ratios (4.5:1 for text)

### Typography

**SF Pro (Apple's system font):**
```swift
// Headers
.font(.largeTitle)      // 34pt, Bold - Screen titles
.font(.title)           // 28pt, Bold - Section headers
.font(.title2)          // 22pt, Bold - Card headers
.font(.title3)          // 20pt, Semibold - Subsection headers

// Body
.font(.body)            // 17pt, Regular - Primary content
.font(.callout)         // 16pt, Regular - Secondary content
.font(.subheadline)     // 15pt, Regular - Tertiary content
.font(.footnote)        // 13pt, Regular - Captions
.font(.caption)         // 12pt, Regular - Timestamps

// Specialized
.font(.headline)        // 17pt, Semibold - Emphasis
.fontWeight(.medium)    // For timetable entries
```

**Dynamic Type:**
- Support all dynamic type sizes
- Test with accessibility sizes (AX1-AX5)
- Use `.minimumScaleFactor()` where space-constrained

### Spacing & Layout

**Based on 8pt grid system:**
```swift
// Standard spacing scale
enum Spacing {
    static let xxs: CGFloat = 4      // Tight spacing
    static let xs: CGFloat = 8       // Compact spacing
    static let sm: CGFloat = 12      // Small spacing
    static let md: CGFloat = 16      // Standard spacing (most common)
    static let lg: CGFloat = 24      // Section spacing
    static let xl: CGFloat = 32      // Large section spacing
    static let xxl: CGFloat = 48     // Screen-level spacing
}

// Card specifications
enum CardMetrics {
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 16
    static let shadowRadius: CGFloat = 10
    static let shadowY: CGFloat = 5
}
```

**Safe Areas:**
- Always respect safe area insets
- Use `.safeAreaInset()` for overlays
- Test on iPhone with notch/Dynamic Island
- Test on iPhone SE (compact width)

### Materials & Depth

**Material Hierarchy:**
```swift
// Background to foreground
.ultraThinMaterial      // Subtle, far background
.thinMaterial           // Light background
.regularMaterial        // Standard cards (most common)
.thickMaterial          // Prominent overlays
.ultraThickMaterial     // Modal sheets, alerts
```

**Shadow & Elevation:**
```swift
// Standard card shadow
.shadow(color: .black.opacity(0.08), radius: 10, y: 5)

// Elevated card (interactive/selected)
.shadow(color: .black.opacity(0.12), radius: 15, y: 8)

// Floating action (buttons)
.shadow(color: .black.opacity(0.15), radius: 20, y: 10)
```

### Animation & Interaction

**Timing:**
```swift
// Standard durations
enum AnimationDuration {
    static let instant: Double = 0.1      // Immediate feedback
    static let quick: Double = 0.2        // Button taps
    static let standard: Double = 0.3     // Most transitions
    static let leisurely: Double = 0.5    // Modal presentations
}

// Easing curves
Animation.easeOut         // Most common
Animation.spring(         // Playful interactions
    response: 0.3,
    dampingFraction: 0.7
)
```

**Haptic Feedback:**
```swift
// Provide haptic feedback for key interactions
UIImpactFeedbackGenerator(style: .light).impactOccurred()    // Selection
UIImpactFeedbackGenerator(style: .medium).impactOccurred()   // Action
UINotificationFeedbackGenerator().notificationOccurred(.success)  // Completion
```

### Component Specifications

**Timetable Period Card:**
```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Mathematics")
        .font(.headline)
    HStack {
        Text("Room 12")
            .font(.subheadline)
            .foregroundColor(.secondary)
        Spacer()
        Text("KCO")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}
.padding(16)
.background(.regularMaterial)
.clipShape(RoundedRectangle(cornerRadius: 16))
.shadow(color: .black.opacity(0.08), radius: 10, y: 5)
```

**Week Selector (Segmented Control):**
```swift
Picker("Week", selection: $selectedWeek) {
    Text("Week 1").tag(WeekType.week1)
    Text("Week 2").tag(WeekType.week2)
}
.pickerStyle(.segmented)
.background(.thinMaterial)
```

### Accessibility

**VoiceOver:**
- All interactive elements have `.accessibilityLabel()`
- Use `.accessibilityHint()` for complex interactions
- Logical accessibility order with `.accessibilityElement(children: .combine)`

**Dynamic Type:**
- All text scales with user preferences
- Test at largest accessibility sizes
- Layout remains usable at all sizes

**Colour Contrast:**
- Minimum 4.5:1 ratio for body text
- 3:1 for large text (18pt+)
- Don't rely solely on colour to convey information

**Reduce Motion:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation? {
    reduceMotion ? nil : .easeOut
}
```

---

## Development Phases

### Phase 1: Foundation (Week 1)
- [ ] Xcode project setup
- [ ] SwiftData models implementation
- [ ] Core services (DataService, PDFService)
- [ ] Basic navigation structure
- [ ] User selection screen

### Phase 2: Timetable Module (Week 1-2)
- [ ] PDF import functionality
- [ ] Week 1/2 toggle logic
- [ ] Day view implementation
- [ ] Week view implementation
- [ ] Fortnight view implementation
- [ ] Current period highlighting

### Phase 3: Polish & Settings (Week 2)
- [ ] Settings screen
- [ ] User profile editing
- [ ] Week start date configuration
- [ ] Dashboard/Home screen
- [ ] Icon and launch screen

### Phase 4: TestFlight (Week 2)
- [ ] Testing on physical devices
- [ ] Bug fixes
- [ ] TestFlight upload
- [ ] Initial deployment to Amelia/Rachel/Andy

---

## Testing Strategy

### Manual Testing Checklist
- [ ] Create multiple users (Amelia, Rachel, Andy)
- [ ] Import PDF for Amelia
- [ ] Verify Week 1/2 calculation accuracy
- [ ] Test all three view modes (Day, Week, Fortnight)
- [ ] Switch between users
- [ ] Edit user profiles
- [ ] Re-import PDF
- [ ] Test on iPhone (various sizes)
- [ ] Test on iPad
- [ ] Dark mode testing

### Automated Testing (Future)
- Unit tests for TimetableCalculator
- SwiftData model tests
- View model tests

---

## PDF Import Handling - Multi-User Approach

### How It Works
Each user (Amelia, Rachel, Andy) has their own `TimetableData` relationship. When:

1. **Amelia imports her PDF:**
   - Stored in Amelia's `TimetableData.pdfData`
   - Rachel and Andy can VIEW Amelia's timetable
   - They don't need to import it themselves

2. **Rachel/Andy's profiles:**
   - If they're students too (future kids?), they import their own PDFs
   - If they're just parents, they don't import anything
   - Their dashboard shows them Amelia's schedule

3. **Viewing permissions:**
   - Students see their own timetable
   - Parents see all family members' timetables
   - Implemented via `UserRole` enum filtering

### Implementation
```swift
// In TimetableViewModel
func canViewTimetable(for user: User, viewing: User) -> Bool {
    if user.id == viewing.id {
        return true // Always see your own
    }
    if user.role == .parent {
        return true // Parents see all
    }
    return false
}
```

---

## Future Expansion Roadmap

### Version 2.0 Features
- Calendar integration module
- Homework tracker
- Shared family events
- Push notifications

### Version 3.0 Features
- Apple Watch companion
- Widgets for all modules
- iPad multi-window support
- Export/sharing capabilities

---

## Git Repository Structure

```
familyhub-ios/
├── .gitignore
├── README.md
├── FamilyHub/                  # Xcode project
├── FamilyHub.xcodeproj
├── docs/
│   ├── ARCHITECTURE.md
│   ├── API.md (future)
│   └── CHANGELOG.md
└── screenshots/               # For App Store/TestFlight
```

### Commit Message Convention
```
type(scope): subject

feat(timetable): add fortnight view
fix(data): correct week calculation
docs(readme): update setup instructions
style(ui): adjust spacing in day view
refactor(service): simplify PDF import
test(calculator): add week detection tests
```

---

## Environment Setup Requirements

### Development Machine
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Apple Developer Account (for TestFlight)

### Testing Devices
- iPhone (iOS 17+)
- iPad (optional, iOS 17+)

### External Tools
- Claude Code (for AI-assisted development)
- TestFlight (for distribution)
- Git/GitHub (version control)

---

## Success Metrics (v1.0)

### Technical
- [ ] App launches without crashes
- [ ] All views render correctly
- [ ] Week calculation is accurate
- [ ] PDF import works reliably
- [ ] iCloud sync functions (if online)

### User Experience
- [ ] Amelia can view her timetable daily
- [ ] Rachel/Andy can check Amelia's schedule
- [ ] Week switching works intuitively
- [ ] App feels fast and responsive

### Business
- [ ] Deployed to TestFlight successfully
- [ ] Amelia uses it regularly
- [ ] Foundation solid for future modules

---

## Getting Started - Claude Code Instructions

### Initial Setup Command
```bash
# Create new iOS app project
cd ~/Development/familyhub-ios
xcodegen generate  # If using XcodeGen, or:
# Create manually in Xcode: File → New → Project → iOS App

# Project settings:
# - Product Name: FamilyHub
# - Team: Lawsons Enterprises Ltd
# - Organization Identifier: com.lawsonsenterprises
# - Bundle Identifier: com.lawsonsenterprises.familyhub
# - Interface: SwiftUI
# - Language: Swift
# - Storage: SwiftData
# - Include Tests: Yes
```

### Development Workflow
1. **Read this specification thoroughly**
2. **Start with Phase 1 (Foundation)**
3. **Build incrementally** - test after each component
4. **Commit frequently** - following commit conventions
5. **Deploy to TestFlight** after Phase 4

### Key Implementation Order
1. SwiftData models (User, TimetableData, ScheduleEntry)
2. DataService setup
3. User selection screen
4. Timetable module views (Day → Week → Fortnight)
5. PDF import functionality
6. Settings screen
7. Dashboard/Home screen
8. Polish and testing

---

## Contact & Support

**Developer:** Andy Lawson  
**Company:** Lawsons Enterprises Ltd  
**Primary User:** Amelia (via Rachel)

**For Claude Code:**
This document provides complete context for building FamilyHub. Refer to this specification for architectural decisions, data models, and implementation details. Build incrementally and test thoroughly at each phase.

---

## Document Version
- **Version:** 1.0
- **Last Updated:** 11th November 2025
- **Status:** Ready for Development

---

## Quick Reference - Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Architecture** | MVVM + Modular | Scalability and testability |
| **Storage** | SwiftData | Modern, iCloud sync built-in |
| **Multi-user** | Yes, from v1.0 | Family use case, worth initial complexity |
| **PDF Handling** | Per-user storage | Each student has own timetable |
| **Week Toggle** | Manual + Auto | Flexibility with smart defaults |
| **First Module** | Timetable | Clear MVP, real user need |
| **Platform** | iOS only (v1) | Focus, can expand to iPad later |
| **Distribution** | TestFlight first | Rapid iteration with real users |

---

## Notes for Claude Code

When implementing this project:

1. **Start simple, build incrementally** - Don't try to build everything at once
2. **Test on device frequently** - Simulators don't catch everything
3. **Follow Apple HIG** - Use native UI patterns
4. **Keep it modular** - Each feature should be self-contained
5. **Comment complex logic** - Especially week calculations
6. **Use SwiftData properly** - Don't fight the framework
7. **Handle errors gracefully** - Especially PDF import
8. **Think about edge cases** - What if no PDF? Wrong week selected?

This is a real app for real users (Amelia and family). Quality matters more than speed.

---

**Ready to build? Let's create something great! 🚀**
