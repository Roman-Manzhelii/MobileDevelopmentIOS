//
//  DetectorView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct DetectorView: View {
    @EnvironmentObject private var activeUserManager: ActiveUserManager
    @Environment(\.modelContext) private var modelContext
    

    private enum PrimaryAction {
        case chooseImage
        case analyze
        case chooseAnotherImage
        case retry

        var title: String {
            switch self {
            case .chooseImage:
                return "Choose Image"
            case .analyze:
                return "Analyze"
            case .chooseAnotherImage:
                return "Choose Another Image"
            case .retry:
                return "Try Again"
            }
        }
    }

    @State private var selectedImage: UIImage?
    @State private var selectedImageData: Data?
    @State private var selectedImageFileName: String?
    @State private var showSourcePicker = false
    @State private var showPhotoLibrary = false
    @State private var showCamera = false
    @State private var isAnalyzing = false
    @State private var analysisResult: AiclipseCheckResponse?
    @State private var analysisError: String?
    @State private var activeAnalysisID = UUID()

    private let apiService = AiclipseAPIService.shared

    private var clearTapAction: (() -> Void)? {
        guard selectedImage != nil, !isAnalyzing else { return nil }
        return clearSelection
    }

    private var primaryAction: PrimaryAction {
        if selectedImage == nil {
            return .chooseImage
        }
        if analysisResult != nil {
            return .chooseAnotherImage
        }
        if analysisError != nil {
            return .retry
        }
        return .analyze
    }

    var body: some View {
        detectorContent
            .confirmationDialog("Choose image source", isPresented: $showSourcePicker, titleVisibility: .visible) {
                sourcePickerActions
            } message: {
                Text("Upload an image from your photo library or take a new photo.")
            }
            .sheet(isPresented: $showPhotoLibrary) {
                photoLibrarySheet
            }
            .sheet(isPresented: $showCamera) {
                cameraSheet
            }
    }

    private var detectorContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(
                title: "AI Detector",
                subtitle: "Upload or capture an image to check it"
            )

            Rectangle()
                .fill(Color.ffBorder)
                .frame(height: 1)

            ResultsCard(
                selectedImage: selectedImage,
                analysisResult: analysisResult,
                isAnalyzing: isAnalyzing,
                errorMessage: analysisError,
                onPlaceholderTap: {
                    showSourcePicker = true
                },
                onClearTap: clearTapAction
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            PrimaryButton(
                title: isAnalyzing ? "Analyzing..." : primaryAction.title,
                isEnabled: !isAnalyzing,
                isLoading: isAnalyzing
            ) {
                handlePrimaryAction()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private var sourcePickerActions: some View {
        Button("Photo Library") {
            showPhotoLibrary = true
        }

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            Button("Take Photo") {
                showCamera = true
            }
        }

        Button("Cancel", role: .cancel) {}
    }

    private var photoLibrarySheet: some View {
        PhotoLibraryPicker(
            isPresented: $showPhotoLibrary,
            onImagePicked: { image, imageData, fileName in
                setSelectedImage(image, uploadData: imageData, fileName: fileName)
            }
        )
    }

    private var cameraSheet: some View {
        ImagePicker(
            isPresented: $showCamera,
            sourceType: .camera,
            onImagePicked: { image, imageData, fileName in
                setSelectedImage(image, uploadData: imageData, fileName: fileName)
            }
        )
    }

    private func setSelectedImage(_ image: UIImage, uploadData: Data, fileName: String) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
            selectedImage = image
            selectedImageData = uploadData
            selectedImageFileName = fileName
            resetAnalysisState()
        }
    }

    private func resetAnalysisState() {
        analysisResult = nil
        analysisError = nil
    }

    private func clearSelection() {
        activeAnalysisID = UUID()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
            selectedImage = nil
            selectedImageData = nil
            selectedImageFileName = nil
            isAnalyzing = false
            resetAnalysisState()
        }
    }

    private func handlePrimaryAction() {
        switch primaryAction {
        case .chooseImage, .chooseAnotherImage:
            showSourcePicker = true
        case .analyze, .retry:
            Task {
                await analyzeCurrentImage()
            }
        }
    }

    @MainActor
    private func analyzeCurrentImage() async {
        guard let selectedImageData else {
            analysisError = "No image is available for analysis."
            return
        }

        let fileName = selectedImageFileName ?? "image.jpg"
        let mimeType = fileName.lowercased().hasSuffix(".png") ? "image/png" : "image/jpeg"
        let requestID = UUID()

        activeAnalysisID = requestID
        withAnimation(.spring(response: 0.28, dampingFraction: 0.92)) {
            isAnalyzing = true
            resetAnalysisState()
        }

        defer {
            if activeAnalysisID == requestID {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    isAnalyzing = false
                }
            }
        }

        do {
            let result = try await apiService.analyzeImage(
                data: selectedImageData,
                filename: fileName,
                mimeType: mimeType
            )

            guard activeAnalysisID == requestID else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                analysisResult = result
            }

            saveScanRecord(
                fileName: fileName,
                imageData: selectedImageData,
                aiProbability: result.aiProbability,
                verdictLabel: result.displayLabel
            )
        } catch {
            guard activeAnalysisID == requestID else { return }
            withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                analysisError = error.localizedDescription
            }
        }
    }

    @MainActor
    private func saveScanRecord(fileName: String, imageData: Data, aiProbability: Double, verdictLabel: String) {
        do {
            let descriptor = FetchDescriptor<UserProfile>()
            let allProfiles = try modelContext.fetch(descriptor)
            let selectedUUID = UUID(uuidString: activeUserManager.activeUserID)
            let profile: UserProfile

            if let selectedUUID,
               let selectedProfile = allProfiles.first(where: { $0.id == selectedUUID }) {
                profile = selectedProfile
            } else if let existing = allProfiles.first {
                profile = existing
            } else {
                let created = UserProfile(displayName: "User")
                modelContext.insert(created)
                profile = created
            }

            let record = ScanRecord(
                userProfileID: profile.id,
                imageFileName: fileName,
                imageData: imageData,
                aiProbability: aiProbability,
                verdictLabel: verdictLabel
            )
            modelContext.insert(record)

            profile.imagesAnalyzed += 1
            try modelContext.save()
        } catch {
            analysisError = "Scan succeeded, but failed to save history: \(error.localizedDescription)"
        }
    }
}

private struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onImagePicked: (UIImage, Data, String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.selection = .default

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker

        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                parent.isPresented = false
                return
            }

            let provider = result.itemProvider
            guard provider.canLoadObject(ofClass: UIImage.self) else {
                parent.isPresented = false
                return
            }

            provider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    defer {
                        self.parent.isPresented = false
                    }

                    guard let image = object as? UIImage,
                          let imageData = image.jpegData(compressionQuality: 0.95) else {
                        return
                    }

                    self.parent.onImagePicked(image, imageData, "photo-library-image.jpg")
                }
            }
        }
    }
}

private struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage, Data, String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.95) {
                let fileName = parent.sourceType == .camera ? "camera-capture.jpg" : "photo-library-image.jpg"
                parent.onImagePicked(image, imageData, fileName)
            }

            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    DetectorView()
        .modelContainer(for: [ScanRecord.self, UserProfile.self], inMemory: true)
        .background(Color.ffBackground)
}
