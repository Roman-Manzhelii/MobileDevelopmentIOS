//
//  DetectorView.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import PhotosUI
import SwiftUI
import UIKit

enum DetectorImageConfiguration {
    static let bundledResourceName = "testImage"
    static let bundledResourceExtension = "png"
    static let bundledFileName = "\(bundledResourceName).\(bundledResourceExtension)"
    static let photoLibraryFileName = "photo-library-image.jpg"
    static let cameraCaptureFileName = "camera-capture.jpg"

    static func uploadDetails(for fileName: String?) -> (fileName: String, mimeType: String) {
        let resolvedFileName = fileName ?? "image.jpg"
        let mimeType = resolvedFileName.lowercased().hasSuffix(".png") ? "image/png" : "image/jpeg"
        return (resolvedFileName, mimeType)
    }
}

struct DetectorView: View {
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImageData: Data?
    @State private var selectedImageFileName: String?
    @State private var showCamera = false
    @State private var isAnalyzing = false
    @State private var analysisResult: AiclipseCheckResponse?
    @State private var analysisError: String?

    private let apiService = AiclipseAPIService.shared

    var body: some View {
        ScrollView {
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
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        PickerCard(emoji: "IMG", title: "Photo Library", footnote: "- iOS PHPicker")
                    }
                    .buttonStyle(.plain)

                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCamera = true
                        }
                    } label: {
                        PickerCard(emoji: "CAM", title: "Take Photo", footnote: "- Camera capture")
                    }
                    .buttonStyle(.plain)
                }

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                ResultsCard(
                    selectedImage: selectedImage,
                    sourceFileName: selectedImageFileName,
                    analysisResult: analysisResult,
                    isAnalyzing: isAnalyzing,
                    errorMessage: analysisError
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

                Text("Default source is bundled `testImage.png`. If you pick another photo, that image will be analyzed instead.")
                    .font(.caption2)
                    .foregroundStyle(Color.ffTextMuted)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .task {
            loadBundledTestImageIfNeeded()
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
                            fileName: DetectorImageConfiguration.photoLibraryFileName
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

    private func loadBundledTestImageIfNeeded() {
        guard selectedImage == nil else { return }

        guard let url = Bundle.main.url(
            forResource: DetectorImageConfiguration.bundledResourceName,
            withExtension: DetectorImageConfiguration.bundledResourceExtension
        ),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            analysisError = "Could not load bundled \(DetectorImageConfiguration.bundledFileName). Make sure the file is included in the app target."
            return
        }

        selectedImage = image
        selectedImageData = data
        selectedImageFileName = DetectorImageConfiguration.bundledFileName
    }

    @MainActor
    private func analyzeCurrentImage() async {
        guard let selectedImageData else {
            analysisError = "No image is available for analysis."
            return
        }

        let uploadDetails = DetectorImageConfiguration.uploadDetails(for: selectedImageFileName)

        isAnalyzing = true
        resetAnalysisState()

        defer {
            isAnalyzing = false
        }

        do {
            let result = try await apiService.analyzeImage(
                data: selectedImageData,
                filename: uploadDetails.fileName,
                mimeType: uploadDetails.mimeType
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
                parent.imageFileName = DetectorImageConfiguration.cameraCaptureFileName
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
