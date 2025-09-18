//
//  DocumentDetailView.swift
//  iSpace
//
//  Created by Shoaib Akhtar on 18/09/25.
//

import SwiftUI
import PDFKit

struct DocumentDetailView: View {
    let item: StoredItem
    
    // This ViewModel will handle loading and decrypting the document
    @StateObject private var viewModel: DocumentDetailViewModel
    
    init(item: StoredItem) {
        self.item = item
        self._viewModel = StateObject(wrappedValue: DocumentDetailViewModel(item: item))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Decrypting...")
            } else if let imageData = viewModel.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if let pdfData = viewModel.pdfData {
                PDFKitView(data: pdfData)
            } else {
                Text("Could not load document.")
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadDocument()
        }
    }
}

// A wrapper for PDFKit's PDFView
struct PDFKitView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// A new ViewModel just for this screen's logic
@MainActor
class DocumentDetailViewModel: ObservableObject {
    @Published var imageData: Data?
    @Published var pdfData: Data?
    @Published var isLoading = true
    
    private let item: StoredItem
    
    init(item: StoredItem) {
        self.item = item
    }
    
    func loadDocument() {
        Task {
            isLoading = true
            
            // This is a placeholder for getting the metadata from the Keychain
            // In a real app, this would be an async call to your DataService
            let documentDetails: DocumentDetails? = getDetailsFromKeychain()
            
            guard let details = documentDetails else {
                isLoading = false
                return
            }
            
            do {
                if let fileData = try FileHelper.shared.read(from: details.fileName) {
                    switch details.documentType {
                    case .image:
                        self.imageData = fileData
                    case .pdf:
                        self.pdfData = fileData
                    }
                }
            } catch {
                print("Failed to read document: \(error)")
            }
            
            isLoading = false
        }
    }
    
    // This is a mock function. You will need to replace this with your actual Keychain reading logic.
    private func getDetailsFromKeychain<T: Decodable>() -> T? {
        // You would need to add a function to your DataService
        // similar to `getDecryptedDetails` that can fetch the `DocumentDetails`
        // by the item's ID. This is a complex step that requires modifying the
        // DataService and ItemDetailViewModel. For now, this placeholder allows
        // the view to compile.
        return nil
    }
}


//#Preview {
//    DocumentDetailView()
//}
