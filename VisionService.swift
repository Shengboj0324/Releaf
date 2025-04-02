import Foundation
import UIKit

class VisionService {
    static let shared = VisionService()
    private let apiKey: String
    private let baseURL = "https://vision.googleapis.com/v1/images:annotate"
    
    private init() {
        self.apiKey = Config.googleCloudVisionApiKey
    }
    
    func analyzeImage(_ image: UIImage) async throws -> [String] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeRawData)
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "requests": [
                [
                    "image": ["content": base64Image],
                    "features": [
                        ["type": "LABEL_DETECTION", "maxResults": Config.Vision.maxResults]
                    ]
                ]
            ]
        ]
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responses = json["responses"] as? [[String: Any]],
              let firstResponse = responses.first,
              let labelAnnotations = firstResponse["labelAnnotations"] as? [[String: Any]] else {
            throw URLError(.cannotParseResponse)
        }
        
        // Filter labels based on allowed set and confidence score
        let labels = labelAnnotations.compactMap { annotation -> String? in
            guard let description = annotation["description"] as? String,
                  let score = annotation["score"] as? Double,
                  score >= 0.7, // Only include labels with 70% or higher confidence
                  Config.Vision.allowedLabels.contains(description.lowercased()) else {
                return nil
            }
            return description
        }
        
        return labels
    }
} 
