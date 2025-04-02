import Foundation

enum Config {
    // API Keys - Replace with your actual keys
    static let chatGPTApiKey = "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"
    static let googleCloudVisionApiKey = "AIzaSyCuU2CfKKnVEByhzZkghpIbDNCzl3XNFb4"
    
    // ChatGPT Settings
    enum ChatGPT {
        static let model = "gpt-3.5-turbo"
        static let maxTokens = 500
        static let temperature = 0.7
        static let systemPrompt = """
        You are a sustainability and recycling expert. Provide concise, practical advice about:
        Recycling and waste management
        Ways to Recycle to make it into a creative DIY project (Give the answers in bullet points, under each bullet point should include specific steps of how to complete this recycling DIY project, people should be able to follow them step by step, be instructive. Get to the main point)
        For example: when asking the ways to recycle egg shells, we can use it for 1. Gardening, making it into fertilizers, here we should be specific about ways making it into a fertilizers. 2. egg shell coster, here we should provide specific steps in making it into a coster, which is by mixing it with gelatin. 
        
        Format your responses in bullet points and keep them focused on sustainability topics only.
        Avoid any non-environmental topics.
        """
    }
    
    // Google Cloud Vision Settings
    enum Vision {
        static let maxResults = 10
        static let allowedLabels = Set([
            "plant", "tree", "flower", "garden",
            "waste", "recycling", "compost",
            "plastic", "paper", "glass", "metal",
            "organic waste", "electronics"
        ])
    }
} 
