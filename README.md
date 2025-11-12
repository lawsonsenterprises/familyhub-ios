# FamilyHub iOS App

**A modular family organisation app starting with school timetable tracking**

## Overview

FamilyHub is a family-focused iOS app designed to help families stay organised. The first feature is a school timetable viewer for tracking rotating Week 1/2 schedules, with a modular architecture ready for future features like calendar integration, homework tracking, and activity management.

### Primary Users
- **Amelia** - Student (timetable tracking)
- **Rachel** - Mum (family overview)
- **Andy** - Dad (family overview)

### Platform
- **iOS 17.0+**
- Built with SwiftUI & SwiftData
- Native iOS design with Liquid Glass (2025)
- iCloud sync enabled

## Features (v1.0 - MVP)

### Multi-User Support
- Individual profiles for each family member
- Role-based access (student, parent)
- Quick profile switching

### Timetable Module
- Week 1/2 rotating schedule support
- PDF timetable import
- Three view modes: Day, Week, Fortnight
- Current period highlighting
- Manual week override
- Smart week calculation

### Settings & Configuration
- User profile management
- Week start date configuration
- PDF re-import capability
- Notification preferences (future)

## Architecture

### Design Pattern
- **MVVM** (Model-View-ViewModel) with SwiftUI
- **Modular architecture** - Protocol-oriented design
- **Local-first** with iCloud sync via SwiftData

### Project Structure
```
FamilyHub/
├── Core/
│   ├── Models/          # SwiftData models
│   ├── Services/        # Business logic services
│   ├── Protocols/       # AppModule protocol
│   └── Extensions/      # Utility extensions
├── Features/
│   ├── Launch/          # Launch screen
│   ├── UserSelection/   # User picker
│   ├── Dashboard/       # Home/Today view
│   ├── Timetable/       # Timetable module
│   └── Settings/        # Settings module
├── Shared/
│   ├── Components/      # Reusable UI components
│   └── Theme/           # Design system
└── Resources/
    ├── Assets.xcassets  # Images, colours
    └── SampleData/      # Test data
```

## Design System

FamilyHub follows Apple's 2025 design language:

- **Liquid Glass materials** for depth and translucency
- **8pt grid system** for consistent spacing
- **Semantic colours** with light/dark mode support
- **SF Pro typography** hierarchy
- **Smooth animations** and haptic feedback
- **Full accessibility** support (VoiceOver, Dynamic Type)
- **WCAG AA compliant** (4.5:1 contrast minimum)

See [iOS-Apple-Best-Practices-2025.md](docs/iOS-Apple-Best-Practices-2025.md) for complete design guidelines.

## Development Setup

### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- iOS 17.0+ device/simulator
- Apple Developer Account (for TestFlight)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/lawsonsenterprises/familyhub-ios.git
cd familyhub-ios
```

2. Open in Xcode:
```bash
open FamilyHub.xcodeproj
```

3. Select your development team in Xcode:
   - Select the FamilyHub project in navigator
   - Go to Signing & Capabilities
   - Select your team

4. Build and run:
   - Select iPhone simulator or device
   - Press Cmd+R to build and run

### Testing

Run the test suite:
```bash
# In Xcode: Cmd+U
# Or via command line:
xcodebuild test -scheme FamilyHub -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Documentation

- [Project Specification](docs/FamilyHub-Project-Specification.md) - Complete technical spec
- [Architecture Guide](docs/ARCHITECTURE.md) - Detailed architecture documentation
- [iOS Best Practices](docs/iOS-Apple-Best-Practices-2025.md) - Design system guide
- [Changelog](docs/CHANGELOG.md) - Version history and updates

## Roadmap

### Version 1.0 (Current - MVP)
- ✅ Multi-user support
- ✅ Week 1/2 timetable module
- ✅ PDF import
- ✅ Three view modes (Day, Week, Fortnight)
- ✅ Settings and configuration

### Version 1.1 (Planned)
- 📋 Today widget
- 📋 Class notifications
- 📋 Period time display
- 📋 "What's on now" dashboard

### Version 2.0 (Future)
- 📋 Calendar integration module
- 📋 Homework tracker
- 📋 Shared family events
- 📋 Push notifications

### Version 3.0 (Future)
- 📋 Apple Watch companion
- 📋 iPad multi-window support
- 📋 Export/sharing capabilities

## Contributing

This is a private family project. For questions or suggestions, contact:
- **Developer:** Andy Lawson
- **Company:** Lawsons Enterprises Ltd
- **Email:** [Contact via GitHub]

## License

Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.

This is proprietary software for family use. Not licensed for public distribution.

## Acknowledgments

Built with:
- [SwiftUI](https://developer.apple.com/swiftui/) - Apple's declarative UI framework
- [SwiftData](https://developer.apple.com/xcode/swiftdata/) - Apple's data persistence framework
- [Claude Code](https://claude.com/claude-code) - AI-assisted development

Following:
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- [Liquid Glass Design Language](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass)

---

**Version:** 1.0.0
**Last Updated:** November 2025
**Status:** In Active Development
