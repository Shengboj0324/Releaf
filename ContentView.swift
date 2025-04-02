//
//  ContentView.swift
//  Releaf
//
//  Created by Micheal Jiang on 31/03/2025.
//

import SwiftUI
import SwiftData
import MapKit
import PhotosUI

// Model for popular searches
struct PopularSearch: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    @State private var showingReward = false
    var onCamera: () -> Void
    
    private func awardSearchWaterDrops(isCamera: Bool) {
        let amount = isCamera ? 20 : 10
        let currentAmount = UserDefaults.standard.integer(forKey: "searchWaterDrops")
        UserDefaults.standard.set(currentAmount + amount, forKey: "searchWaterDrops")
        UserStats.shared.addWaterDrops(amount)
        NotificationCenter.default.post(name: NSNotification.Name("SearchWaterDropsChanged"), object: nil)
        showingReward = true
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Search Container
                VStack(spacing: 16) {
                    // Search Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recycling Inspirations")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Separate garbage into mixed waste and\nrecyclables at one touch, starts here")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    HStack(spacing: 12) {
                        Button {
                            isSearching = true
                            awardSearchWaterDrops(isCamera: false)
                    } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text("Ask about sustainability...")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                        }

                        Button {
                            onCamera()
                            awardSearchWaterDrops(isCamera: true)
                        } label: {
                            Image(systemName: "camera")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.6, blue: 0.4),
                                    Color(red: 0.1, green: 0.4, blue: 0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            ZStack {
                                // Background pattern
                                ForEach(0..<20) { i in
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: CGFloat.random(in: 20...60))
                                        .position(
                                            x: CGFloat.random(in: -20...400),
                                            y: CGFloat.random(in: -20...200)
                                        )
                                }
                            }
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 5)
                )
                .padding(.horizontal, 16)
            }
            
            if showingReward {
                WaterDropRewardView(amount: isSearching ? 10 : 20, isPresented: $showingReward)
            }
        }
    }
}

struct PopularSearchGrid: View {
    @Query(sort: \SearchHistory.timestamp, order: .reverse) private var searchHistory: [SearchHistory]
    @State private var showingAllSearches = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Text("Popular Search")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                Button {
                    showingAllSearches = true
                } label: {
                    Text("See More")
                        .foregroundColor(.green)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal, 24)
            
            if searchHistory.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                        .frame(height: 40)
                    
                    Text("No searches yet")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Your search history will appear here")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(searchHistory.prefix(6)) { history in
                        SearchImageCard(history: history)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $showingAllSearches) {
            AllSearchesView(searches: Array(searchHistory))
        }
    }
}

struct SearchImageCard: View {
    let history: SearchHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = history.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
            }
            
            Text(history.query)
                .font(.caption)
                .lineLimit(2)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AllSearchesView: View {
    @Environment(\.dismiss) private var dismiss
    let searches: [SearchHistory]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if searches.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                            .frame(height: 60)
                        
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No searches yet")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text("Try searching for sustainability topics")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(searches) { history in
                            SearchImageCard(history: history)
                                .frame(height: 160)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("All Searches")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MapSection: View {
    enum MapTab {
        case users, planters
    }
    
    @State private var selectedTab: MapTab = .users
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.0, longitude: -100.0),
        span: MKCoordinateSpan(latitudeDelta: 70, longitudeDelta: 70)
    )
    @State private var userLocation: CLLocationCoordinate2D?
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Our Home of Sustainability")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                // Tab buttons
                HStack(spacing: 0) {
                    TabButton(
                        title: "Accumulated users",
                        isSelected: selectedTab == .users,
                        action: { selectedTab = .users }
                    )
                    TabButton(
                        title: "Tree planters",
                        isSelected: selectedTab == .planters,
                        action: { selectedTab = .planters }
                    )
                }
                .background(Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Map
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: .none,
                    annotationItems: selectedTab == .users ? mockUsers : mockPlanters
                ) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        LocationDot(type: selectedTab)
                    }
                }
                .frame(height: 400)
                .colorScheme(.dark)
            }
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 24)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(10)
        }
        .padding(.horizontal, 8)
    }
}

struct LocationDot: View {
    let type: MapSection.MapTab
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(type == .users ? Color.blue : Color.green)
                .frame(width: 8, height: 8)
            
            Circle()
                .stroke(type == .users ? Color.blue : Color.green, lineWidth: 2)
                .frame(width: 16, height: 16)
                .opacity(isAnimating ? 0 : 0.5)
                .scaleEffect(isAnimating ? 2 : 1)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
}

// Mock data for the map
struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

let mockUsers = [
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)), // New York
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)), // Los Angeles
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 51.0447, longitude: -114.0719)), // Calgary
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)), // Mexico City
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673)), // Montreal
]

let mockPlanters = [
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)), // San Francisco
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298)), // Chicago
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207)), // Vancouver
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)), // Miami
    MapLocation(coordinate: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832)), // Toronto
]

struct HomeView: View {
    @StateObject private var userStats = UserStats()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    SearchBar(text: $searchText,
                            isSearching: $isSearching,
                            onCamera: {
                                showingCamera = true
                            })
                    
                    PopularSearchGrid()
                    
                    // Stats section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Impact")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 24)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(title: "PLANTED", value: String(userStats.treesPlanted), unit: "trees")
                            StatCard(title: "GROWTH", value: String(userStats.growthDays), unit: "days")
                            StatCard(title: "ACHIEVEMENTS", value: String(userStats.achievements), unit: "earned")
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    MapSection()
                }
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $isSearching) {
                SearchView(searchText: $searchText)
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(image: $capturedImage, isShowing: $showingCamera) { image in
                    if let image = image {
                        capturedImage = image
                        isSearching = true
                    }
                }
            }
            .onAppear {
                userStats.fetchUserStats()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(UIColor.systemGray6),
                            Color(UIColor.systemBackground)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
    }
}

// Add these before TreesView
enum TreeStage: Int, CaseIterable {
    case seed = 0
    case sapling
    case sprout
    case mature
    
    var name: String {
        switch self {
        case .seed: return "Seed"
        case .sapling: return "Sapling"
        case .sprout: return "Sprout"
        case .mature: return "Mature"
        }
    }
    
    var height: Double {
        switch self {
        case .seed: return 0.1
        case .sapling: return 0.5
        case .sprout: return 1.2
        case .mature: return 2.5
        }
    }
}

struct TreeType: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let features: [String]
    let icon: String
}

struct WaterDrop: Identifiable {
    let id = UUID()
    var position: CGPoint
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
}

// Add this before TreesView
struct ShareOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showingPostView: Bool
    @ObservedObject var viewModel: TreeViewModel
    @State private var showingShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Share preview
            VStack(spacing: 16) {
                Text("Share Tree Progress")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "tree.fill")
                            .foregroundColor(.green)
                        Text("Current Height: \(viewModel.formattedHeight())")
                    }
                    
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.blue)
                        Text("Water Drops: \(viewModel.waterDrops)")
                    }
                    
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text("Stage: \(viewModel.currentStage.name)")
                    }
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.vertical)
            
            // Action buttons
            VStack(spacing: 20) {
                Button {
                    showingShareSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                        Text("Share")
                            .font(.system(size: 20))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
                
                Button {
                    showingPostView = true
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                        Text("Post Accomplishment")
                            .font(.system(size: 20))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(
                activityItems: [
                    generateShareText(),
                    takeScreenshot()
                ]
            )
        }
    }
    
    private func generateShareText() -> String {
        """
        🌱 My Tree Progress in Releaf 
        Height: \(viewModel.formattedHeight())
        Stage: \(viewModel.currentStage.name)
        Water Drops: \(viewModel.waterDrops)
        
        Join me in making the world greener! 
        """
    }
    
    private func takeScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds)
        return renderer.image { ctx in
            UIApplication.shared.windows.first?.layer.render(in: ctx.cgContext)
        }
    }
}

// Add this new ShareSheet struct to handle native sharing
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        
        // Configure excluded activity types to match iOS default share sheet
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .saveToCameraRoll
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct PostAccomplishmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingReward = false
    
    private func handlePost() {
        let rewardAmount = 30
        let currentAmount = UserDefaults.standard.integer(forKey: "postWaterDrops")
        UserDefaults.standard.set(currentAmount + rewardAmount, forKey: "postWaterDrops")
        UserStats.shared.addWaterDrops(rewardAmount)
        NotificationCenter.default.post(name: NSNotification.Name("PostWaterDropsChanged"), object: nil)
        showingReward = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Image selection
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                        } else {
                            Button {
                                showingImagePicker = true
                            } label: {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                    Text("Add Photo")
                                        .font(.caption)
                                }
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Text input
                        TextEditor(text: $postText)
                            .frame(height: 150)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Spacer()
                    }
                    .padding()
                }
                
                if showingReward {
                    WaterDropRewardView(amount: 30, isPresented: $showingReward)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        handlePost()
                    }
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

// Update AccountManager
struct AccountManager {
    static let shared = AccountManager()
    
    var isLoggedIn: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isLoggedIn")
        }
    }
    
    func createAccount(name: String, email: String) {
        UserDefaults.standard.set(name, forKey: "accountName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        // Initialize water drops for new account
        if UserDefaults.standard.integer(forKey: "userWaterDrops") == 0 {
            UserDefaults.standard.set(100, forKey: "userWaterDrops") // Give initial water drops
            NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
        }
    }
    
    func deleteAccount() {
        // Reset all user data
        UserDefaults.standard.set("Your Name", forKey: "accountName")
        UserDefaults.standard.set("username@example.com", forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userProfileImage")
        UserDefaults.standard.set(0, forKey: "userPosts")
        UserDefaults.standard.set(0, forKey: "userTracking")
        UserDefaults.standard.set(0, forKey: "userFollowers")
        UserDefaults.standard.set(0, forKey: "userWaterDrops")
        UserDefaults.standard.set(0, forKey: "userTreesPlanted")
        UserDefaults.standard.set(0, forKey: "userAchievements")
        UserDefaults.standard.set(0.1, forKey: "treeHeight")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        
        // Notify observers
        NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
        NotificationCenter.default.post(name: .accountDeleted, object: nil)
    }
}

// Add this to Notification.Name extension
extension Notification.Name {
    static let accountDeleted = Notification.Name("accountDeleted")
}

// Update TreeViewModel class
class TreeViewModel: ObservableObject {
    @Published var currentStage: TreeStage = .seed
    @Published var waterDrops: Int = 0
    @Published var showingTreeSelector = false
    @Published var isWatering = false
    @Published var activeWaterDrops: [WaterDrop] = []
    @Published var selectedTree: TreeType?
    @Published var showingShareOptions = false
    @Published var showingPostView = false
    @Published var currentHeight: Double = 0.1 // Starting height
    @Published var measurementUnit: String = UserDefaults.standard.string(forKey: "selectedUnit") ?? "Metric"
    @Published var showingLoginAlert = false
    private var heightObserver: NSObjectProtocol?
    
    private var cancellable: NSObjectProtocol?
    
    let treeTypes = [
        TreeType(
            name: "Oak",
            description: "A mighty oak tree that can live for centuries. Known for its strong wood and abundant acorns.",
            features: ["Long lifespan: 100+ years", "Height: Up to 100 feet", "Native to: Northern Hemisphere"],
            icon: "leaf.circle.fill"
        ),
        TreeType(
            name: "Pine",
            description: "An evergreen conifer with needle-like leaves. Perfect for year-round greenery.",
            features: ["Evergreen", "Height: 50-150 feet", "Fast growing"],
            icon: "leaf.arrow.triangle.circlepath"
        ),
        TreeType(
            name: "Maple",
            description: "Known for its distinctive leaf shape and vibrant fall colors.",
            features: ["Beautiful fall colors", "Height: 40-100 feet", "Shade providing"],
            icon: "leaf.fill"
        ),
        TreeType(
            name: "Cherry",
            description: "Beautiful flowering tree with spring blossoms. Perfect for gardens.",
            features: ["Spring blossoms", "Height: 20-40 feet", "Ornamental beauty"],
            icon: "flower.2"
        ),
        TreeType(
            name: "Willow",
            description: "Graceful tree with drooping branches, perfect near water features.",
            features: ["Flexible branches", "Height: 30-70 feet", "Water-loving"],
            icon: "wind"
        ),
        TreeType(
            name: "Birch",
            description: "Elegant tree with distinctive white bark and delicate leaves.",
            features: ["White bark", "Height: 40-70 feet", "Fast growing"],
            icon: "leaf.circle"
        ),
        TreeType(
            name: "Redwood",
            description: "Majestic giant known for its incredible height and longevity.",
            features: ["Extremely tall", "Height: 200-300 feet", "Long-lived"],
            icon: "arrow.up.to.line"
        ),
        TreeType(
            name: "Palm",
            description: "Tropical tree perfect for warm climates and coastal areas.",
            features: ["Tropical climate", "Height: 30-100 feet", "Drought resistant"],
            icon: "sun.max.fill"
        )
    ]
    
    init() {
        // Load saved height
        currentHeight = UserDefaults.standard.double(forKey: "treeHeight")
        
        // Initialize water drops from UserDefaults to ensure consistency
        waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
        
        // Observe water drops changes
        cancellable = NotificationCenter.default.addObserver(
            forName: .waterDropsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
        }
        
        // Observe account deletion
        heightObserver = NotificationCenter.default.addObserver(
            forName: .accountDeleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.currentHeight = 0.1
        }
        
        // Observe measurement unit changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MeasurementUnitChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let unit = notification.object as? String {
                self?.measurementUnit = unit
            }
        }
    }
    
    deinit {
        if let cancellable = cancellable {
            NotificationCenter.default.removeObserver(cancellable)
        }
        if let heightObserver = heightObserver {
            NotificationCenter.default.removeObserver(heightObserver)
        }
    }
    
    func addWater() {
        guard AccountManager.shared.isLoggedIn else {
            showingLoginAlert = true
            return
        }
        
        if UserStats.shared.waterDrops >= 2 {
            UserStats.shared.useWaterDrops(2)
            currentHeight += 0.2
            UserDefaults.standard.set(currentHeight, forKey: "treeHeight")
            
            // Update local water drops immediately
            waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
            
            // Increment trees planted every 200 water drops
            if waterDrops % 200 == 0 {
                let currentTrees = UserDefaults.standard.integer(forKey: "userTreesPlanted")
                UserDefaults.standard.set(currentTrees + 1, forKey: "userTreesPlanted")
                
                if currentStage != .mature {
                    withAnimation(.spring()) {
                        currentStage = TreeStage(rawValue: currentStage.rawValue + 1) ?? .mature
                    }
                }
            }
        }
    }
    
    // Convert meters to feet
    func metersToFeet(_ meters: Double) -> Double {
        return meters * 3.28084
    }
    
    // Get formatted height string based on current unit
    func formattedHeight() -> String {
        let height = measurementUnit == "Metric" ? currentHeight : metersToFeet(currentHeight)
        let unit = measurementUnit == "Metric" ? "m" : "ft"
        return String(format: "%.1f %@", height, unit)
    }
}

struct TreeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TreeViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.treeTypes) { tree in
                        Button {
                            viewModel.selectedTree = tree
                            dismiss()
                        } label: {
                            TreeOptionCard(tree: tree)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Tree Type")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TreeOptionCard: View {
    let tree: TreeType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: tree.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                Text(tree.name)
                    .font(.headline)
                Spacer()
            }
            
            // Description
            Text(tree.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            // Features
            VStack(alignment: .leading, spacing: 6) {
                ForEach(tree.features, id: \.self) { feature in
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TreeView: View {
    let stage: TreeStage
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.5
            
            ZStack {
                // Tree visualization based on stage
                switch stage {
                case .seed:
                    // Seed with more detail
                    ZStack {
                        // Seed body
                        Ellipse()
                            .fill(Color.brown)
                            .frame(width: size * 0.2, height: size * 0.25)
                        
                        // Seed details
                        Ellipse()
                            .stroke(Color.brown.opacity(0.6), lineWidth: 1)
                            .frame(width: size * 0.15, height: size * 0.2)
                    }
                    
                case .sapling:
                    // Young sapling with simple leaves
                    VStack(spacing: -5) {
                        // Small crown
                        ForEach(0..<3) { layer in
                            LeafCluster(size: size * 0.2, angle: Double(layer) * 25)
                                .foregroundColor(.green)
                                .offset(y: -CGFloat(layer) * 10)
                        }
                        
                        // Thin trunk
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: size * 0.08, height: size * 0.3)
                    }
                    
                case .sprout:
                    // Growing tree with more branches
                    VStack(spacing: -15) {
                        // Larger crown
                        ForEach(0..<5) { layer in
                            LeafCluster(size: size * 0.25, angle: Double(layer) * 20)
                                .foregroundColor(.green)
                                .offset(y: -CGFloat(layer) * 15)
                        }
                        
                        // Thicker trunk with subtle texture
                        ZStack {
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            // Bark texture
                            ForEach(0..<4) { i in
                                Rectangle()
                                    .fill(Color.brown.opacity(0.3))
                                    .frame(width: 2, height: size * 0.4)
                                    .offset(x: CGFloat(i * 5) - 7.5)
                            }
                        }
                        .frame(width: size * 0.12, height: size * 0.5)
                    }
                    
                case .mature:
                    // Majestic oak tree
                    VStack(spacing: -30) {
                        // Full crown with multiple layers
                        ZStack {
                            // Main crown layers
                            ForEach(0..<7) { layer in
                                LeafCluster(size: size * (0.8 - Double(layer) * 0.05), angle: Double(layer) * 15)
                                    .foregroundColor(Color.green.opacity(0.8 + Double(layer) * 0.03))
                                    .offset(y: -CGFloat(layer) * 20)
                            }
                            
                            // Additional detail layers
                            ForEach(0..<5) { layer in
                                LeafCluster(size: size * (0.7 - Double(layer) * 0.05), angle: -Double(layer) * 20)
                                    .foregroundColor(Color.green.opacity(0.9))
                                    .offset(y: -CGFloat(layer) * 25)
                            }
                            
                            // Highlight layers for depth
                            ForEach(0..<3) { layer in
                                LeafCluster(size: size * (0.6 - Double(layer) * 0.05), angle: Double(layer) * 30)
                                    .foregroundColor(Color.green.opacity(0.7))
                                    .offset(y: -CGFloat(layer) * 30)
                            }
                        }
                        
                        // Detailed trunk with texture
                        ZStack {
                            // Main trunk
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.2, blue: 0.1),
                                        Color(red: 0.6, green: 0.3, blue: 0.1)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            // Bark texture
                            ForEach(0..<8) { i in
                                Rectangle()
                                    .fill(Color.brown.opacity(0.3))
                                    .frame(width: 3, height: size * 0.8)
                                    .offset(x: CGFloat(i * 8) - 28)
                            }
                            
                            // Trunk highlights
                            ForEach(0..<4) { i in
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 2, height: size * 0.8)
                                    .offset(x: CGFloat(i * 15) - 22.5)
                            }
                        }
                        .frame(width: size * 0.25, height: size * 0.8)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// Add this helper view for creating leaf clusters
struct LeafCluster: View {
    let size: Double
    let angle: Double
    
    var body: some View {
        ZStack {
            // Center leaves
            ForEach(0..<5) { i in
                Leaf()
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(Double(i) * 72 + angle))
            }
            
            // Outer leaves for fuller appearance
            ForEach(0..<8) { i in
                Leaf()
                    .frame(width: size * 0.8, height: size * 0.8)
                    .rotationEffect(.degrees(Double(i) * 45 + angle + 22.5))
            }
        }
    }
}

// Add this helper view for individual leaves
struct Leaf: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                path.move(to: CGPoint(x: width * 0.5, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: width, y: height * 0.5),
                    control: CGPoint(x: width * 0.9, y: height * 0.1)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width * 0.5, y: height),
                    control: CGPoint(x: width * 0.9, y: height * 0.9)
                )
                path.addQuadCurve(
                    to: CGPoint(x: 0, y: height * 0.5),
                    control: CGPoint(x: width * 0.1, y: height * 0.9)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width * 0.5, y: 0),
                    control: CGPoint(x: width * 0.1, y: height * 0.1)
                )
            }
        }
    }
}

// Add these structs before TreesView
struct ActivityBubble: Identifiable {
    let id = UUID()
    let type: ActivityType
    var position: CGPoint
    var velocity: CGPoint
    var scale: CGFloat = 1.0
    
    enum ActivityType {
        case search, donation, post
        
        var icon: String {
            switch self {
            case .search: return "magnifyingglass"
            case .donation: return "heart.fill"
            case .post: return "square.and.pencil"
            }
        }
        
        var color: Color {
            switch self {
            case .search: return Color(red: 0.3, green: 0.7, blue: 1.0)
            case .donation: return Color(red: 1.0, green: 0.5, blue: 0.5)
            case .post: return Color(red: 0.5, green: 0.8, blue: 0.5)
            }
        }
        
        var title: String {
            switch self {
            case .search: return "Search Rewards"
            case .donation: return "Donation Rewards"
            case .post: return "Post Rewards"
            }
        }
        
        func getWaterDrops() -> Int {
            let defaults = UserDefaults.standard
            switch self {
            case .search:
                return defaults.integer(forKey: "searchWaterDrops")
            case .donation:
                return defaults.integer(forKey: "donationWaterDrops")
            case .post:
                return defaults.integer(forKey: "postWaterDrops")
            }
        }
    }
}

struct FloatingBubble: View {
    let type: ActivityBubble.ActivityType
    @State private var animating = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(type.color.opacity(0.3))
                .frame(width: 70, height: 70)
                .blur(radius: 10)
            
            // Main bubble
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            type.color.opacity(0.9),
                            type.color.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: type.color.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // Content Stack
            VStack(spacing: 4) {
                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                // Water drops count
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10))
                    Text("\(type.getWaterDrops())")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
            }
        }
        .scaleEffect(animating ? 1.1 : 1.0)
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                animating = true
            }
        }
    }
}

struct RewardCounterView: View {
    let type: ActivityBubble.ActivityType
    @Binding var isPresented: Bool
    @State private var countedValue: Int = 0
    let finalValue: Int
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
        withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 20) {
                // Header
                Text(type.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Counter circle
                ZStack {
                    Circle()
                        .fill(type.color.opacity(0.2))
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .fill(type.color.opacity(0.4))
                        .frame(width: 140, height: 140)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.white)
                            Text("\(countedValue)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Water Drops")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .onAppear {
                    // Animate counting
                    withAnimation(.easeOut(duration: 2.0)) {
                        for i in 0...finalValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (2.0 / Double(finalValue))) {
                                countedValue = i
                            }
                        }
                    }
                }
                
                // Activity icon
                Image(systemName: type.icon)
                    .font(.system(size: 30))
                    .foregroundColor(type.color)
                    .padding()
                    .background(Circle().fill(Color.white))
                    .shadow(color: type.color.opacity(0.5), radius: 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(UIColor.systemGray6).opacity(0.95))
                    .shadow(radius: 20)
            )
            .padding(40)
        }
    }
}

// Update TreesView to include floating bubbles
struct TreesView: View {
    @StateObject private var viewModel = TreeViewModel()
    @State private var waterDropPositions: [CGPoint] = []
    @State private var showingManageAccount = false
    @State private var activityBubbles: [ActivityBubble] = []
    @State private var selectedActivity: ActivityBubble.ActivityType?
    @State private var showingRewardCounter = false
    @State private var searchWaterDrops: Int = UserDefaults.standard.integer(forKey: "searchWaterDrops")
    @State private var donationWaterDrops: Int = UserDefaults.standard.integer(forKey: "donationWaterDrops")
    @State private var postWaterDrops: Int = UserDefaults.standard.integer(forKey: "postWaterDrops")
    
    let timer = Timer.publish(every: 0.033, on: .main, in: .common).autoconnect() // Slower update rate
    
    private func initializeActivityBubbles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Position bubbles in the upper middle area
        activityBubbles = [
            ActivityBubble(
                type: .search,
                position: CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.25),
                velocity: CGPoint(x: 0.3, y: 0.3) // Slower movement
            ),
            ActivityBubble(
                type: .donation,
                position: CGPoint(x: screenWidth * 0.7, y: screenHeight * 0.2),
                velocity: CGPoint(x: -0.3, y: 0.3) // Slower movement
            ),
            ActivityBubble(
                type: .post,
                position: CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.3),
                velocity: CGPoint(x: 0.3, y: -0.3) // Slower movement
            )
        ]
    }
    
    private func updateBubblePositions() {
        let bounds = UIScreen.main.bounds
        let minY: CGFloat = 100 // Minimum Y position
        let maxY: CGFloat = bounds.height * 0.4 // Maximum Y position (40% of screen height)
        let padding: CGFloat = 40
        
        for i in activityBubbles.indices {
            // Update position
            activityBubbles[i].position.x += activityBubbles[i].velocity.x
            activityBubbles[i].position.y += activityBubbles[i].velocity.y
            
            // Bounce off edges with position constraints
            if activityBubbles[i].position.x <= padding || activityBubbles[i].position.x >= bounds.width - padding {
                activityBubbles[i].velocity.x *= -1
            }
            if activityBubbles[i].position.y <= minY || activityBubbles[i].position.y >= maxY {
                activityBubbles[i].velocity.y *= -1
            }
            
            // Ensure position stays within bounds
            activityBubbles[i].position.x = max(padding, min(bounds.width - padding, activityBubbles[i].position.x))
            activityBubbles[i].position.y = max(minY, min(maxY, activityBubbles[i].position.y))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.7, blue: 1.0),
                        Color(red: 0.4, green: 0.8, blue: 0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    // Height indicator and water drops
                    HStack {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(viewModel.formattedHeight())
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(viewModel.currentStage.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.9))
                        )
                        
                        Spacer()
                        
                        // Water drops counter
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("\(viewModel.waterDrops)")
                                .font(.headline)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.9))
                        )
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Tree and floating bubbles
                    ZStack {
                        TreeView(stage: viewModel.currentStage)
                            .frame(height: 300)
                        
                        // Floating activity bubbles
                        ForEach(activityBubbles) { bubble in
                            FloatingBubble(type: bubble.type)
                                .position(bubble.position)
                                .onTapGesture {
                                    selectedActivity = bubble.type
                                    showingRewardCounter = true
                                }
                        }
                        
                        ForEach(viewModel.activeWaterDrops) { drop in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: CGFloat.random(in: 4...8))
                                .position(drop.position)
                                .opacity(drop.opacity)
                                .scaleEffect(drop.scale)
                                .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Control buttons
                    HStack(spacing: 40) {
                        Button {
                            viewModel.showingTreeSelector = true
                        } label: {
                            Image(systemName: "backpack.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        
                        Button {
                            if viewModel.waterDrops >= 2 {
                                startWateringAnimation()
                            }
                        } label: {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(viewModel.waterDrops >= 2 ? Color.blue : Color.gray)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                // Reward counter overlay
                if showingRewardCounter, let activity = selectedActivity {
                    RewardCounterView(
                        type: activity,
                        isPresented: $showingRewardCounter,
                        finalValue: activity.getWaterDrops()
                    )
                    .transition(.opacity)
                }
            }
            .navigationTitle("Virtual Tree")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if AccountManager.shared.isLoggedIn {
                            viewModel.showingShareOptions = true
                        } else {
                            viewModel.showingLoginAlert = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingTreeSelector) {
                TreeSelectorView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingShareOptions) {
                ShareOptionsView(showingPostView: $viewModel.showingPostView, viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.showingPostView) {
                PostAccomplishmentView()
            }
            .alert("Account Required", isPresented: $viewModel.showingLoginAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Create Account") {
                    showingManageAccount = true
                }
            } message: {
                Text("You need to create an account to use this feature.")
            }
            .sheet(isPresented: $showingManageAccount) {
                ManageAccountView(profileViewModel: ProfileViewModel())
            }
        }
        .onAppear {
            initializeActivityBubbles()
            // Set up observers for water drops changes
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("SearchWaterDropsChanged"),
                object: nil,
                queue: .main
            ) { _ in
                searchWaterDrops = UserDefaults.standard.integer(forKey: "searchWaterDrops")
            }
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("DonationWaterDropsChanged"),
                object: nil,
                queue: .main
            ) { _ in
                donationWaterDrops = UserDefaults.standard.integer(forKey: "donationWaterDrops")
            }
            
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("PostWaterDropsChanged"),
                object: nil,
                queue: .main
            ) { _ in
                postWaterDrops = UserDefaults.standard.integer(forKey: "postWaterDrops")
            }
        }
        .onReceive(timer) { _ in
            updateBubblePositions()
        }
    }
    
    private func startWateringAnimation() {
        let numberOfDrops = 50
        let duration = 2.0
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        
        for i in 0..<numberOfDrops {
            let delay = Double(i) * (duration / Double(numberOfDrops) * 0.5)
            
            let startX = CGFloat.random(in: -screenWidth/2 + 30...screenWidth/2 - 30)
            let startY = CGFloat.random(in: -200...(-50))
            
            let waterDrop = WaterDrop(position: CGPoint(x: startX, y: startY))
            viewModel.activeWaterDrops.append(waterDrop)
            
            withAnimation(
                .interpolatingSpring(
                    mass: 0.8,
                    stiffness: 120,
                    damping: 8,
                    initialVelocity: 2
                )
                .delay(delay)
            ) {
                let index = viewModel.activeWaterDrops.count - 1
                let endY = CGFloat.random(in: 200...300)
                let horizontalSwing = CGFloat.random(in: -40...40)
                
                viewModel.activeWaterDrops[index].position.y += endY
                viewModel.activeWaterDrops[index].position.x += horizontalSwing
                viewModel.activeWaterDrops[index].opacity = 0
            }
            
            if i % 3 == 0 {
                withAnimation(
                    .easeInOut(duration: duration * 0.3)
                    .delay(delay)
                ) {
                    let index = viewModel.activeWaterDrops.count - 1
                    viewModel.activeWaterDrops[index].scale = CGFloat.random(in: 1.2...1.8)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + delay) {
                if !viewModel.activeWaterDrops.isEmpty {
                    viewModel.activeWaterDrops.removeFirst()
                    viewModel.addWater()
                }
            }
        }
    }
}

// Update UserStats class
class UserStats: ObservableObject {
    @Published var posts: Int = 0
    @Published var tracking: Int = 0
    @Published var followers: Int = 0
    @Published var waterDrops: Int = 0
    @Published var treesPlanted: Int = 0
    @Published var achievements: Int = 0
    @Published var growthDays: Int = 0
    private let appStartDateKey = "appStartDate"
    
    static let shared = UserStats() // Singleton instance for global access
    
    init() {
        fetchUserStats()
    }
    
    func fetchUserStats() {
        self.posts = UserDefaults.standard.integer(forKey: "userPosts")
        self.tracking = UserDefaults.standard.integer(forKey: "userTracking")
        self.followers = UserDefaults.standard.integer(forKey: "userFollowers")
        self.waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
        self.treesPlanted = UserDefaults.standard.integer(forKey: "userTreesPlanted")
        self.achievements = UserDefaults.standard.integer(forKey: "userAchievements")
        
        // Calculate growth days
        if let startDate = UserDefaults.standard.object(forKey: appStartDateKey) as? Date {
            self.growthDays = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        } else {
            // First time app launch
            UserDefaults.standard.set(Date(), forKey: appStartDateKey)
            self.growthDays = 0
        }
        
        // Notify observers of current water drops
        NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
    }
    
    func addWaterDrops(_ amount: Int) {
        waterDrops += amount
        UserDefaults.standard.set(waterDrops, forKey: "userWaterDrops")
        NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
    }
    
    func useWaterDrops(_ amount: Int) -> Bool {
        if waterDrops >= amount {
            waterDrops -= amount
            UserDefaults.standard.set(waterDrops, forKey: "userWaterDrops")
            NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
            return true
        }
        return false
    }
}

// Add this extension for the notification name
extension Notification.Name {
    static let waterDropsDidChange = Notification.Name("waterDropsDidChange")
}

// Add this before ProfileView
class ProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage?
    @Published var showingPhotoPicker = false
    @Published var showingProfileOptions = false
    
    func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "userProfileImage")
            profileImage = image
        }
    }
    
    func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
}

struct ProfilePhotoOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    
    // These will be replaced with your actual images
    let profileOptions = [
        "metal", "wood", "sproute",
        "recycle", "procelain", "oceantrash"
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Profile Photo")
                    .font(.headline)
                    .padding(.top)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    // Default icon option
                    Button {
                        viewModel.profileImage = nil
                        UserDefaults.standard.removeObject(forKey: "userProfileImage")
                        dismiss()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                    
                    // Six profile photo options
                    ForEach(profileOptions, id: \.self) { imageName in
                        Button {
                            if let image = UIImage(named: imageName) {
                                viewModel.saveProfileImage(image)
                            }
                            dismiss()
                        } label: {
                            // Temporarily using a placeholder until you provide the actual images
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text("Photo\n\(profileOptions.firstIndex(of: imageName)! + 1)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                )
                        }
                    }
                }
                .padding()
                
                Text("Select one of the available profile photos")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ImageSlider: View {
    let images = ["slider1", "slider2", "slider3", "slider4"] // Replace with your actual image names
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    // Temporarily using a colored rectangle as placeholder
                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .overlay(
                            Text("Image \(index + 1)")
                                .foregroundColor(.white)
                        )
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 200)
            
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<images.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
        }
    }
}

struct ServiceTeamView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ImageSlider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Our Service Team")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We are a dedicated team of environmental enthusiasts working tirelessly to make our planet greener. Our mission is to inspire and enable individuals to contribute to environmental sustainability through simple, everyday actions.")
                        .font(.body)
                    
                    Text("What We Do")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("• Plant and maintain trees across urban and rural areas\n• Educate communities about environmental conservation\n• Organize local cleanup initiatives\n• Provide sustainable solutions for waste management\n• Partner with organizations to maximize environmental impact")
                        .font(.body)
                }
                .padding()
            }
        }
        .navigationTitle("Service Team")
    }
}

struct DonationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAmount: Double?
    @State private var customAmount: String = ""
    @State private var showingPaymentSheet = false
    @State private var showingLoginAlert = false
    @State private var showingManageAccount = false
    
    let predefinedAmounts = [1.0, 5.0, 20.0, 100.0, 200.0, 500.0]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ImageSlider()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Make a Difference")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your donation helps us plant more trees and create a sustainable future. Every dollar counts towards making our planet greener and healthier for future generations.")
                        .font(.body)
                    
                    Text("Benefits")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("• Each dollar donated plants a new tree\n• Get 5x water drops for every dollar\n• Track your environmental impact\n• Receive regular updates about your contribution")
                        .font(.body)
                }
                .padding()
                
                // Donation amounts
                VStack(spacing: 16) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(predefinedAmounts, id: \.self) { amount in
                            Button {
                                selectedAmount = amount
                                customAmount = ""
                                showingPaymentSheet = true
                            } label: {
                                Text("$\(Int(amount))")
                                    .font(.headline)
                                    .foregroundColor(selectedAmount == amount ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedAmount == amount ? Color.green : Color(UIColor.systemGray6))
                                    )
                            }
                        }
                        
                        // Custom amount button
                        Button {
                            selectedAmount = nil
                        } label: {
                            Text("Custom")
                                .font(.headline)
                                .foregroundColor(selectedAmount == nil ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedAmount == nil ? Color.green : Color(UIColor.systemGray6))
                                )
                        }
                    }
                    
                    if selectedAmount == nil {
                        TextField("Enter amount", text: $customAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button {
                            if let amount = Double(customAmount) {
                                showingPaymentSheet = true
                            }
                        } label: {
                            Text("Donate")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .disabled(Double(customAmount) == nil)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Make a Donation")
        .sheet(isPresented: $showingPaymentSheet) {
            if AccountManager.shared.isLoggedIn {
                handlePaymentCompletion()
            }
        } content: {
            if AccountManager.shared.isLoggedIn {
                PaymentHandlerView(amount: selectedAmount ?? Double(customAmount) ?? 0) { success in
                    if success {
                        handlePaymentCompletion()
                    }
                    showingPaymentSheet = false
                }
            }
        }
        .alert("Account Required", isPresented: $showingLoginAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Create Account") {
                showingManageAccount = true
            }
        } message: {
            Text("You need to create an account to make a donation.")
        }
        .sheet(isPresented: $showingManageAccount) {
            ManageAccountView(profileViewModel: ProfileViewModel())
        }
        .onChange(of: selectedAmount) { newValue in
            if !AccountManager.shared.isLoggedIn {
                showingLoginAlert = true
                selectedAmount = nil
            }
        }
        .onChange(of: customAmount) { newValue in
            if !AccountManager.shared.isLoggedIn && !newValue.isEmpty {
                showingLoginAlert = true
                customAmount = ""
            }
        }
    }
    
    private func handlePaymentCompletion() {
        let amount = selectedAmount ?? Double(customAmount) ?? 0
        let waterDropsReward = Int(amount * 5)
        let currentAmount = UserDefaults.standard.integer(forKey: "donationWaterDrops")
        UserDefaults.standard.set(currentAmount + waterDropsReward, forKey: "donationWaterDrops")
        UserStats.shared.addWaterDrops(waterDropsReward)
        NotificationCenter.default.post(name: NSNotification.Name("DonationWaterDropsChanged"), object: nil)
        dismiss()
    }
}

struct PaymentHandlerView: View {
    let amount: Double
    let onCompletion: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Processing Payment")
                .font(.headline)
            
            Text("$\(String(format: "%.2f", amount))")
                .font(.title)
            
            // Simulated payment processing
            Button("Complete Payment") {
                // In a real app, this would integrate with actual payment processing
                onCompletion(true)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button("Cancel") {
                onCompletion(false)
            }
            .foregroundColor(.red)
        }
        .padding()
    }
}

// Add this enum before ProfileView
enum UserStatus: Int, CaseIterable {
    case ecoAware = 0
    case greenStarter = 1
    case sustainableSeeker = 2
    case ecoWarrior = 3
    case earthGuardian = 4
    case ecoChampion = 5
    
    var title: String {
        switch self {
        case .ecoAware: return "EcoAware"
        case .greenStarter: return "GreenStarter"
        case .sustainableSeeker: return "SustainableSeeker"
        case .ecoWarrior: return "EcoWarrior"
        case .earthGuardian: return "EarthGuardian"
        case .ecoChampion: return "EcoChampion"
        }
    }
    
    var color: Color {
        switch self {
        case .ecoAware: return .blue
        case .greenStarter: return .green
        case .sustainableSeeker: return .teal
        case .ecoWarrior: return .orange
        case .earthGuardian: return .purple
        case .ecoChampion: return .red
        }
    }
    
    static func calculateStatus(treesPlanted: Int) -> UserStatus {
        let level = treesPlanted / 20
        return UserStatus(rawValue: min(level, 5)) ?? .ecoAware
    }
}

// Add these helper views before ManageAccountView
struct AccountPhotoSection: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Button {
                profileViewModel.showingProfileOptions = true
            } label: {
                if let profileImage = profileViewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }
            
            Text("Tap to change photo")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top)
    }
}

struct AccountDetailsSection: View {
    @Binding var accountName: String
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Account Name")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter your name", text: $accountName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
    }
}

struct PasswordSection: View {
    @Binding var currentPassword: String
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    @Binding var showingPasswordError: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Change Password")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // Current Password
                PasswordField(
                    title: "Current Password",
                    placeholder: "Enter current password",
                    text: $currentPassword,
                    icon: "lock.fill"
                )
                
                // New Password
                PasswordField(
                    title: "New Password",
                    placeholder: "Enter new password",
                    text: $newPassword,
                    icon: "key.fill"
                )
                
                // Confirm Password
                PasswordField(
                    title: "Confirm New Password",
                    placeholder: "Confirm new password",
                    text: $confirmPassword,
                    icon: "checkmark.shield.fill"
                )
                
                if showingPasswordError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
        }
    }
}

struct PasswordField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            SecureField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color(UIColor.systemGray6))
        }
    }
}

struct ActionButtonsSection: View {
    let onSave: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onSave) {
                Text("Save Changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button(action: onDelete) {
                Text("Delete Account")
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

// Update ManageAccountView
struct ManageAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var accountName = UserDefaults.standard.string(forKey: "accountName") ?? "Your Name"
    @State private var email = UserDefaults.standard.string(forKey: "userEmail") ?? "username@example.com"
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingDeleteConfirmation = false
    @State private var showingSaveConfirmation = false
    @State private var showingPasswordError = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    AccountPhotoSection(profileViewModel: profileViewModel)
                    
                    VStack(spacing: 20) {
                        AccountDetailsSection(accountName: $accountName, email: $email)
                        
                        PasswordSection(
                            currentPassword: $currentPassword,
                            newPassword: $newPassword,
                            confirmPassword: $confirmPassword,
                            showingPasswordError: $showingPasswordError
                        )
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    ActionButtonsSection(
                        onSave: {
                            if newPassword == confirmPassword {
                                saveAccount()
                            } else {
                                showingPasswordError = true
                            }
                        },
                        onDelete: {
                            showingDeleteConfirmation = true
                        }
                    )
                }
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Manage Account")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $profileViewModel.showingProfileOptions) {
                ProfilePhotoOptionsView(viewModel: profileViewModel)
            }
            .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
            .alert("Changes Saved", isPresented: $showingSaveConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your account information has been updated successfully.")
            }
        }
    }
    
    private func saveAccount() {
        AccountManager.shared.createAccount(name: accountName, email: email)
        showingSaveConfirmation = true
    }
    
    private func deleteAccount() {
        // Reset all user data to default values
        UserDefaults.standard.set("Your Name", forKey: "accountName")
        UserDefaults.standard.set("username@example.com", forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userProfileImage")
        UserDefaults.standard.set(0, forKey: "userPosts")
        UserDefaults.standard.set(0, forKey: "userTracking")
        UserDefaults.standard.set(0, forKey: "userFollowers")
        
        // Update water drops through UserStats to ensure proper notification
        UserStats.shared.waterDrops = 0
        UserDefaults.standard.set(0, forKey: "userWaterDrops")
        NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
        
        UserDefaults.standard.set(0, forKey: "userTreesPlanted")
        UserDefaults.standard.set(0, forKey: "userAchievements")
        
        // Reset profile image
        profileViewModel.profileImage = nil
        
        dismiss()
    }
}

// Update ProfileView to include Manage Account button
struct ProfileView: View {
    @StateObject private var userStats = UserStats()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var dateOfBirth = Date()
    @State private var selectedUnit = "Metric"
    @State private var selectedCountry = "United States"
    @State private var selectedLanguage = "English"
    @State private var showingManageAccount = false
    
    let units = ["Metric", "Imperial"]
    let countries = ["United States", "Canada", "United Kingdom", "Australia", "Germany", "France", "Japan", "China"]
    let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 20) {
                        Button {
                            profileViewModel.showingProfileOptions = true
                        } label: {
                            if let profileImage = profileViewModel.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(UserDefaults.standard.string(forKey: "accountName") ?? "Your Name")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(UserDefaults.standard.string(forKey: "userEmail") ?? "username@example.com")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // User Status Badge
                            let currentStatus = UserStatus.calculateStatus(treesPlanted: userStats.treesPlanted)
                            Text(currentStatus.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(currentStatus.color)
                                )
                                .padding(.top, 4)
                            
                            // Progress to next level
                            if currentStatus != .ecoChampion {
                                let treesForNextLevel = ((userStats.treesPlanted / 20) + 1) * 20
                                let progress = Double(userStats.treesPlanted % 20) / 20.0
                                
                                VStack(spacing: 4) {
                                    // Progress bar
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 4)
                                            
                                            Rectangle()
                                                .fill(currentStatus.color)
                                                .frame(width: geometry.size.width * progress, height: 4)
                                        }
                                        .cornerRadius(2)
                                    }
                                    .frame(height: 4)
                                    .padding(.top, 4)
                                    
                                    // Trees needed text
                                    Text("\(treesForNextLevel - userStats.treesPlanted) more trees to \(UserStatus(rawValue: currentStatus.rawValue + 1)?.title ?? "")")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 200)
                                .padding(.top, 4)
                            }
                        }
                        
                        // Stats Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            StatBlock(title: "Posts", value: "\(userStats.posts)")
                            StatBlock(title: "Tracking", value: "\(userStats.tracking)")
                            StatBlock(title: "Followers", value: "\(userStats.followers)")
                            StatBlock(title: "WaterDrops", value: "\(userStats.waterDrops)")
                            StatBlock(title: "Trees Planted", value: "\(userStats.treesPlanted)")
                            StatBlock(title: "Achievements", value: "\(userStats.achievements)")
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    
                    // Our Team (Previously Additional Services)
                    VStack(alignment: .leading, spacing: 24) {
                        Text("OUR TEAM")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            NavigationLink(destination: ServiceTeamView()) {
                                AdditionalServiceButton(
                                    title: "Service Team",
                                    icon: "person.2.fill"
                                )
                            }
                            
                            AdditionalServiceButton(
                                title: "Overall Use",
                                icon: "chart.bar.fill"
                            )
                            
                            NavigationLink(destination: DonationView()) {
                                AdditionalServiceButton(
                                    title: "Make a Donation",
                                    icon: "heart.fill"
                                )
                            }
                            
                            AdditionalServiceButton(
                                title: "Collaborations",
                                icon: "person.2.circle.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 24) {
                        Text("SETTINGS")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Manage Account Button
                            NavigationLink(destination: ManageAccountView(profileViewModel: profileViewModel)) {
                                SettingRow(title: "Manage Account") {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Date of Birth
                            SettingRow(title: "Date of Birth") {
                                DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                    .labelsHidden()
                                    .frame(maxWidth: 150)
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Units of Measure
                            SettingRow(title: "Units of Measure") {
                                Picker("", selection: $selectedUnit) {
                                    ForEach(units, id: \.self) { unit in
                                        Text(unit).tag(unit)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .onChange(of: selectedUnit) { newValue in
                                    UserDefaults.standard.set(newValue, forKey: "selectedUnit")
                                    NotificationCenter.default.post(
                                        name: NSNotification.Name("MeasurementUnitChanged"),
                                        object: newValue
                                    )
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Payment Information
                            SettingRow(title: "Payment Information") {
                                NavigationLink {
                                    Text("Payment Methods")
                                } label: {
                                    HStack {
                                        Text("Manage")
                                            .foregroundColor(.green)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Country/Region
                            SettingRow(title: "Country/Region") {
                                Picker("", selection: $selectedCountry) {
                                    ForEach(countries, id: \.self) { country in
                                        Text(country).tag(country)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Language
                            SettingRow(title: "Language") {
                                Picker("", selection: $selectedLanguage) {
                                    ForEach(languages, id: \.self) { language in
                                        Text(language).tag(language)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Others (Previously Additional Options)
                    VStack(alignment: .leading, spacing: 24) {
                        Text("OTHERS")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: Text("Favorites")) {
                                SettingRow(title: "Favorites") {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            NavigationLink(destination: Text("Help & Support")) {
                                SettingRow(title: "Help & Support") {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            NavigationLink(destination: Text("Legal")) {
                                SettingRow(title: "Legal") {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Profile")
            .onAppear {
                userStats.fetchUserStats()
                profileViewModel.loadProfileImage()
            }
            .sheet(isPresented: $profileViewModel.showingProfileOptions) {
                ProfilePhotoOptionsView(viewModel: profileViewModel)
            }
        }
    }
}

struct AdditionalServiceButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.green)
            Text(title)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct SettingRow<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            content()
        }
        .padding(.horizontal)
        .frame(height: 54)
        .contentShape(Rectangle())
    }
}

struct StatBlock: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold))
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            TreesView()
                .tabItem {
                    Label("Trees", systemImage: "leaf.fill")
                }
                .toolbarBackground(.white.opacity(0.9), for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}

// Add CameraView
struct CameraView: View {
    @Binding var image: UIImage?
    @Binding var isShowing: Bool
    let onCapture: (UIImage?) -> Void
    
    var body: some View {
        ZStack {
            CameraPreview(image: $image, isShowing: $isShowing) { capturedImage in
                image = capturedImage
                onCapture(capturedImage)
                isShowing = false
            }
            
            VStack {
                Spacer()
                
                Button {
                    isShowing = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

// Add CameraPreview
struct CameraPreview: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShowing: Bool
    let onCapture: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPreview
        
        init(_ parent: CameraPreview) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onCapture(image)
            }
            parent.isShowing = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShowing = false
        }
    }
}

// Add this struct for the reward notification
struct WaterDropRewardView: View {
    let amount: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                Text("+\(amount)")
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("Water Drops!")
                    .font(.headline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}
