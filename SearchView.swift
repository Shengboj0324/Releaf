import SwiftUI
import SwiftData

@Model
class SearchHistory: Identifiable {
    var id: UUID
    var query: String
    var timestamp: Date
    var category: String
    var imageData: Data?
    var imagePrompt: String
    
    init(query: String, category: String = "general", imageData: Data? = nil, imagePrompt: String = "") {
        self.id = UUID()
        self.query = query
        self.timestamp = Date()
        self.category = category
        self.imageData = imageData
        self.imagePrompt = imagePrompt
    }
}

struct Post: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let imageData: Data?
    let author: String
    let timestamp: Date
    let tags: [String]
}

struct RelatedPostCard: View {
    let post: Post
    
    var body: some View {
        Button {
            // Handle post selection
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                if let imageData = post.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(post.content)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        Text(post.author)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(post.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SearchHistory.timestamp, order: .reverse) private var searchHistory: [SearchHistory]
    
    @Binding var searchText: String
    @State private var isLoading = false
    @State private var searchResult: String?
    @State private var errorMessage: String?
    @State private var relatedPosts: [Post] = []
    @FocusState private var isFocused: Bool
    
    let popularCategories = [
        ("Recycling Tips", "leaf.circle.fill"),
        ("Composting", "trash.circle.fill"),
        ("Energy Saving", "bolt.circle.fill"),
        ("Water Conservation", "drop.circle.fill"),
        ("Sustainable Living", "house.circle.fill"),
        ("Green Technology", "gear.circle.fill")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Ask about sustainability...", text: $searchText)
                            .focused($isFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                Task {
                                    await performSearch()
                                }
                            }
                    }
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if let result = searchResult {
                            Text("Results")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text(result)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        } else if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Related Posts Section
                        if !relatedPosts.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Related Posts")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ],
                                    spacing: 16
                                ) {
                                    ForEach(relatedPosts) { post in
                                        RelatedPostCard(post: post)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Popular Categories
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Popular Categories")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(popularCategories, id: \.0) { category, icon in
                                    Button {
                                        searchText = category
                                        Task {
                                            await performSearch()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: icon)
                                                .foregroundColor(.green)
                                            Text(category)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(UIColor.systemGray6))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Recent Searches
                        if !searchHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Recent Searches")
                                        .font(.headline)
                                    Spacer()
                                    Button("Clear") {
                                        clearHistory()
                                    }
                                    .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                                
                                ForEach(searchHistory.prefix(5)) { history in
                                    Button {
                                        searchText = history.query
                                        Task {
                                            await performSearch()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "clock")
                                                .foregroundColor(.gray)
                                            Text(history.query)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "arrow.up.left")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        searchResult = nil
        errorMessage = nil
        relatedPosts = []
        
        do {
            async let responseTask = ChatGPTService.shared.generateResponse(for: searchText)
            async let promptTask = ChatGPTService.shared.generateImagePrompt(for: searchText)
            
            let (response, imagePrompt) = try await (responseTask, promptTask)
            let imageData = try await ChatGPTService.shared.generateImage(prompt: imagePrompt)
            
            // Save to search history with image
            let newSearch = SearchHistory(
                query: searchText,
                imageData: imageData,
                imagePrompt: imagePrompt
            )
            modelContext.insert(newSearch)
            
            searchResult = response
            
            // Fetch related posts
            await fetchRelatedPosts()
        } catch {
            errorMessage = "Sorry, couldn't process your request. Please try again."
            print("Error: \(error)")
        }
        
        isLoading = false
    }
    
    private func fetchRelatedPosts() async {
        // Simulated fetch of related posts
        // In a real app, this would make an API call to your backend
        let samplePosts = [
            Post(
                title: "Sustainable Living Tips",
                content: "Learn how to reduce your carbon footprint with these simple daily habits.",
                imageData: nil,
                author: "EcoExpert",
                timestamp: Date().addingTimeInterval(-86400),
                tags: ["sustainability", "eco-friendly", "lifestyle"]
            ),
            Post(
                title: "Urban Gardening Guide",
                content: "Transform your balcony into a thriving garden with these expert tips.",
                imageData: nil,
                author: "GreenThumb",
                timestamp: Date().addingTimeInterval(-172800),
                tags: ["gardening", "urban", "plants"]
            ),
            Post(
                title: "Zero Waste Journey",
                content: "My experience transitioning to a zero-waste lifestyle over 6 months.",
                imageData: nil,
                author: "EcoWarrior",
                timestamp: Date().addingTimeInterval(-259200),
                tags: ["zero-waste", "sustainability", "lifestyle"]
            ),
            Post(
                title: "Composting 101",
                content: "Everything you need to know about starting your own compost bin.",
                imageData: nil,
                author: "EarthLover",
                timestamp: Date().addingTimeInterval(-345600),
                tags: ["composting", "gardening", "eco-friendly"]
            )
        ]
        
        // Filter posts based on search text
        relatedPosts = samplePosts.filter { post in
            let searchTerms = searchText.lowercased().split(separator: " ")
            return searchTerms.contains { term in
                post.title.lowercased().contains(term) ||
                post.content.lowercased().contains(term) ||
                post.tags.contains { $0.lowercased().contains(term) }
            }
        }
    }
    
    private func clearHistory() {
        for item in searchHistory {
            modelContext.delete(item)
        }
    }
} 
