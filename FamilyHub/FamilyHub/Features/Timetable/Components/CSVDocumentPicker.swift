//
//  CSVDocumentPicker.swift
//  FamilyHub
//
//  Created by Claude Code on 13/11/2025.
//  Copyright © 2025 Lawsons Enterprises Ltd. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

/// Document picker for selecting CSV files
struct CSVDocumentPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onFileSelected: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Accept CSV files and plain text files
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.commaSeparatedText, .plainText],
            asCopy: true
        )
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: CSVDocumentPicker

        init(_ parent: CSVDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onFileSelected(url)
            parent.isPresented = false
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented = false
        }
    }
}
