//
//  PDFService.swift
//  FamilyHub
//
//  Created by Claude Code on 12/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import Foundation
import PDFKit
import UIKit

/// Service for handling PDF import and processing
struct PDFService {
    /// Import PDF from a file URL
    /// - Parameter url: URL of the PDF file
    /// - Returns: PDF data
    /// - Throws: Error if import fails
    static func importPDF(from url: URL) async throws -> Data {
        // Ensure we can access the URL
        guard url.startAccessingSecurityScopedResource() else {
            throw PDFError.accessDenied
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        // Read the data
        guard let data = try? Data(contentsOf: url) else {
            throw PDFError.invalidData
        }

        // Verify it's a valid PDF
        guard let _ = PDFDocument(data: data) else {
            throw PDFError.invalidPDF
        }

        return data
    }

    /// Generate a thumbnail image from PDF data
    /// - Parameters:
    ///   - data: PDF data
    ///   - size: Desired thumbnail size (default 200x200)
    /// - Returns: Thumbnail image, or nil if generation fails
    static func renderPDFThumbnail(data: Data, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard let document = PDFDocument(data: data),
              let page = document.page(at: 0) else {
            return nil
        }

        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: size)

        let thumbnail = renderer.image { context in
            UIColor.white.set()
            context.fill(CGRect(origin: .zero, size: size))

            context.cgContext.translateBy(x: 0, y: size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)

            let scaleFactor = min(size.width / pageRect.width, size.height / pageRect.height)
            context.cgContext.scaleBy(x: scaleFactor, y: scaleFactor)

            page.draw(with: .mediaBox, to: context.cgContext)
        }

        return thumbnail
    }

    /// Extract schedule data from PDF (placeholder for future OCR implementation)
    /// - Parameter pdfData: PDF data to parse
    /// - Returns: Array of schedule entries (currently returns empty array)
    /// - Note: Future enhancement - implement OCR to automatically parse timetable
    static func extractScheduleData(from pdfData: Data) -> [ScheduleEntry]? {
        // TODO: Implement OCR/parsing logic in future version
        // For v1.0, users will manually enter schedule data
        return nil
    }
}

// MARK: - Errors

enum PDFError: LocalizedError {
    case accessDenied
    case invalidData
    case invalidPDF

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Cannot access the PDF file. Please grant permission."
        case .invalidData:
            return "The file data is invalid or corrupted."
        case .invalidPDF:
            return "The file is not a valid PDF document."
        }
    }
}
