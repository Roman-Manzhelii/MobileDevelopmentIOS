//
//  DetectorView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import PhotosUI
import SwiftUI
import UIKit

struct DetectorView: View {
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImageData: Data?
    @State private var selectedImageFileName: String?
    @State private var showSourcePicker = false
    @State private var showPhotoLibrary = false
    @State private var showCamera = false
    @State private var isAnalyzing = false
    @State private var analysisResult: AiclipseCheckResponse?
    @State private var analysisError: String?

    private let apiService = AiclipseAPIService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Detector")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ffTextPrimary)
                Text("Upload & Analyze")
                    .font(.subheadline)
                    .foregroundStyle(Color.ffTextMuted)
            }
            .padding(.top, 8)

            Rectangle()
                .fill(Color.ffBorder)
                .frame(height: 1)

            SectionLabel(title: "Image Picker")

            HStack(spacing: 10) {
                Button {
                    showPhotoLibrary = true
                } label: {
                    PickerCard(emoji: "🖼", title: "Photo Library", footnote: "● iOS PHPicker")
                }
                .buttonStyle(.plain)

                Button {
                    presentCameraIfAvailable()
                } label: {
                    PickerCard(emoji: "📷", title: "Take Photo", footnote: "● Camera capture")
                }
                .buttonStyle(.plain)
            }

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
                onClearTap: selectedImage != nil && !isAnalyzing ? clearSelection : nil
            )

            PrimaryButton(
                title: isAnalyzing ? "Analyzing..." : "Analyze",
                isEnabled: selectedImageData != nil && !isAnalyzing
            ) {
                Task {
                    await analyzeCurrentImage()
                }
            }
            .padding(.top, 4)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
        .photosPicker(isPresented: $showPhotoLibrary, selection: $photoItem, matching: .images)
        .confirmationDialog("Choose image source", isPresented: $showSourcePicker, titleVisibility: .visible) {
            Button("Photo Library") {
                showPhotoLibrary = true
            }

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") {
                    showCamera = true
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Upload an image from your photo library or take a new photo.")
        }
        .onChange(of: photoItem) { _, new in
            guard let new else { return }
            Task {
                if let data = try? await new.loadTransferable(type: Data.self),
                   let ui = UIImage(data: data) {
                    let uploadData = ui.jpegData(compressionQuality: 0.95) ?? data
                    await MainActor.run {
                        setSelectedImage(
                            ui,
                            uploadData: uploadData,
                            fileName: "photo-library-image.jpg"
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(
                image: $selectedImage,
                imageData: $selectedImageData,
                imageFileName: $selectedImageFileName,
                isPresented: $showCamera,
                sourceType: .camera,
                onImageChange: resetAnalysisState
            )
        }
    }

    private func setSelectedImage(_ image: UIImage, uploadData: Data, fileName: String) {
        selectedImage = image
        selectedImageData = uploadData
        selectedImageFileName = fileName
        resetAnalysisState()
    }

    private func resetAnalysisState() {
        analysisResult = nil
        analysisError = nil
    }

    private func clearSelection() {
        photoItem = nil
        selectedImage = nil
        selectedImageData = nil
        selectedImageFileName = nil
        resetAnalysisState()
    }

    private func presentCameraIfAvailable() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showCamera = true
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

        isAnalyzing = true
        resetAnalysisState()

        defer {
            isAnalyzing = false
        }

        do {
            let result = try await apiService.analyzeImage(
                data: selectedImageData,
                filename: fileName,
                mimeType: mimeType
            )

            analysisResult = result
        } catch {
            analysisError = error.localizedDescription
        }
    }
}

private struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var imageData: Data?
    @Binding var imageFileName: String?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    var onImageChange: () -> Void

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
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
                parent.imageData = img.jpegData(compressionQuality: 0.95)
                parent.imageFileName = "camera-capture.jpg"
                parent.onImageChange()
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
        .background(Color.ffBackground)
}
