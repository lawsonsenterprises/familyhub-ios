# FamilyHub Architecture Documentation

## Overview

FamilyHub uses a modular MVVM architecture built with SwiftUI and SwiftData. This document provides detailed information about the app's architecture, design patterns, and implementation details.

## Core Architecture Principles

### 1. Modular Design
Each feature is a self-contained module that conforms to the `AppModule` protocol, making it easy to add or remove features without affecting the rest of the app.

### 2. MVVM Pattern
- **Models:** SwiftData models for persistence (User, TimetableData, ScheduleEntry)
- **Views:** SwiftUI views for UI presentation
- **ViewModels:** Business logic and state management

### 3. Local-First with Cloud Sync
- SwiftData for local persistence
- iCloud sync enabled by default
- Works offline, syncs when online

## Data Layer

### SwiftData Models

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
}
```

**Relationships:**
- One-to-one with TimetableData (cascade delete)
- One-to-one with UserPreferences (cascade delete)

#### TimetableData Model
```swift
@Model
class TimetableData {
    @Attribute(.unique) var id: UUID
    var pdfData: Data?
    var currentWeek: WeekType
    var weekStartDate: Date
    var lastUpdated: Date

    @Relationship var scheduleEntries: [ScheduleEntry]
    @Relationship(inverse: \User.timetableData) var owner: User?
}
```

**Relationships:**
- One-to-many with ScheduleEntry
- Inverse relationship with User

#### ScheduleEntry Model
```swift
@Model
class ScheduleEntry {
    @Attribute(.unique) var id: UUID
    var dayOfWeek: DayOfWeek
    var period: Int
    var subject: String
    var room: String
    var teacher: String?
    var week: WeekType
    var startTime: String?
    var endTime: String?

    @Relationship(inverse: \TimetableData.scheduleEntries) var timetableData: TimetableData?
}
```

### Data Service Layer

#### DataService
Manages SwiftData ModelContainer and provides data access methods.

```swift
class DataService {
    static let shared = DataService()
    let modelContainer: ModelContainer

    // User management
    func createUser(name: String, role: UserRole) -> User
    func fetchUsers() -> [User]
    func deleteUser(_ user: User)

    // Timetable management
    func saveTimetable(_ timetable: TimetableData)
    func fetchTimetable(for user: User) -> TimetableData?
}
```

#### TimetableCalculator
Handles Week A/B calculation logic.

```swift
class TimetableCalculator {
    static func currentWeek(startDate: Date) -> WeekType
    static func isCurrentPeriod(entry: ScheduleEntry, date: Date) -> Bool
    static func weeksSinceStart(from startDate: Date) -> Int
}
```

**Week Calculation Logic:**
- Takes a reference start date (when Week A began)
- Calculates weeks elapsed since start date
- Even weeks = Week A, Odd weeks = Week B
- Handles date math correctly across years

#### PDFService
Manages PDF import and storage.

```swift
class PDFService {
    func importPDF(from url: URL) async throws -> Data
    func renderPDFThumbnail(data: Data) -> UIImage?
    // Future: OCR/parsing of PDF to auto-populate schedule
}
```

## Feature Modules

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

This protocol allows for dynamic feature loading and easy addition of new modules.

### Current Modules

#### 1. Timetable Module
- **Purpose:** Display and manage school timetables
- **Views:** DayView, WeekView, FortnightView
- **Components:** PeriodCard, WeekSelectorView
- **State Management:** TimetableViewModel

#### 2. Settings Module
- **Purpose:** User preferences and app configuration
- **Views:** SettingsView, UserProfileEditView
- **Features:** Profile editing, week configuration, PDF re-import

## UI Architecture

### Design System

**Location:** `Shared/Theme/AppTheme.swift`

```swift
// Spacing (8pt grid)
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16  // Most common
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// Card specifications
enum CardMetrics {
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 16
    static let shadowRadius: CGFloat = 10
    static let shadowY: CGFloat = 5
    static let shadowOpacity: CGFloat = 0.08
}

// Animation durations
enum AnimationDuration {
    static let instant: Double = 0.1
    static let quick: Double = 0.2
    static let standard: Double = 0.3
    static let leisurely: Double = 0.5
}
```

### Liquid Glass Implementation

Materials used throughout the app:

| Component | Material | Rationale |
|-----------|----------|-----------|
| Period cards | `.regularMaterial` | Standard content |
| Navigation bar | `.thinMaterial` | Lightweight |
| Tab bar | `.regularMaterial` | Persistent presence |
| Modals | `.thickMaterial` | Prominent overlays |

### Colour System

Semantic colours defined in `Color+Theme.swift`:

```swift
extension Color {
    static let primaryApp = Color.blue      // Main accent
    static let secondaryApp = Color.cyan    // Secondary actions
    static let accentApp = Color.orange     // CTAs
    static let weekA = Color.purple         // Week A indicator
    static let weekB = Color.green          // Week B indicator
}
```

All colours support light/dark mode automatically.

## Navigation Structure

```
Launch Screen
└── User Profile Selector (family members)
    └── Tab Navigation
        ├── Dashboard (today's overview)
        ├── Timetable Module
        │   ├── Day View
        │   ├── Week View
        │   └── Fortnight View
        ├── [Future] Calendar Module
        ├── [Future] Activities Module
        └── Settings
            ├── User Profile Edit
            ├── Week Configuration
            └── Notification Settings
```

## State Management

### Environment Objects
- `@Environment(\.modelContext)` - SwiftData context
- Custom environment values for app-wide state

### View Models
- TimetableViewModel - Manages timetable state
- DashboardViewModel - Manages dashboard state
- Each major view has its own ViewModel

### Data Flow
1. User interacts with View
2. View calls ViewModel method
3. ViewModel updates Models via DataService
4. SwiftData triggers view refresh
5. View re-renders with new data

## Persistence & Sync

### Local Storage
- SwiftData stores data in local SQLite database
- Automatic migrations handled by SwiftData
- Data persists across app launches

### iCloud Sync
- Enabled via `.cloudKitDatabase: .automatic`
- Syncs across user's devices
- Conflict resolution handled automatically
- Works offline, syncs when online

### Data Backup
- Included in iOS device backups
- Can be restored from backup
- iCloud provides additional redundancy

## Testing Architecture

### Unit Tests
- Model tests (User, TimetableData, ScheduleEntry)
- Service tests (DataService, TimetableCalculator)
- Utility tests (Date extensions, helpers)

### Integration Tests
- SwiftData persistence tests
- Module integration tests
- Navigation flow tests

### UI Tests (Future)
- User flow tests
- Accessibility tests
- Screenshot tests for App Store

## Performance Considerations

### Lazy Loading
- Schedule entries loaded on-demand
- PDF data loaded only when needed
- Large data sets paginated

### Memory Management
- Images cached efficiently
- PDF data stored as compressed Data
- Automatic memory management via SwiftData

### Optimization
- Minimize re-renders with proper state management
- Use `@Query` for efficient SwiftData fetching
- Avoid unnecessary computations in views

## Security & Privacy

### Data Protection
- All data stored locally with iOS encryption
- iCloud data encrypted in transit and at rest
- No third-party analytics

### Privacy
- No tracking or telemetry
- User data never leaves Apple ecosystem
- Complies with Apple privacy requirements

## Accessibility

### VoiceOver Support
- All interactive elements have labels
- Proper accessibility hints
- Logical navigation order

### Dynamic Type
- All text scales with user preferences
- Layout adapts to larger text sizes
- Tested at all accessibility sizes

### Colour & Contrast
- WCAG AA compliant (4.5:1 minimum)
- Works with colour blindness
- High contrast mode supported

### Reduce Motion
- Respects reduce motion preference
- Provides non-animated alternatives
- Smooth experience for all users

## Future Architecture Considerations

### Planned Modules
- Calendar Module (v2.0)
- Homework Tracker (v2.0)
- Activities Module (v2.0)
- Apple Watch Companion (v3.0)

### Extensibility
- Module protocol allows easy addition
- Shared components reusable
- Theme system scales to new features

### Migration Strategy
- SwiftData handles schema migrations
- Version migrations documented
- Backwards compatibility maintained

## Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use British English spelling
- Document complex logic
- Keep functions focused and small

### File Organization
- Group by feature, not type
- Keep related files together
- Use clear, descriptive names
- Maintain consistent structure

### Git Workflow
- Feature branches for new work
- Descriptive commit messages
- Regular commits (not batch)
- Follow conventional commits format

---

**Document Version:** 1.0
**Last Updated:** November 2025
**Status:** Living Document (updated as app evolves)
