# FamilyHub Xcode Project Setup Instructions

## Current Status

âï¸ All Swift source files have been created and are ready
âï¸ Project structure is complete
âï¸ Git repository initialized
âï¸ Documentation ready

## What's Needed

You need to create the Xcode project and link the existing source files.

## Step-by-Step Instructions

### 1. Create New Xcode Project

1. Open **Xcode** (version 15.0 or later)
2. Select **File â New â Project** (or press â§+âCommand+N)
3. Choose **iOS** platform
4. Select **App** template
5. Click **Next**

### 2. Configure Project Settings

Enter the following details:

- **Product Name:** `FamilyHub`
- **Team:** Select "Lawsons Enterprises Ltd" (or your development team)
- **Organization Identifier:** `com.lawsonsenterprises`
- **Bundle Identifier:** `com.lawsonsenterprises.familyhub` (auto-generated)
- **Interface:** `SwiftUI`
- **Language:** `Swift`
- **Storage:** `SwiftData`
- **Include Tests:** `âï¸ Checked`

Click **Next**

### 3. Save Location

- Navigate to: `/Users/andrewlawson/Development/Apps/ios/familyhub-ios/`
- **IMPORTANT:** Uncheck "Create Git repository" (we already have one)
- Click **Create**

### 4. Delete Default Files

Xcode will create some default files. Delete these (Move to Trash):

- `FamilyHubApp.swift` (we have our own)
- `ContentView.swift` (we have our own)
- `Item.swift` (not needed)
- `Preview Content` folder (optional, can keep)

### 5. Add Existing Source Files to Project

In Xcode Project Navigator:

1. **Right-click on `FamilyHub` folder** (blue project icon at top)
2. Select **Add Files to "FamilyHub"...**
3. Navigate to the `FamilyHub` folder in your file system
4. Select **all folders and files** in the FamilyHub directory:
   - `FamilyHubApp.swift`
   - `ContentView.swift`
   - `Core` folder
   - `Features` folder
   - `Shared` folder
   - `Resources` folder
5. **IMPORTANT:** Ensure these options are set:
   - âï¸ "Copy items if needed" - **UNCHECKED** (files are already in place)
   - âï¸ "Create groups" - **SELECTED**
   - âï¸ "Add to targets: FamilyHub" - **CHECKED**
6. Click **Add**

### 6. Configure Project Settings

#### 6.1 General Tab

1. Select **FamilyHub project** in navigator (blue icon)
2. Select **FamilyHub target**
3. Go to **General** tab
4. Verify:
   - **Display Name:** FamilyHub
   - **Bundle Identifier:** com.lawsonsenterprises.familyhub
   - **Version:** 1.0
   - **Build:** 1
   - **Deployment Info:**
     - **iOS Deployment Target:** 17.0 or later
     - **iPhone** orientation options as needed
     - **iPad** (optional, can support later)

#### 6.2 Signing & Capabilities

1. Go to **Signing & Capabilities** tab
2. Select your **Team:** Lawsons Enterprises Ltd
3. Ensure **Automatically manage signing** is checked
4. Add **iCloud** capability:
   - Click **+ Capability**
   - Search for "iCloud"
   - Add **iCloud**
   - Check **CloudKit**
5. The CloudKit container should be created automatically

#### 6.3 Build Settings

1. Go to **Build Settings** tab
2. Search for "Swift Language Version"
3. Ensure it's set to **Swift 5** or later

### 7. Add Info.plist Entries (If Needed)

If you plan to import PDFs from Files app, add this to Info.plist:

1. Select `Info.plist` in Project Navigator
2. Right-click and select **Open As â Source Code**
3. Add before the closing `</dict>`:

```xml
<key>UISupportsDocumentBrowser</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

### 8. Build and Test

1. Select a simulator: **iPhone 15 Pro** (recommended)
2. Press **âCommand+B** to build
3. Fix any import/syntax errors if they appear
4. Press **âCommand+R** to run

### 9. Expected Result

When you run the app:

1. **First launch:** You'll see the "Welcome to FamilyHub" screen
2. **Tap "Get Started"** to create your first user profile
3. **Enter name:** e.g., "Amelia"
4. **Select role:** Student
5. **Tap "Continue"** (or "Add")
6. You'll see the **User Selection screen** with Amelia's card
7. **Tap Amelia's card** to enter the app
8. You'll see the **main tab view** with:
   - Today tab (Dashboard)
   - Timetable tab (placeholder)
   - Settings tab

### 10. Test Checklist

Test these features:

- [ ] App launches without crashes
- [ ] Can create new users
- [ ] Can select different users
- [ ] Can navigate between tabs
- [ ] Light/dark mode both work (toggle in Settings app)
- [ ] Dynamic Type works (test with larger text in Settings)
- [ ] All materials (glass effects) render correctly
- [ ] Animations are smooth

## Troubleshooting

### Build Errors

**"Cannot find 'User' in scope"**
- Make sure all Core/Models files are added to target
- Clean build folder (âShift+âCommand+K)
- Rebuild

**"Use of unresolved identifier 'Spacing'"**
- Ensure Shared/Theme/AppTheme.swift is added to target
- Check import statements

**SwiftData errors**
- Ensure deployment target is iOS 17.0+
- Verify SwiftData is imported in files that use @Model

### Runtime Errors

**App crashes on launch**
- Check FamilyHubApp.swift is set as @main entry point
- Verify ModelContainer configuration is correct

**"No such module 'SwiftData'"**
- Ensure minimum deployment target is iOS 17.0+
- Clean and rebuild

## Next Steps

After successful setup:

1. **Commit to Git:**
   ```bash
   git add .
   git commit -m "feat(foundation): initialize Xcode project and core implementation"
   ```

2. **Test on Physical Device:**
   - Connect iPhone
   - Select as run destination
   - Run app

3. **Phase 2: Implement Timetable Module**
   - PDF import functionality
   - Week A/B views
   - Schedule entry creation

## Need Help?

If you encounter issues:

1. Check Xcode console for error messages
2. Verify all files are added to the target
3. Clean build folder and rebuild
4. Restart Xcode if needed

---

**Created:** 12 November 2025
**Status:** Ready for Xcode project creation
