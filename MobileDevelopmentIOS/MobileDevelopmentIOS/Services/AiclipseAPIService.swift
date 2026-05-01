//
//  AiclipseAPIService.swift
//  MobileDevelopmentIOS
//
//  Created by Student on 23/03/2026.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct AiclipseCheckResponse: Decodable {
    let verdict: String?
    let label: String
    let confidence: Double?
    let modelVersion: String?
    let detectionToken: String?

    enum CodingKeys: String, CodingKey {
        case verdict
        case label
        case confidence
        case modelVersion = "model_version"
        case detectionToken = "detection_token"
    }

    private var normalizedLabel: String {
        label.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    var isAIGenerated: Bool {
        normalizedLabel == "fake"
    }

    var aiProbability: Double {
        switch normalizedLabel {
        case "real":
            return 0
        case "suspicious":
            return 0.5
        case "fake":
            return 1
        default:
            return 0.5
        }
    }

    var displayLabel: String {
        switch normalizedLabel {
        case "real":
            return "Real"
        case "suspicious":
            return "Suspicious"
        case "fake":
            return "Fake"
        default:
            return label
        }
    }
}

enum AiclipseAPIError: LocalizedError {
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case let .requestFailed(statusCode, message):
            if let message, !message.isEmpty {
                return "Aiclipse request failed (\(statusCode)): \(message)"
            }
            return "Aiclipse request failed with status code \(statusCode)."
        }
    }
}

final class AiclipseAPIService {
    static let shared = AiclipseAPIService()

    private enum Constants {
        static let endpoint = URL(string: "https://aiclipse.online/api/v1/checks")!
        static let apiKey = "ak_e2b1c088-602f-4f62-af39-328db521a552.sk_6BPSln22DhUtm8FiH1hQ7Rhs0MmJmoypTFFr5M6-iyo"
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func analyzeImage(data: Data, filename: String, mimeType: String) async throws -> AiclipseCheckResponse {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: Constants.endpoint)
        request.httpMethod = "POST"
        request.setValue(Constants.apiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeMultipartBody(data: data, filename: filename, mimeType: mimeType, boundary: boundary)

        let (responseData, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AiclipseAPIError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            let message = extractErrorMessage(from: responseData)
            throw AiclipseAPIError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        return try JSONDecoder().decode(AiclipseCheckResponse.self, from: responseData)
    }

    private func makeMultipartBody(data: Data, filename: String, mimeType: String, boundary: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\(lineBreak)")
        body.append("Content-Type: \(mimeType)\(lineBreak)\(lineBreak)")
        body.append(data)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")

        return body
    }

    private func extractErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = json["message"] as? String {
                return message
            }
            if let error = json["error"] as? String {
                return error
            }
        }

        let text = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text?.isEmpty == false ? text : nil
    }
}

private extension Data {
    mutating func append(_ string: String) {
        append(Data(string.utf8))
    }
}
