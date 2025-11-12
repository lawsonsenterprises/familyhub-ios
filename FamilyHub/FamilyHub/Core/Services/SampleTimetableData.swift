//
//  SampleTimetableData.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation

/// Service for generating sample timetable data for testing
struct SampleTimetableData {
    /// Generate sample schedule entries for Amelia's timetable
    /// - Returns: Array of sample schedule entries covering Week 1 and Week 2
    static func generateSampleEntries() -> [ScheduleEntry] {
        var entries: [ScheduleEntry] = []

        // Week 1 - Monday
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 1, subject: "Mathematics", room: "12", week: .week1, teacher: "KCO", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 2, subject: "English", room: "8", week: .week1, teacher: "SMI", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 3, subject: "Science", room: "15", week: .week1, teacher: "JON", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 4, subject: "History", room: "22", week: .week1, teacher: "BRO", startTime: "12:05", endTime: "12:55"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 5, subject: "French", room: "7", week: .week1, teacher: "DUP", startTime: "13:35", endTime: "14:25"))

        // Week 1 - Tuesday
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 1, subject: "English", room: "8", week: .week1, teacher: "SMI", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 2, subject: "Geography", room: "19", week: .week1, teacher: "WHI", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 3, subject: "PE", room: "Gym", week: .week1, teacher: "TAY", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 4, subject: "Mathematics", room: "12", week: .week1, teacher: "KCO", startTime: "12:05", endTime: "12:55"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 5, subject: "Art", room: "A3", week: .week1, teacher: "GRE", startTime: "13:35", endTime: "14:25"))

        // Week 1 - Wednesday
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 1, subject: "Science", room: "15", week: .week1, teacher: "JON", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 2, subject: "Mathematics", room: "12", week: .week1, teacher: "KCO", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 3, subject: "Music", room: "M1", week: .week1, teacher: "HAR", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 4, subject: "English", room: "8", week: .week1, teacher: "SMI", startTime: "12:05", endTime: "12:55"))

        // Week 1 - Thursday
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 1, subject: "History", room: "22", week: .week1, teacher: "BRO", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 2, subject: "Science", room: "15", week: .week1, teacher: "JON", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 3, subject: "French", room: "7", week: .week1, teacher: "DUP", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 4, subject: "Mathematics", room: "12", week: .week1, teacher: "KCO", startTime: "12:05", endTime: "12:55"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 5, subject: "Drama", room: "D1", week: .week1, teacher: "LEE", startTime: "13:35", endTime: "14:25"))

        // Week 1 - Friday
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 1, subject: "English", room: "8", week: .week1, teacher: "SMI", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 2, subject: "PE", room: "Field", week: .week1, teacher: "TAY", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 3, subject: "Geography", room: "19", week: .week1, teacher: "WHI", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 4, subject: "Science", room: "15", week: .week1, teacher: "JON", startTime: "12:05", endTime: "12:55"))

        // Week 2 - Monday
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 1, subject: "Science", room: "16", week: .week2, teacher: "JON", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 2, subject: "Mathematics", room: "12", week: .week2, teacher: "KCO", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 3, subject: "English", room: "8", week: .week2, teacher: "SMI", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 4, subject: "French", room: "7", week: .week2, teacher: "DUP", startTime: "12:05", endTime: "12:55"))
        entries.append(ScheduleEntry(dayOfWeek: .monday, period: 5, subject: "History", room: "22", week: .week2, teacher: "BRO", startTime: "13:35", endTime: "14:25"))

        // Week 2 - Tuesday
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 1, subject: "Mathematics", room: "12", week: .week2, teacher: "KCO", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 2, subject: "Art", room: "A3", week: .week2, teacher: "GRE", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 3, subject: "Geography", room: "19", week: .week2, teacher: "WHI", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 4, subject: "English", room: "8", week: .week2, teacher: "SMI", startTime: "12:05", endTime: "12:55"))
        entries.append(ScheduleEntry(dayOfWeek: .tuesday, period: 5, subject: "PE", room: "Gym", week: .week2, teacher: "TAY", startTime: "13:35", endTime: "14:25"))

        // Week 2 - Wednesday
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 1, subject: "English", room: "8", week: .week2, teacher: "SMI", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 2, subject: "Science", room: "16", week: .week2, teacher: "JON", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 3, subject: "Drama", room: "D1", week: .week2, teacher: "LEE", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .wednesday, period: 4, subject: "Mathematics", room: "12", week: .week2, teacher: "KCO", startTime: "12:05", endTime: "12:55"))

        // Week 2 - Thursday
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 1, subject: "French", room: "7", week: .week2, teacher: "DUP", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 2, subject: "Music", room: "M1", week: .week2, teacher: "HAR", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 3, subject: "Science", room: "16", week: .week2, teacher: "JON", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 4, subject: "History", room: "22", week: .week2, teacher: "BRO", startTime: "12:05", endTime: "12:55"))
        entries.append(ScheduleEntry(dayOfWeek: .thursday, period: 5, subject: "English", room: "8", week: .week2, teacher: "SMI", startTime: "13:35", endTime: "14:25"))

        // Week 2 - Friday
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 1, subject: "Geography", room: "19", week: .week2, teacher: "WHI", startTime: "09:00", endTime: "09:50"))
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 2, subject: "Mathematics", room: "12", week: .week2, teacher: "KCO", startTime: "09:55", endTime: "10:45"))
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 3, subject: "PE", room: "Field", week: .week2, teacher: "TAY", startTime: "11:10", endTime: "12:00"))
        entries.append(ScheduleEntry(dayOfWeek: .friday, period: 4, subject: "Art", room: "A3", week: .week2, teacher: "GRE", startTime: "12:05", endTime: "12:55"))

        return entries
    }
}
