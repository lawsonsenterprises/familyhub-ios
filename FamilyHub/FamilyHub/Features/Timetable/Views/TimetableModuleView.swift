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
    @State private var showPDFPicker = false
    @State private var isImporting = false
    @State private var importError: String?

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
            .sheet(isPresented: $showPDFPicker) {
                PDFDocumentPicker(isPresented: $showPDFPicker) { url in
                    Task {
                        await importPDF(from: url)
                    }
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

                Text("Import a PDF timetable to get started")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if user.isStudent {
                VStack(spacing: Spacing.md) {
                    Button {
                        showPDFPicker = true
                    } label: {
                        Label("Import Timetable PDF", systemImage: "doc.badge.plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.accentApp)
                            .clipShape(Capsule())
                    }
                    .disabled(isImporting)

                    Button {
                        loadSampleData()
                    } label: {
                        Label("Load Sample Data", systemImage: "doc.text")
                            .font(.subheadline)
                            .foregroundColor(.accentApp)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.accentApp.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .disabled(isImporting)
                }
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

    private func loadSampleData() {
        isImporting = true
        importError = nil

        // Generate sample entries
        let entries = SampleTimetableData.generateSampleEntries()

        if let existingTimetable = user.timetableData {
            // Clear existing entries
            existingTimetable.scheduleEntries.removeAll()

            // Add new entries
            for entry in entries {
                existingTimetable.scheduleEntries.append(entry)
            }

            existingTimetable.markUpdated()
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
        }

        // Save context
        try? modelContext.save()

        // Update selected week
        updateSelectedWeek()

        isImporting = false
    }

    private func importPDF(from url: URL) async {
        isImporting = true
        importError = nil

        do {
            // Import the PDF data
            let pdfData = try await PDFService.importPDF(from: url)

            // Extract schedule entries
            let entries = PDFService.extractScheduleData(from: pdfData)

            guard !entries.isEmpty else {
                importError = "Could not extract timetable data from PDF"
                isImporting = false
                return
            }

            // Create or update timetable data
            await MainActor.run {
                if let existingTimetable = user.timetableData {
                    // Clear existing entries
                    existingTimetable.scheduleEntries.removeAll()

                    // Add new entries
                    for entry in entries {
                        existingTimetable.scheduleEntries.append(entry)
                    }

                    // Update metadata
                    existingTimetable.pdfData = pdfData
                    existingTimetable.markUpdated()
                } else {
                    // Create new timetable
                    let timetableData = TimetableData(owner: user)
                    timetableData.pdfData = pdfData

                    // Add entries
                    for entry in entries {
                        timetableData.scheduleEntries.append(entry)
                    }

                    timetableData.markUpdated()
                    user.timetableData = timetableData
                    modelContext.insert(timetableData)
                }

                // Save context
                try? modelContext.save()

                // Update selected week
                updateSelectedWeek()
            }

            isImporting = false
        } catch {
            await MainActor.run {
                importError = error.localizedDescription
                isImporting = false
            }
        }
    }
}

#Preview {
    let user = User(name: "Amelia", role: .student)
    return TimetableModuleView(user: user)
}
