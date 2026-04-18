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
    @State private var showCamera = false

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
                        PickerCard(emoji: "🖼", title: "Photo Library", footnote: "● iOS PHPicker")
                    }
                    .buttonStyle(.plain)

                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showCamera = true
                        }
                    } label: {
                        PickerCard(emoji: "📷", title: "Take Photo", footnote: "● Camera capture")
                    }
                    .buttonStyle(.plain)
                }

                Rectangle()
                    .fill(Color.ffBorder)
                    .frame(height: 1)

                ResultsCard(selectedImage: selectedImage)

                PrimaryButton(title: "Analyze", isEnabled: selectedImage != nil) {
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .onChange(of: photoItem) { _, new in
            guard let new else { return }
            Task {
                if let data = try? await new.loadTransferable(type: Data.self),
                   let ui = UIImage(data: data) {
                    await MainActor.run { selectedImage = ui }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, isPresented: $showCamera, sourceType: .camera)
        }
    }
}

// MARK: - UIImagePickerController bridge

private struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType

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
