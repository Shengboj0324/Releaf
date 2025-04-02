import Foundation

class ChatGPTService {
    static let shared = ChatGPTService()
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    
    private init() {
        self.apiKey = Config.chatGPTApiKey
    }
    
    private func makeRequest(endpoint: String, body: [String: Any]) async throws -> Data {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
    
    func generateResponse(for query: String) async throws -> String {
        let messages: [[String: String]] = [
            ["role": "system", "content": Config.ChatGPT.systemPrompt],
            ["role": "user", "content": query]
        ]
        
        let requestBody: [String: Any] = [
            "model": Config.ChatGPT.model,
            "messages": messages,
            "max_tokens": Config.ChatGPT.maxTokens,
            "temperature": Config.ChatGPT.temperature
        ]
        
        let data = try await makeRequest(endpoint: "chat/completions", body: requestBody)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return content
    }
    
    func generateImagePrompt(for query: String) async throws -> String {
        let promptRequest = """
        Create a brief, vivid, and artistic image prompt for DALL-E based on this sustainability-related search: "\(query)".
        The prompt should be focused on environmental and sustainability themes.
        Keep it under 50 words and make it visually descriptive.
        Only return the prompt text, nothing else.
        """
        
        return try await generateResponse(for: promptRequest)
    }
    
    func generateImage(prompt: String) async throws -> Data {
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "n": 1,
            "size": "512x512",
            "response_format": "b64_json"
        ]
        
        let data = try await makeRequest(endpoint: "images/generations", body: requestBody)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = json["data"] as? [[String: Any]],
              let firstImage = dataArray.first,
              let base64Image = firstImage["b64_json"] as? String,
              let imageData = Data(base64Encoded: base64Image) else {
            throw URLError(.cannotParseResponse)
        }
        
        return imageData
    }
} 
