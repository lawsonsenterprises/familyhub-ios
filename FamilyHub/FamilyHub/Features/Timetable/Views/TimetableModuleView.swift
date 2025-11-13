//
//  TimetableModuleView.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI
import SwiftData

struct TimetableModuleView: View {
    let user: User

    @Environment(\.modelContext) private var modelContext

    @State private var selectedWeek: WeekType = .week1
    @State private var viewMode: ViewMode = .week
    @State private var manualOverride: Bool = false
    @State private var isImporting = false
    @State private var importError: String?
    @State private var showDeleteConfirmation = false
    @State private var showCSVPicker = false
    @State private var parseResult: CSVParser.ParseResult?
    @State private var showImportPreview = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let timetableData = user.timetableData, timetableData.hasSchedule {
                    // Week selector
                    WeekSelector(
                        selectedWeek: $selectedWeek,
                        calculatedWeek: calculatedWeek,
                        manualOverride: manualOverride,
                        onToggle: toggleWeek
                    )
                    .padding(Spacing.md)

                    // View mode picker
                    viewModePicker
                        .padding(.horizontal, Spacing.md)
                        .padding(.bottom, Spacing.sm)

                    // Content based on view mode
                    Group {
                        switch viewMode {
                        case .day:
                            DayView(
                                timetableData: timetableData,
                                selectedWeek: selectedWeek,
                                currentDate: Date()
                            )
                        case .week:
                            WeekView(
                                timetableData: timetableData,
                                selectedWeek: selectedWeek
                            )
                        case .fortnight:
                            FortnightView(
                                timetableData: timetableData,
                                selectedWeek: selectedWeek
                            )
                        }
                    }
                } else {
                    // Empty state
                    emptyState
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Timetable")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if user.timetableData?.hasSchedule == true {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Menu {
                            Button(role: .destructive) {
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete Timetable", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .confirmationDialog(
                "Delete Timetable",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteTimetable()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all timetable data. You can import a new timetable afterwards.")
            }
            .sheet(isPresented: $showCSVPicker) {
                CSVDocumentPicker(isPresented: $showCSVPicker) { url in
                    Task {
                        await importCSV(from: url)
                    }
                }
            }
            .sheet(isPresented: $showImportPreview) {
                if let result = parseResult {
                    CSVImportPreviewView(
                        parseResult: result,
                        onConfirm: {
                            confirmImport()
                        },
                        onCancel: {
                            showImportPreview = false
                            parseResult = nil
                        }
                    )
                }
            }
            .overlay {
                if isImporting {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        VStack(spacing: Spacing.md) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.primaryApp)

                            Text("Importing Timetable...")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                        }
                        .padding(Spacing.xl)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.backgroundSecondary)
                        )
                    }
                }
            }
            .onAppear {
                updateSelectedWeek()
            }
        }
    }

    // MARK: - View Components

    private var viewModePicker: some View {
        Picker("View Mode", selection: $viewMode) {
            ForEach([ViewMode.day, ViewMode.week, ViewMode.fortnight], id: \.self) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundColor(.textTertiary)

            VStack(spacing: Spacing.xs) {
                Text("No Timetable Yet")
                    .font(.sectionHeader)
                    .foregroundColor(.textPrimary)

                Text("Import a CSV file or manually enter your timetable")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if user.isStudent {
                Button {
                    showCSVPicker = true
                } label: {
                    Label("Import CSV File", systemImage: "doc.badge.plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.accentApp)
                        .clipShape(Capsule())
                }
                .disabled(isImporting)

                #if DEBUG
                // Development-only: Sample data for testing without PDF
                Button {
                    loadSampleData()
                } label: {
                    Label("Load Sample Data (Dev)", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                }
                .disabled(isImporting)
                .padding(.top, Spacing.sm)
                #endif
            }

            // Show error if import failed
            if let error = importError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, Spacing.sm)
            }

            Spacer()
        }
        .padding(Spacing.xl)
    }

    // MARK: - Computed Properties

    private var calculatedWeek: WeekType {
        guard let timetableData = user.timetableData else {
            return .week1
        }
        return TimetableCalculator.currentWeek(startDate: timetableData.weekStartDate)
    }

    // MARK: - Actions

    private func toggleWeek() {
        selectedWeek.toggle()
        manualOverride = (selectedWeek != calculatedWeek)
    }

    private func updateSelectedWeek() {
        guard let timetableData = user.timetableData else { return }

        if timetableData.manualOverride {
            selectedWeek = timetableData.currentWeek
            manualOverride = true
        } else {
            selectedWeek = calculatedWeek
            manualOverride = false
        }
    }

    private func deleteTimetable() {
        guard let timetableData = user.timetableData else { return }

        print("🔵 Deleting timetable data...")

        // Remove all entries
        timetableData.scheduleEntries.removeAll()

        // Delete the timetable data object
        modelContext.delete(timetableData)
        user.timetableData = nil

        // Save context
        try? modelContext.save()

        print("✅ Timetable deleted successfully")
    }

    private func loadSampleData() {
        isImporting = true
        importError = nil

        // Generate sample entries
        let entries = SampleTimetableData.generateSampleEntries()

        print("🔵 Loading \(entries.count) sample entries...")

        if let existingTimetable = user.timetableData {
            // Clear existing entries
            existingTimetable.scheduleEntries.removeAll()

            // Add new entries
            for entry in entries {
                existingTimetable.scheduleEntries.append(entry)
            }

            existingTimetable.markUpdated()

            // Validate and print report
            let report = TimetableValidator.validate(existingTimetable)
            TimetableValidator.printReport(report)
        } else {
            // Create new timetable
            let timetableData = TimetableData(owner: user)

            // Add entries
            for entry in entries {
                timetableData.scheduleEntries.append(entry)
            }

            timetableData.markUpdated()
            user.timetableData = timetableData
            modelContext.insert(timetableData)

            // Validate and print report
            let report = TimetableValidator.validate(timetableData)
            TimetableValidator.printReport(report)
        }

        // Save context
        try? modelContext.save()

        // Update selected week
        updateSelectedWeek()

        print("✅ Sample data loaded successfully!")
        isImporting = false
    }

    // MARK: - CSV Import

    private func importCSV(from url: URL) async {
        isImporting = true
        importError = nil

        do {
            // Import CSV file
            let csvContent = try await FileImportService.importCSV(from: url)

            // Parse CSV content
            let result = CSVParser.parse(csvContent)

            await MainActor.run {
                parseResult = result
                isImporting = false

                // Show preview
                showImportPreview = true
            }
        } catch {
            await MainActor.run {
                importError = error.localizedDescription
                isImporting = false
            }
        }
    }

    private func confirmImport() {
        guard let result = parseResult else { return }

        // Import the valid entries
        let entries = result.validEntries

        print("🔵 Importing \(entries.count) valid entries...")

        if let existingTimetable = user.timetableData {
            // Clear existing entries
            existingTimetable.scheduleEntries.removeAll()

            // Add new entries
            for entry in entries {
                existingTimetable.scheduleEntries.append(entry)
            }

            existingTimetable.markUpdated()

            // Validate and print report
            let validationReport = TimetableValidator.validate(existingTimetable)
            TimetableValidator.printReport(validationReport)
        } else {
            // Create new timetable
            let timetableData = TimetableData(owner: user)

            // Add entries
            for entry in entries {
                timetableData.scheduleEntries.append(entry)
            }

            timetableData.markUpdated()
            user.timetableData = timetableData
            modelContext.insert(timetableData)

            // Validate and print report
            let validationReport = TimetableValidator.validate(timetableData)
            TimetableValidator.printReport(validationReport)
        }

        // Save context
        try? modelContext.save()

        // Update selected week
        updateSelectedWeek()

        // Close preview
        showImportPreview = false
        parseResult = nil

        print("✅ CSV data imported successfully!")
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    return TimetableModuleView(user: user)
}
