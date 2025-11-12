# Testing Guide - Phase 2 Timetable Features

## Overview
This guide covers testing the timetable views and import functionality implemented in Phase 2.1 and 2.2.

## Prerequisites
- Xcode installed and configured
- iOS Simulator ready
- Project builds successfully

## Test Scenarios

### Scenario 1: Sample Data Loading ⭐ START HERE

This is the easiest way to test all functionality without PDFs.

**Steps:**
1. **Build and run** the app in simulator
2. **Select Amelia** from the user selection screen
3. **Navigate to Timetable tab** (calendar icon)
4. **Tap "Load Sample Data"** button
5. **Check console output** for validation report

**Expected Console Output:**
```
🔵 Loading 50 sample entries...

=== Timetable Validation Report ===
Total Entries: 50
Week 1 Entries: 25
Week 2 Entries: 25

Entries per day:
  Monday: 10
  Tuesday: 10
  Wednesday: 8
  Thursday: 10
  Friday: 8

✅ No issues found!
===================================

✅ Sample data loaded successfully!
```

**Expected UI Behavior:**
- Empty state disappears
- Week selector appears at top (showing "Week 1" or "Week 2")
- View mode picker appears (Day | Week | Fortnight)
- Timetable content displays below

### Scenario 2: Week View Verification

**Steps:**
1. Load sample data (see Scenario 1)
2. **Ensure "Week" is selected** in view mode picker
3. **Verify display** of all weekdays

**What to Check:**
- [ ] Monday through Friday sections visible
- [ ] Each day shows entry count (e.g., "5 classes")
- [ ] Today's date is highlighted (if viewing current day)
- [ ] Each period card shows:
  - Subject name
  - Start time (left side)
  - Room number ("Room X")
  - Period number ("PX" on right)
- [ ] Periods are sorted by time
- [ ] No overlapping entries
- [ ] Smooth scrolling

**Test Week Toggle:**
- [ ] Tap week toggle button (arrows icon)
- [ ] Verify switch from Week 1 to Week 2
- [ ] Check that classes change appropriately
- [ ] Verify purple indicator for Week 1
- [ ] Verify green indicator for Week 2

### Scenario 3: Day View Verification

**Steps:**
1. Load sample data
2. **Select "Day" view** from picker
3. **Check today's schedule**

**What to Check:**
- [ ] Current date displayed at top
- [ ] Day name shown below date
- [ ] If no classes today: "No Classes Today" message
- [ ] If classes exist:
  - [ ] Period cards show start/end times
  - [ ] Subject names clearly visible
  - [ ] Teacher codes displayed (if present)
  - [ ] Room numbers shown
  - [ ] Current period highlighted (if during school day)
  - [ ] Blue indicator dot for current period
  - [ ] Cards have proper spacing

**Current Period Detection:**
- Only testable during school hours (09:00-14:25)
- Current period should have:
  - Blue border
  - Light blue background
  - Blue dot indicator

### Scenario 4: Fortnight View Verification

**Steps:**
1. Load sample data
2. **Select "Fortnight" view** from picker
3. **Review side-by-side comparison**

**What to Check:**
- [ ] All 5 days (Mon-Fri) displayed
- [ ] Each day has two columns: Week 1 and Week 2
- [ ] Week 1 column has purple indicator dot
- [ ] Week 2 column has green indicator dot
- [ ] Currently selected week is highlighted
- [ ] Each mini-card shows:
  - Subject name
  - Start time
  - Room number
- [ ] "No classes" shown for empty periods
- [ ] Can compare same day across weeks easily

**Test Comparisons:**
- [ ] Verify Monday Week 1 vs Week 2 differ
- [ ] Check that some subjects appear in both weeks
- [ ] Confirm different room assignments visible
- [ ] Validate time differences (if any)

### Scenario 5: PDF Import Testing ⚠️ CRITICAL TEST

**Prerequisites:**
1. PDF timetable must be in simulator Files app
2. **IMPORTANT:** Delete existing timetable first (tap "..." menu → Delete Timetable)

**Steps:**
1. **Open Timetable tab** in FamilyHub app
2. **Tap "Import Timetable PDF"** button
3. **Select your PDF** from file picker
4. **Wait for import** (loading overlay appears with progress indicator)
5. **Check Xcode Console** for detailed extraction report

**Expected Console Output (FULL IMPORT):**
```
🔵 Performing OCR on page 1...
🔹 OCR found X text observations

[Row processing logs...]
🔹 Found 5-7 periods in this row
🔹 Period 0: X items → Parsing...
✅ Created entry: [Subject] ([Teacher]) in Room [X]
...

🔵 Extracted 70 entries from PDF

=== Timetable Validation Report ===
Total Entries: 70
Week 1 Entries: 35
Week 2 Entries: 35

Entries per day:
  Monday: 14
  Tuesday: 14
  Wednesday: 14
  Thursday: 14
  Friday: 14

✅ No issues found!
===================================

✅ PDF data imported successfully!
```

**What to Check:**
- [ ] File picker opens correctly
- [ ] Can navigate to PDF location
- [ ] Loading overlay displays during import
- [ ] Console shows "🔹 Found 5-7 periods in this row" (NOT 20+)
- [ ] Console shows ~70 total entries extracted
- [ ] Validation report shows 35 per week, 14 per day
- [ ] All 10 days have data (Week 1 & 2, Mon-Fri)
- [ ] Data loads into all three views (Day/Week/Fortnight)
- [ ] Each period shows Subject, Teacher, Room correctly

**Gap-Based Clustering Fix:**
The parser now uses gap detection (0.065 threshold) to identify period boundaries. Large gaps between items indicate new periods, small gaps indicate items within the same period. This fixes the previous issue where items were incorrectly split.

**If Import Shows < 70 Entries:**
- Check console for "🔹 Found X periods" - should be 5-7, not 20+
- Check for "Period X has only 1-2 items, skipping" warnings
- Look for parsing errors or missing data
- Verify all 10 days are processed (2 weeks × 5 days)

## Known Issues / Limitations

### PDF Parsing
- Parser expects specific formats:
  - "Week 1" and "Week 2" headers
  - Day names: Monday, Tuesday, etc.
  - Period format: "Period 1" or "P1"
  - Room format: "R12" or "Room 12"
  - Teacher codes: 3 capital letters
- Custom PDF formats may not parse correctly
- OCR is not implemented (text must be selectable)

### Simulator-Specific Issues
- ISSymbol warnings are harmless (iOS simulator issue)
- File picker may show simulator artifacts
- Current period highlighting only works if system time matches school hours

### Data Persistence
- Data persists between app launches (SwiftData)
- To reset: Delete app from simulator
- Sample data overwrites existing data

## Validation Checklist

### Sample Data
- [ ] 50 total entries generated
- [ ] 25 entries for Week 1
- [ ] 25 entries for Week 2
- [ ] 5 days covered (Monday-Friday)
- [ ] Multiple periods per day
- [ ] All required fields populated
- [ ] No duplicate entries

### Views
- [ ] Week view displays correctly
- [ ] Day view displays correctly
- [ ] Fortnight view displays correctly
- [ ] View switching works smoothly
- [ ] Week toggling works
- [ ] Data persists after closing app

### UI/UX
- [ ] Colors match design system
- [ ] Fonts are readable
- [ ] Spacing is consistent
- [ ] Touch targets are adequate
- [ ] Scrolling is smooth
- [ ] Animations are fluid

## Troubleshooting

### No data showing after load
1. Check console for validation report
2. Verify entry count > 0
3. Try switching view modes
4. Try toggling week
5. Restart app

### Console errors
- Read error messages carefully
- Check for SwiftData issues
- Verify model relationships
- Look for nil values

### PDF import fails
- Verify PDF format
- Check console for parsing errors
- Try sample data first to isolate issue
- Ensure PDF contains text (not images only)

### Current period not highlighting
- Only works during school hours (09:00-14:25)
- Verify system time is correct
- Check that times in data match current time
- Test with sample data first

## Next Steps After Testing

Once all scenarios pass:
1. Document any issues found
2. Note any UI improvements needed
3. Test with real timetable PDFs
4. Gather user feedback
5. Plan Phase 2.3 features

## Success Criteria

✅ All test scenarios complete without errors
✅ Console validation reports show no issues
✅ All three view modes display correctly
✅ Week switching functions properly
✅ Data persists between sessions
✅ UI is smooth and responsive
