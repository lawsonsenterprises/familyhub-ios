//
//  FileImportService.swift
//  FamilyHub
//
//  Created by Claude Code on 13/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

/// Service for handling file import operations
struct FileImportService {
    /// Import file data from a URL
    /// - Parameter url: URL of the file
    /// - Returns: File data
    /// - Throws: Error if import fails
    static func importFile(from url: URL) async throws -> Data {
        // Ensure we can access the URL (security-scoped resource)
        guard url.startAccessingSecurityScopedResource() else {
            throw FileImportError.accessDenied
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        // Read the data
        guard let data = try? Data(contentsOf: url) else {
            throw FileImportError.invalidData
        }

        return data
    }

    /// Import and parse CSV file
    /// - Parameter url: URL of the CSV file
    /// - Returns: String content of the CSV
    /// - Throws: Error if import fails
    static func importCSV(from url: URL) async throws -> String {
        let data = try await importFile(from: url)

        // Convert to string
        guard let csvString = String(data: data, encoding: .utf8) else {
            throw FileImportError.invalidEncoding
        }

        return csvString
    }
}

// MARK: - Errors

enum FileImportError: LocalizedError {
    case accessDenied
    case invalidData
    case invalidEncoding

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Cannot access the file. Please grant permission."
        case .invalidData:
            return "The file data is invalid or corrupted."
        case .invalidEncoding:
            return "The file encoding is not supported. Please use UTF-8 encoded files."
        }
    }
}
