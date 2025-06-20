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
import Foundation
import PassKit
import CoreLocation
import Combine
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
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
        // Only award waterdrops to authenticated users
        guard AccountManager.shared.isLoggedIn else { return }
        
        _ = isCamera ? 20 : 10
        UserStats.shared.addSearchWaterDrops()
        showingReward = true
    }
    
    private func handleSearchAction() {
        if AccountManager.shared.isLoggedIn {
            isSearching = true
            awardSearchWaterDrops(isCamera: false)
        } else if AccountManager.shared.isGuestMode {
            // Show guest limitation message
        } else {
            // Not logged in at all, shouldn't reach here
        }
    }
    
    private func handleCameraAction() {
        if AccountManager.shared.isLoggedIn {
            onCamera()
            awardSearchWaterDrops(isCamera: true)
        } else if AccountManager.shared.isGuestMode {
            // Show guest limitation message
        } else {
            // Not logged in at all, shouldn't reach here
        }
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
                            handleSearchAction()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text(AccountManager.shared.isGuestMode ? "Sign in to search..." : "Ask about sustainability...")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(12)
                        }

                        Button {
                            handleCameraAction()
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
            
            if showingReward && AccountManager.shared.isLoggedIn {
                WaterDropRewardView(amount: isSearching ? 10 : 20, isPresented: $showingReward)
            }
        }
    }
}

struct PopularSearchGrid: View {
    @Query(sort: \SearchHistory.timestamp, order: .reverse) private var searchHistory: [SearchHistory]
    @State private var showingAllSearches = false
    @State private var showingLoginAlert = false
    @State private var showingCreateAccount = false
    
    private var filteredHistory: [SearchHistory] {
        if AccountManager.shared.isLoggedIn {
            return Array(searchHistory.prefix(6))
        }
        return []
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Recent Searches")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !filteredHistory.isEmpty {
                    Button {
                        showingAllSearches = true
                    } label: {
                        Text("See More")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            if !AccountManager.shared.isLoggedIn {
                // Not logged in view
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Sign in to Track Searches")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Create an account to save your search history and earn rewards")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        showingCreateAccount = true
                    } label: {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 160)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(UIColor.systemGray6).opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            } else if filteredHistory.isEmpty {
                // Empty state for logged in users
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No Searches Yet")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Your recent sustainability searches will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(UIColor.systemGray6).opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            } else {
                // Search history grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(filteredHistory) { history in
                        SearchImageCard(history: history)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 24)
                .animation(.spring(), value: filteredHistory)
            }
        }
        .sheet(isPresented: $showingAllSearches) {
            AllSearchesView(searches: Array(searchHistory))
        }
        .sheet(isPresented: $showingCreateAccount) {
            CreateAccountView()
        }
        .alert("Create Account", isPresented: $showingLoginAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Create Account") {
                showingCreateAccount = true
            }
        } message: {
            Text("Create an account to earn waterdrops for your sustainable actions!")
        }
    }
}

struct SearchImageCard: View {
    let history: SearchHistory
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button {
            // Handle search selection
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    if let imageData = history.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                    } else {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6))
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green.opacity(0.5))
                            )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(history.query)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    if let summary = history.resultSummary {
                        Text(summary)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(history.timestamp, style: .relative)
                            .font(.caption2)
                    }
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
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
    @StateObject private var locationManager = LocationManager.shared
    
    // New state for fetched user locations
    @State private var userLocations: [MapLocation] = []
    @State private var isLoadingUsers = false
    @State private var userLocationsError: String? = nil
    
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
                ZStack {
                    Map(coordinateRegion: $region,
                        showsUserLocation: true,
                        userTrackingMode: .none,
                        annotationItems: selectedTab == .users ? userLocations : mockPlanters
                    ) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            LocationDot(type: selectedTab)
                        }
                    }
                    .frame(height: 400)
                    .colorScheme(.dark)
                    
                    if selectedTab == .users {
                        if isLoadingUsers {
                            ProgressView("Loading user locations...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                        } else if let error = userLocationsError {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title)
                                Text(error)
                                    .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.1))
                        }
                    }
                }
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            fetchUserLocations()
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .users && userLocations.isEmpty && !isLoadingUsers {
                fetchUserLocations()
            }
        }
    }
    
    private func fetchUserLocations() {
        isLoadingUsers = true
        userLocationsError = nil
        
        Task {
            do {
                let locations = try await NetworkService.shared.fetchMapLocations()
                await MainActor.run {
                    userLocations = locations.map { loc in
                        MapLocation(coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
                    }
                    isLoadingUsers = false
                }
            } catch {
                await MainActor.run {
                    userLocationsError = error.localizedDescription
                    isLoadingUsers = false
                }
            }
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
  static let shared = LocationManager()

  public let manager = CLLocationManager()
  public let geocoder = CLGeocoder()

  @Published var location: CLLocation?
  @Published var countryCode: String?

  override private init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
  }

  /// Call once (e.g. onAppear of your root view)
  func requestAuthorizationAndLocation() {
    manager.requestWhenInUseAuthorization()
    manager.startUpdatingLocation()
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locs: [CLLocation]
  ) {
    guard let loc = locs.last else { return }
    self.location = loc

    // Reverse‑geocode country
    geocoder.reverseGeocodeLocation(loc) { places, error in
      if let code = places?.first?.isoCountryCode {
        DispatchQueue.main.async {
          self.countryCode = code
        }
      }
    }

    manager.stopUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error:", error.localizedDescription)
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
    @State private var showingPlantedTrees = false
    @State private var showingCreateAccount = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    SearchBar(text: $searchText,
                            isSearching: $isSearching,
                            onCamera: {
                                showingCamera = true
                            })
                    
                    CommunityPostsGrid()
                    
                    // Stats section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Impact")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 24)
                        
                        if AccountManager.shared.isGuestMode {
                            // Guest mode stats view
                            VStack(spacing: 16) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Preview Mode")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Create an account to track your environmental impact and earn rewards")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                
                                Button {
                                    showingCreateAccount = true
                                } label: {
                                    Text("Create Account")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 160)
                                        .padding(.vertical, 12)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(Color(UIColor.systemGray6).opacity(0.5))
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                        } else if !AccountManager.shared.isLoggedIn {
                            // Authentication prompt for home stats
                            VStack(spacing: 16) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Track Your Impact")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Create an account to see your environmental impact and achievements")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                
                                Button {
                                    showingCreateAccount = true
                                } label: {
                                    Text("Create Account")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 160)
                                        .padding(.vertical, 12)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(Color(UIColor.systemGray6).opacity(0.5))
                            .cornerRadius(16)
                            .padding(.horizontal, 24)
                        } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "PLANTED",
                                    value: userStats.isLoading ? "..." : String(userStats.treesPlanted),
                                unit: "trees"
                            ) {
                                // Show planted trees view
                                showingPlantedTrees = true
                            }
                                StatCard(title: "GROWTH", value: userStats.isLoading ? "..." : String(userStats.growthDays), unit: "days")
                                StatCard(title: "ACHIEVEMENTS", value: userStats.isLoading ? "..." : String(userStats.achievements), unit: "earned")
                        }
                        .padding(.horizontal, 24)
                        }
                    }
                    .sheet(isPresented: $showingPlantedTrees) {
                        PlantedTreesView()
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
            .sheet(isPresented: $showingCreateAccount) {
                CreateAccountView()
            }
            .sheet(isPresented: $userStats.showingLoginPrompt) {
                CreateAccountView()
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
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
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
        .buttonStyle(PlainButtonStyle())
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

// Update TreeType struct to include waterdrops cost
struct TreeType: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let features: [String]
    let icon: String
    let waterdropsCost: Int
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
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.layer.render(in: ctx.cgContext)
            }
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
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No additional updates needed
    }
}

struct PostAccomplishmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingReward = false
    @State private var showingLoginAlert = false
    @State private var showingCreateAccount = false
    @State private var selectedCategory: MaterialCategory? = nil

    let materialCategories = [
        MaterialCategory(name: "Metals", systemImage: "bolt.fill", color: .orange),
        MaterialCategory(name: "Plastic", systemImage: "arrow.triangle.2.circlepath", color: .blue),
        MaterialCategory(name: "Glass", systemImage: "drop.fill", color: .cyan),
        MaterialCategory(name: "Wood", systemImage: "leaf.fill", color: .brown),
        MaterialCategory(name: "Porcelain", systemImage: "circle.grid.3x3.fill", color: .gray),
        MaterialCategory(name: "Others", systemImage: "ellipsis.circle.fill", color: .purple)
    ]
    
    private func handlePost() {
        if AccountManager.shared.isLoggedIn {
            Task {
                do {
                    let author = UserDefaults.standard.string(forKey: "accountName") ?? "Your Name"
                    let authorId = AccountManager.shared.userId ?? "unknown"
                    let tags = [selectedCategory?.name ?? "Others"]
                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                    let now = Date()
                    try await NetworkService.shared.createPost(
                        title: postText,
                        content: postText,
                        imageData: imageData,
                        author: author,
                        authorId: authorId,
                        tags: tags,
                        timestamp: now
                    )
                    UserStats.shared.addPostWaterDrops()
                    showingReward = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                } catch {
                    // Handle error properly
                    print("Failed to create post: \(error.localizedDescription)")
                    // Could show an alert to user here
                }
            }
        } else {
            showingLoginAlert = true
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Material Category Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select a Category")
                                .font(.headline)
                            HStack(spacing: 12) {
                                ForEach(materialCategories) { category in
                                    Button(action: { selectedCategory = category }) {
                                        VStack(spacing: 4) {
                                            Image(systemName: category.systemImage)
                                                .font(.system(size: 22))
                                                .foregroundColor(category.color)
                                                .padding(10)
                                                .background(selectedCategory?.id == category.id ? category.color.opacity(0.2) : Color(UIColor.systemGray6))
                                                .clipShape(Circle())
                                            Text(category.name)
                                                .font(.caption2)
                                                .foregroundColor(.primary)
                                        }
                                        .padding(4)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedCategory?.id == category.id ? category.color : Color.clear, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        
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
                
                if showingReward && AccountManager.shared.isLoggedIn {
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
                    .disabled(selectedCategory == nil)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingCreateAccount) {
                CreateAccountView()
            }
            .alert("Create Account", isPresented: $showingLoginAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Create Account") {
                    showingCreateAccount = true
                }
            } message: {
                Text("Create an account to earn waterdrops for your sustainable actions!")
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
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No additional updates needed for UIImagePickerController
    }
    
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

// Update AccountManager to use AuthenticationService
@MainActor
class AccountManager: ObservableObject {
    static let shared = AccountManager()
    @Published var isLoggedIn: Bool = false
    @Published var isGuestMode: Bool = false
    @Published var userId: String? = nil
    @Published var userEmail: String? = nil
    @Published var displayName: String? = nil
    
    private let authService = AuthenticationService.shared
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {
        // Observe authentication state changes
        authService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                self?.isLoggedIn = isAuthenticated
                NotificationCenter.default.post(name: NSNotification.Name("AuthenticationChanged"), object: nil)
            }
            .store(in: &cancellables)
            
        // Observe user changes
        authService.$currentUser
            .map { $0?.uid }
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
            
        authService.$currentUser
            .map { $0?.email }
            .assign(to: \.userEmail, on: self)
            .store(in: &cancellables)
            
        authService.$currentUser
            .map { $0?.displayName ?? "User" }
            .assign(to: \.displayName, on: self)
            .store(in: &cancellables)
    }
    
    func signOut() {
        do {
            try authService.signOut()
            // Clear local user data when signing out
            clearLocalUserData()
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    func continueAsGuest() {
        isGuestMode = true
        isLoggedIn = false
        // Clear any existing auth data
        clearLocalUserData()
    }
    
    func exitGuestMode() {
        isGuestMode = false
    }
    
    var hasAnyAccess: Bool {
        isLoggedIn || isGuestMode
    }
    
    private func clearLocalUserData() {
        // Reset all user data but keep app settings
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
        
        // Reset guest mode
        isGuestMode = false
        
        // Notify observers
        NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
        NotificationCenter.default.post(name: .accountDeleted, object: nil)
    }
}

// Add this to Notification.Name extension
extension Notification.Name {
    static let accountDeleted = Notification.Name("accountDeleted")
    static let showManageAccount = Notification.Name("showManageAccount")
    static let showCreateAccount = Notification.Name("showCreateAccount")
}


// Update TreeViewModel class
@MainActor
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
    @Published var showingCreateAccount = false
    private var heightObserver: NSObjectProtocol?
    private var cancellable: NSObjectProtocol?
    
    @Published var waterDropsSpentOnCurrentTree: Int = 0
    @Published var virtualHeight: Double = 0.0
    @Published var showingCompletionCelebration = false
    @Published var showingNewTreePrompt = false
    @Published var showingTreeTypeSelection = false
    @Published var treeSelectionDeadline: Date?
    @Published var timeRemaining: TimeInterval = 0
    private var selectionTimer: Timer?
    
    let waterdropsToComplete = 10000
    let waterdropsPerGrowthIncrement = 100
    let heightIncrementPerGrowth = 0.2 // meters
    
    // Add treeTypes array with beautiful descriptions
    let treeTypes = [
        TreeType(
            name: "Oak",
            description: "A mighty oak tree symbolizing strength and endurance. Known for its robust trunk and acorn production.",
            features: ["Centuries-long lifespan", "Strong wood structure", "Wildlife habitat"],
            icon: "leaf.circle.fill",
            waterdropsCost: 1000
        ),
        TreeType(
            name: "Pine",
            description: "An elegant evergreen conifer with needle-like leaves. Provides year-round greenery and fresh air.",
            features: ["Evergreen foliage", "Rapid growth", "Mountain climate"],
            icon: "leaf.arrow.triangle.circlepath",
            waterdropsCost: 800
        ),
        TreeType(
            name: "Maple",
            description: "Known for its stunning autumn colors and distinctive lobed leaves. A symbol of natural beauty.",
            features: ["Brilliant fall colors", "Excellent shade", "Syrup production"],
            icon: "leaf.fill",
            waterdropsCost: 1200
        ),
        TreeType(
            name: "Cherry",
            description: "Beautiful flowering tree with delicate spring blossoms. Creates stunning pink and white displays.",
            features: ["Spring blossoms", "Ornamental beauty", "Compact size"],
            icon: "flower.2",
            waterdropsCost: 1500
        ),
        TreeType(
            name: "Willow",
            description: "Graceful tree with elegant drooping branches that sway in the breeze. Perfect near water.",
            features: ["Graceful branches", "Water-loving", "Natural flexibility"],
            icon: "wind",
            waterdropsCost: 900
        ),
        TreeType(
            name: "Birch",
            description: "Elegant tree with distinctive white bark and delicate leaves. A symbol of new beginnings.",
            features: ["White bark beauty", "Slender form", "Pioneer species"],
            icon: "leaf.circle",
            waterdropsCost: 1100
        ),
        TreeType(
            name: "Redwood",
            description: "Majestic giant reaching incredible heights. These ancient trees inspire awe and reverence.",
            features: ["Towering height", "Ancient wisdom", "Forest cathedral"],
            icon: "arrow.up.to.line",
            waterdropsCost: 2000
        ),
        TreeType(
            name: "Palm",
            description: "Tropical paradise tree with flowing fronds. Brings tropical vibes and coastal charm.",
            features: ["Tropical paradise", "Swaying fronds", "Coastal beauty"],
            icon: "sun.max.fill",
            waterdropsCost: 1800
        )
    ]
    
    init() {
        // Only load data if user is authenticated
        if AccountManager.shared.isLoggedIn {
        // Load saved height
        currentHeight = UserDefaults.standard.double(forKey: "treeHeight")
        
        // Load saved stage
        if let savedStageRawValue = UserDefaults.standard.object(forKey: "currentTreeStage") as? Int,
           let savedStage = TreeStage(rawValue: savedStageRawValue) {
            currentStage = savedStage
        }
        
        // Initialize water drops from UserDefaults to ensure consistency
        waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
        } else {
            // Reset to defaults for unauthenticated users
            currentHeight = 0.1
            currentStage = .seed
            waterDrops = 0
        }
        
        // Observe water drops changes
        cancellable = NotificationCenter.default.addObserver(
            forName: .waterDropsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
            self?.waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
            }
        }
        
        // Observe account deletion and authentication changes
        heightObserver = NotificationCenter.default.addObserver(
            forName: .accountDeleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
            self?.currentHeight = 0.1
            self?.currentStage = .seed
            self?.waterDropsSpentOnCurrentTree = 0
                self?.waterDrops = 0
            UserDefaults.standard.set(TreeStage.seed.rawValue, forKey: "currentTreeStage")
            UserDefaults.standard.set(0.1, forKey: "treeHeight")
            }
        }
        
        // Observe authentication state changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AuthenticationChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                if AccountManager.shared.isLoggedIn {
                    // Reload data when user logs in
                    self?.currentHeight = UserDefaults.standard.double(forKey: "treeHeight")
                    if let savedStageRawValue = UserDefaults.standard.object(forKey: "currentTreeStage") as? Int,
                       let savedStage = TreeStage(rawValue: savedStageRawValue) {
                        self?.currentStage = savedStage
                    }
                    self?.waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
                } else {
                    // Reset when user logs out
                    self?.currentHeight = 0.1
                    self?.currentStage = .seed
                    self?.waterDrops = 0
                    self?.waterDropsSpentOnCurrentTree = 0
                }
            }
        }
        
        // Observe measurement unit changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MeasurementUnitChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
            if let unit = notification.object as? String {
                self?.measurementUnit = unit
                }
            }
        }
        
        // Observe create account request
        NotificationCenter.default.addObserver(
            forName: .showCreateAccount,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
            self?.showingCreateAccount = true
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
            _ = UserStats.shared.useWaterDrops(2)
            currentHeight += 0.2
            UserDefaults.standard.set(currentHeight, forKey: "treeHeight")
            
            // Update local water drops immediately
            waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
            
            // Increment water drops spent on current tree
            waterDropsSpentOnCurrentTree += 2
            
            // Check if tree is complete (mature stage with over 1000 water drops)
            if currentStage == .mature && waterDropsSpentOnCurrentTree >= 1000 {
                completeTreePlanting()
            }
            // Normal stage progression
            else if currentStage != .mature {
                let waterDropsForNextStage = 200 * (currentStage.rawValue + 1)
                if waterDropsSpentOnCurrentTree >= waterDropsForNextStage {
                    withAnimation(.spring()) {
                        currentStage = TreeStage(rawValue: currentStage.rawValue + 1) ?? .mature
                        UserDefaults.standard.set(currentStage.rawValue, forKey: "currentTreeStage")
                    }
                }
            }
        }
    }
    
    private func completeTreePlanting() {
        // Show celebration first
        withAnimation(.spring()) {
            showingCompletionCelebration = true
        }
        
        // Increment trees planted count immediately
        let currentTrees = UserDefaults.standard.integer(forKey: "userTreesPlanted")
        UserDefaults.standard.set(currentTrees + 1, forKey: "userTreesPlanted")
        
        // Start 10-minute timer for tree type selection
        treeSelectionDeadline = Date().addingTimeInterval(600) // 10 minutes
        timeRemaining = 600
        startSelectionTimer()
        
        // After celebration, show tree type selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showingCompletionCelebration = false
                self.showingTreeTypeSelection = true
            }
        }
    }
    
    private func startSelectionTimer() {
        selectionTimer?.invalidate()
        selectionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let deadline = self.treeSelectionDeadline else { return }
            
            let remaining = deadline.timeIntervalSinceNow
            if remaining <= 0 {
                // Time's up - auto-select default tree type
                Task { @MainActor in
                    await self.selectDefaultTree()
                }
            } else {
                Task { @MainActor in
                    self.timeRemaining = remaining
                }
            }
        }
    }
    
    func selectTreeType(_ treeType: TreeType) {
        selectedTree = treeType
        finishTreePlanting()
    }
    
    @MainActor private func selectDefaultTree() {
        // Select the cheapest tree type as default
        if let defaultTree = treeTypes.min(by: { $0.waterdropsCost < $1.waterdropsCost }) {
            selectedTree = defaultTree
        }
        finishTreePlanting()
    }
    
    private func finishTreePlanting() {
        selectionTimer?.invalidate()
        selectionTimer = nil
        treeSelectionDeadline = nil
        
        // Reset tree to seed stage for next planting
                withAnimation(.spring()) {
                    currentStage = .seed
                    currentHeight = 0.1
                    waterDropsSpentOnCurrentTree = 0
            showingTreeTypeSelection = false
                    UserDefaults.standard.set(TreeStage.seed.rawValue, forKey: "currentTreeStage")
                    UserDefaults.standard.set(0.1, forKey: "treeHeight")
                }
                
        // Sync with backend
        Task {
            await syncTreePlantingWithBackend()
        }
    }
    
    private func syncTreePlantingWithBackend() async {
        guard let treeType = selectedTree,
              let userId = AccountManager.shared.userId else { return }
        
        do {
            try await NetworkService.shared.recordTreePlanting(
                userId: userId,
                treeType: treeType.name,
                location: getCurrentLocation()
            )
        } catch {
            print("Failed to sync tree planting with backend: \(error.localizedDescription)")
        }
    }
    
    private func getCurrentLocation() -> (latitude: Double, longitude: Double)? {
        // Get current location from LocationManager
        guard let location = LocationManager.shared.location else { return nil }
        return (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func formatTimeRemaining() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
    
    var isGrowingTree: Bool {
        currentStage != .mature || waterDropsSpentOnCurrentTree > 0
    }
    
    func addWaterDrop() {
        waterDropsSpentOnCurrentTree += 1
        
        // Update virtual height every 100 waterdrops
        if waterDropsSpentOnCurrentTree % waterdropsPerGrowthIncrement == 0 {
            virtualHeight += heightIncrementPerGrowth
        }
        
        // Check if tree is complete
        if waterDropsSpentOnCurrentTree >= waterdropsToComplete {
            completeTree()
        }
    }
    
    func completeTree() {
        showingCompletionCelebration = true
        
        // After celebration, reset tree and show prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        withAnimation {
                self.resetTree()
                self.showingNewTreePrompt = true
            }
        }
    }
    
    func resetTree() {
        waterDropsSpentOnCurrentTree = 0
        virtualHeight = 0.0
        currentStage = .seed
        showingCompletionCelebration = false
    }
    
    var growthProgress: Double {
        Double(waterDropsSpentOnCurrentTree) / Double(waterdropsToComplete)
    }
}

struct TreeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TreeViewModel
    @State private var selectedTree: TreeType?
    @State private var showingPaymentView = false
    @State private var showingGrowingAlert = false
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.treeTypes) { tree in
                        Button {
                            if viewModel.isGrowingTree {
                                showingGrowingAlert = true
                            } else {
                                selectedTree = tree
                                showingPaymentView = true
                            }
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
            .sheet(isPresented: $showingPaymentView) {
                if let tree = selectedTree {
                    TreeWaterdropsView(tree: tree, viewModel: viewModel, isPresented: $showingPaymentView)
                }
            }
            .alert("Tree in Progress", isPresented: $showingGrowingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You cannot select a new tree while growing one. Please complete or reset your current tree first.")
            }
        }
    }
}

struct TreeOptionCard: View {
    let tree: TreeType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Beautiful tree preview section
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.92, green: 0.97, blue: 0.88),
                            Color(red: 0.85, green: 0.93, blue: 0.82)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 120)
                
                getTreeShapePreview(for: tree.name)
                    .scaleEffect(0.8)
                    .frame(height: 120)
            }
            
            // Tree information
            VStack(alignment: .leading, spacing: 8) {
                // Header with name
                Text(tree.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            
            // Description
            Text(tree.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
                    .multilineTextAlignment(.leading)
            
                // Key features
            VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(tree.features.prefix(3)), id: \.self) { feature in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            // Cost display at bottom
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    Text("\(tree.waterdropsCost)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                    Text("drops")
                        .font(.system(size: 14))
                        .foregroundColor(.blue.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    // Helper function to get the tree shape for preview
    private func getTreeShapePreview(for treeName: String) -> some View {
        let treeType: TreeShape.TreeType
        let size = CGSize(width: 80, height: 80)
        
        switch treeName.lowercased() {
        case "oak":
            treeType = .oak
        case "pine":
            treeType = .pine
        case "maple":
            treeType = .maple
        case "cherry":
            treeType = .cherry
        case "willow":
            treeType = .willow
        case "birch":
            treeType = .birch
        case "redwood":
            treeType = .redwood
        case "palm":
            treeType = .palm
        default:
            treeType = .defaultTree
        }
        
        return TreeShape.create(treeType, size: size)
    }
}

struct TreeView: View {
    @ObservedObject var viewModel: TreeViewModel
    @State private var animationOffset: Double = 0
    
    var body: some View {
        VStack {
            // Enhanced Tree Visualization with growth stages
            GeometryReader { geometry in
                let treeSize = CGSize(
                    width: min(geometry.size.width, geometry.size.height) * 0.9,
                    height: min(geometry.size.width, geometry.size.height) * 0.9
                )
                
                ZStack {
                    // Ambient lighting effect
                    Circle()
                        .fill(RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: treeSize.width * 0.8
                        ))
                        .frame(width: treeSize.width * 1.5, height: treeSize.height * 1.5)
                        .opacity(viewModel.currentStage == .mature ? 0.6 : 0.3)
                        .animation(.easeInOut(duration: 2), value: viewModel.currentStage)
                    
                    // Enhanced tree visualization with smooth transitions
                    Group {
                    switch viewModel.currentStage {
                    case .seed:
                            // Enhanced seed visualization
                            EnhancedSeedVisualization(size: treeSize, animationOffset: animationOffset)
                                
                        case .sapling, .sprout, .mature:
                            // Progressive tree growth with enhanced shapes
                            if let selectedTree = viewModel.selectedTree {
                                getEnhancedTreeShape(for: selectedTree.name, size: treeSize, stage: viewModel.currentStage)
                            } else {
                                TreeShape.create(.defaultTree, size: treeSize, stage: viewModel.currentStage, animationOffset: animationOffset)
                            }
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: viewModel.currentStage)
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: viewModel.selectedTree?.id)
                    
                    // Particle effects for mature trees
                    if viewModel.currentStage == .mature {
                        ForEach(0..<6, id: \.self) { particle in
                            Circle()
                                .fill(Color.green.opacity(0.3))
                                .frame(width: 4, height: 4)
                                .offset(
                                    x: cos(animationOffset + Double(particle)) * Double(treeSize.width * 0.4),
                                    y: sin(animationOffset * 0.7 + Double(particle) * 1.2) * Double(treeSize.height * 0.3)
                                )
                                .animation(
                                    .easeInOut(duration: 4 + Double(particle) * 0.5)
                                    .repeatForever(autoreverses: true),
                                    value: animationOffset
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 300)
            .onAppear {
                // Start continuous animation
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    animationOffset = .pi * 2
                }
            }
            
            // Enhanced Tree Info Display
            if let selectedTree = viewModel.selectedTree {
                VStack(spacing: 8) {
                    // Tree name with icon
                    HStack(spacing: 8) {
                        Image(systemName: getTreeIcon(for: selectedTree.name))
                            .foregroundColor(.green)
                    Text(selectedTree.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.green)
                    }
                    
                    // Growth stage with progress indicator
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                    Text("Stage: \(viewModel.currentStage.name)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                            
                            // Mini progress bar for current stage
                            if viewModel.currentStage != .mature {
                                GeometryReader { geometry in
                                    let stageProgress = (viewModel.currentHeight - viewModel.currentStage.height) / 
                                                      (getNextStageHeight() - viewModel.currentStage.height)
                                    
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 4)
                                        
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.green)
                                            .frame(width: geometry.size.width * max(0, min(1, stageProgress)), height: 4)
                                    }
                                }
                                .frame(width: 100, height: 4)
                            }
                        }
                        
                        Spacer()
                        
                        // Height display
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(viewModel.formattedHeight())
                                .font(.system(.callout, design: .rounded))
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                            
                            Text("Height")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.1))
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            }
            
            // Enhanced Progress Bar
            if viewModel.currentStage != .mature {
                VStack(spacing: 8) {
                    HStack {
                        Text("Growth Progress")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(Int(viewModel.growthProgress * 100))%")
                            .font(.caption)
                    .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                    
            ProgressView(value: viewModel.growthProgress)
                        .progressViewStyle(EnhancedGreenProgressViewStyle())
                        .frame(width: 240)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
        }
        .overlay {
            if viewModel.showingCompletionCelebration {
                CelebrationView(onComplete: {
                    viewModel.showingCompletionCelebration = false
                })
            }
        }
        .alert("Tree Completed!", isPresented: $viewModel.showingNewTreePrompt) {
            Button("Select New Tree") {
                // This will be handled by the parent view to show tree selector
            }
        } message: {
            Text("Congratulations! Your tree has reached maturity. Time to start growing a new one!")
        }
    }
    
    // Helper function to get enhanced tree shape with stage
    private func getEnhancedTreeShape(for treeName: String, size: CGSize, stage: TreeStage) -> some View {
        let treeType: TreeShape.TreeType
        
        switch treeName.lowercased() {
        case "oak":
            treeType = .oak
        case "pine":
            treeType = .pine
        case "maple":
            treeType = .maple
        case "cherry":
            treeType = .cherry
        case "willow":
            treeType = .willow
        case "birch":
            treeType = .birch
        case "redwood":
            treeType = .redwood
        case "palm":
            treeType = .palm
        default:
            treeType = .defaultTree
        }
        
        return TreeShape.create(treeType, size: size, stage: stage, animationOffset: animationOffset)
    }
    
    // Helper function to get tree icon
    private func getTreeIcon(for treeName: String) -> String {
        switch treeName.lowercased() {
        case "oak": return "leaf.circle.fill"
        case "pine": return "triangle.fill"
        case "maple": return "leaf.fill"
        case "cherry": return "flower.fill"
        case "willow": return "wind"
        case "birch": return "leaf.circle"
        case "redwood": return "arrow.up.to.line"
        case "palm": return "sun.max.fill"
        default: return "leaf.fill"
        }
    }
    
    // Helper function to get next stage height
    private func getNextStageHeight() -> Double {
        switch viewModel.currentStage {
        case .seed: return TreeStage.sapling.height
        case .sapling: return TreeStage.sprout.height
        case .sprout: return TreeStage.mature.height
        case .mature: return TreeStage.mature.height
        }
    }
}

// Enhanced seed visualization with beautiful animations
struct EnhancedSeedVisualization: View {
    let size: CGSize
    let animationOffset: Double
    @State private var isGerminating = false
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Magical glow effect
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color.green.opacity(glowOpacity),
                        Color.blue.opacity(glowOpacity * 0.5),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * 0.4
                ))
                .frame(width: size.width * 0.8, height: size.width * 0.8)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowOpacity)
            
            // Enhanced seed body with realistic detail
            ZStack {
                // Main seed body
                Ellipse()
                    .fill(RadialGradient(
                        colors: [
                            Color(red: 0.65, green: 0.45, blue: 0.25),
                            Color(red: 0.45, green: 0.3, blue: 0.15),
                            Color(red: 0.35, green: 0.2, blue: 0.1)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size.width * 0.08
                    ))
                    .frame(width: size.width * 0.12, height: size.width * 0.15)
                    .overlay(
                        Ellipse()
                            .stroke(Color(red: 0.3, green: 0.15, blue: 0.05), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 2)
                
                // Highlight on seed
                Ellipse()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: size.width * 0.04, height: size.width * 0.06)
                    .offset(x: -size.width * 0.02, y: -size.width * 0.025)
                
                // Seed texture lines
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.25, green: 0.1, blue: 0.05).opacity(0.6))
                        .frame(width: size.width * 0.08, height: 1)
                        .offset(y: CGFloat(index - 1) * 3)
                }
            }
            
            // Germination effects
            if isGerminating {
                // Tiny root
                RoundedRectangle(cornerRadius: 1)
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.95, blue: 0.8),
                            Color(red: 0.8, green: 0.85, blue: 0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 2, height: size.width * 0.08)
                    .offset(y: size.width * 0.12)
                    .transition(.scale.combined(with: .opacity))
                
                // Tiny green shoot
                ZStack {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.8, blue: 0.3),
                                Color(red: 0.3, green: 0.6, blue: 0.2)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .frame(width: 3, height: size.width * 0.06)
                    
                    // Tiny leaves
                    ForEach(0..<2, id: \.self) { index in
                        Ellipse()
                            .fill(Color(red: 0.4, green: 0.7, blue: 0.2))
                            .frame(width: 4, height: 6)
                            .offset(
                                x: index == 0 ? -3 : 3,
                                y: -size.width * 0.02
                            )
                            .rotationEffect(.degrees(index == 0 ? -30 : 30))
                    }
                }
                .offset(y: -size.width * 0.08)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Sparkle effects
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 2, height: 2)
                    .offset(
                        x: cos(animationOffset + Double(index) * 1.2) * Double(size.width * 0.15),
                        y: sin(animationOffset + Double(index) * 1.5) * Double(size.width * 0.15)
                    )
                    .animation(
                        .easeInOut(duration: 3 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isGerminating = true
                glowOpacity = 0.8
            }
        }
    }
}

// Enhanced progress bar style
struct EnhancedGreenProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.green.opacity(0.2))
                .frame(height: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
            
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(
                    colors: [
                        Color.green,
                        Color(red: 0.2, green: 0.8, blue: 0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 240, height: 8)
                .shadow(color: Color.green.opacity(0.5), radius: 2, x: 0, y: 1)
        }
    }
}

// Beautiful seed visualization
struct SeedVisualization: View {
    let size: CGSize
    @State private var isGerminating = false
    
    var body: some View {
                        ZStack {
            // Main seed body with realistic gradient
                            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.6, green: 0.4, blue: 0.2),
                        Color(red: 0.4, green: 0.25, blue: 0.1),
                        Color(red: 0.3, green: 0.2, blue: 0.08)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: size.width * 0.15
                ))
                .frame(width: size.width * 0.15, height: size.width * 0.18)
                .overlay(
                    // Seed texture lines
                    VStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.brown.opacity(0.3))
                                .frame(width: size.width * 0.1, height: 1)
                        }
                    }
                )
            
            // Small sprouting root (if germinating)
            if isGerminating {
                SeedSproutShape()
                    .stroke(Color(red: 0.9, green: 0.95, blue: 0.8), lineWidth: 2)
                    .frame(width: size.width * 0.08, height: size.width * 0.12)
                    .offset(y: size.width * 0.12)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Tiny green shoot
            if isGerminating {
                Rectangle()
                                .fill(LinearGradient(
                        colors: [
                            Color(red: 0.4, green: 0.8, blue: 0.2),
                            Color(red: 0.2, green: 0.6, blue: 0.1)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    ))
                    .frame(width: 3, height: size.width * 0.1)
                    .cornerRadius(1.5)
                    .offset(y: -size.width * 0.12)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Subtle glow effect
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color.green.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * 0.3
                ))
                .frame(width: size.width * 0.6, height: size.width * 0.6)
                .opacity(isGerminating ? 1 : 0.3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isGerminating = true
            }
        }
    }
}

// Seed sprout shape for the tiny root
struct SeedSproutShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        let control1 = CGPoint(x: rect.midX + rect.width * 0.3, y: rect.height * 0.3)
        let control2 = CGPoint(x: rect.midX - rect.width * 0.2, y: rect.height * 0.7)
        let end = CGPoint(x: rect.midX, y: rect.maxY)
        
        path.addCurve(to: end, control1: control1, control2: control2)
        
        return path
    }
}

// Add GreenProgressViewStyle
struct GreenProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.2))
                .frame(height: 8)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 200, height: 8)
        }
    }
}

// Enhanced Tree Shape Definitions with Growth Stages
struct TreeShape {
    enum TreeType {
        case oak, pine, maple, cherry, willow, birch, redwood, palm, defaultTree
    }
    
    static func create(_ type: TreeType, size: CGSize, stage: TreeStage = .mature, animationOffset: Double = 0) -> some View {
        switch type {
        case .oak:
            return AnyView(EnhancedOakTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .pine:
            return AnyView(EnhancedPineTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .maple:
            return AnyView(EnhancedMapleTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .cherry:
            return AnyView(EnhancedCherryTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .willow:
            return AnyView(EnhancedWillowTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .birch:
            return AnyView(EnhancedBirchTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .redwood:
            return AnyView(EnhancedRedwoodTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .palm:
            return AnyView(EnhancedPalmTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        case .defaultTree:
            return AnyView(EnhancedDefaultTreeShape(size: size, stage: stage, animationOffset: animationOffset))
        }
    }
}

// Enhanced Oak Tree - Strong, majestic with growth stages
struct EnhancedOakTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    @State private var isAnimating = false
    
    var body: some View {
                            ZStack {
            // Enhanced trunk with texture and growth
            ZStack {
                // Main trunk
                OakTrunkShape()
                                    .fill(LinearGradient(
                    colors: [
                            Color(red: 0.35, green: 0.2, blue: 0.1),
                            Color(red: 0.55, green: 0.35, blue: 0.2),
                            Color(red: 0.45, green: 0.25, blue: 0.15)
                    ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                    .frame(width: trunkWidth, height: trunkHeight)
                    .offset(y: size.height * 0.25)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 2, y: 2)
                
                // Bark texture lines
                ForEach(0..<Int(trunkHeight / 15), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.3, green: 0.15, blue: 0.05).opacity(0.6))
                        .frame(width: trunkWidth * 0.8, height: 2)
                        .offset(y: size.height * 0.25 - trunkHeight/2 + CGFloat(index) * 15)
                }
            }
            
            // Enhanced crown with layered complexity
            ZStack {
                // Shadow layer
                Ellipse()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: crownWidth * 1.1, height: crownHeight * 1.1)
                    .offset(x: 3, y: crownYOffset + 3)
                
                // Main crown with complex gradient
                OakCrownShape()
                    .fill(RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.75, blue: 0.3),
                            Color(red: 0.3, green: 0.65, blue: 0.25),
                            Color(red: 0.2, green: 0.5, blue: 0.15),
                            Color(red: 0.15, green: 0.4, blue: 0.1)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.2),
                        startRadius: 0,
                        endRadius: crownWidth * 0.6
                    ))
                    .frame(width: crownWidth, height: crownHeight)
                    .offset(y: crownYOffset)
                
                // Highlight layers for depth
                ForEach(0..<highlightCount, id: \.self) { index in
            Circle()
                        .fill(Color(red: 0.5, green: 0.8, blue: 0.4).opacity(0.3))
                        .frame(width: crownWidth * CGFloat(0.3 - Double(index) * 0.1))
                        .offset(
                            x: crownWidth * CGFloat(0.1 - Double(index) * 0.05),
                            y: crownYOffset - crownHeight * CGFloat(0.1 + Double(index) * 0.05)
                        )
                }
                
                // Animated leaves for mature trees
                if stage == .mature {
                    ForEach(0..<leafCount, id: \.self) { index in
                        Image(systemName: "leaf.fill")
                            .font(.system(size: CGFloat.random(in: 8...12)))
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.1).opacity(0.7))
                            .offset(
                                x: cos(animationOffset + Double(index) * 0.5) * Double(crownWidth * 0.3),
                                y: crownYOffset + sin(animationOffset + Double(index) * 0.3) * 10
                            )
                            .animation(
                                .easeInOut(duration: 3 + Double(index) * 0.5)
                                .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
            }
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
        .onAppear {
            isAnimating = true
        }
    }
    
    // Growth stage calculations
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat {
        size.width * (0.1 + CGFloat(stage.rawValue) * 0.03)
    }
    
    private var trunkHeight: CGFloat {
        size.height * (0.2 + CGFloat(stage.rawValue) * 0.1)
    }
    
    private var crownWidth: CGFloat {
        size.width * (0.4 + CGFloat(stage.rawValue) * 0.15)
    }
    
    private var crownHeight: CGFloat {
        size.height * (0.3 + CGFloat(stage.rawValue) * 0.15)
    }
    
    private var crownYOffset: CGFloat {
        -size.height * (0.05 + CGFloat(stage.rawValue) * 0.05)
    }
    
    private var highlightCount: Int {
        max(0, stage.rawValue)
    }
    
    private var leafCount: Int {
        stage == .mature ? 8 : 0
    }
}

// Oak-specific shapes
struct OakTrunkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create slightly tapered trunk
        path.move(to: CGPoint(x: width * 0.4, y: height))
        path.addQuadCurve(to: CGPoint(x: width * 0.45, y: 0), control: CGPoint(x: width * 0.3, y: height * 0.5))
        path.addQuadCurve(to: CGPoint(x: width * 0.55, y: 0), control: CGPoint(x: width * 0.5, y: height * 0.2))
        path.addQuadCurve(to: CGPoint(x: width * 0.6, y: height), control: CGPoint(x: width * 0.7, y: height * 0.5))
        path.closeSubpath()
        
        return path
    }
}

struct OakCrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Create irregular oak crown shape with lobes
        let lobes = 12
        for i in 0...lobes {
            let angle = Double(i) * 2 * .pi / Double(lobes)
            let variation = sin(Double(i) * 1.5) * 0.2 + 1
            let x = center.x + cos(angle) * radius * variation
            let y = center.y + sin(angle) * radius * variation * 0.8
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return path
    }
}

// Enhanced Pine Tree - Majestic evergreen with detailed needle layers
struct EnhancedPineTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Enhanced trunk with bark texture
            ZStack {
                // Main trunk with natural taper
                PineTrunkShape()
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.15, blue: 0.08),
                            Color(red: 0.45, green: 0.25, blue: 0.15),
                            Color(red: 0.35, green: 0.2, blue: 0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: trunkWidth, height: trunkHeight)
                    .offset(y: size.height * 0.3)
                    .shadow(color: Color.black.opacity(0.4), radius: 2, x: 1, y: 2)
                
                // Bark texture with vertical lines
                ForEach(0..<3, id: \.self) { index in
                    Rectangle()
                        .fill(Color(red: 0.25, green: 0.1, blue: 0.05).opacity(0.7))
                        .frame(width: 1, height: trunkHeight * 0.8)
                        .offset(
                            x: trunkWidth * (0.3 + CGFloat(index) * 0.2 - 0.5),
                            y: size.height * 0.3
                        )
                }
            }
            
            // Enhanced needle layers with natural variation
            ForEach(0..<layerCount, id: \.self) { layer in
                let layerProgress = Double(layer) / Double(max(layerCount - 1, 1))
                let layerWidth = size.width * (baseLayerWidth - layerProgress * 0.4)
                let layerHeight = size.height * layerHeightRatio
                let yOffset = -size.height * 0.35 + Double(layer) * size.height * 0.12
                
                ZStack {
                    // Shadow for each layer
                    EnhancedPineLayerShape(layerIndex: layer)
                        .fill(Color.black.opacity(0.15))
                        .frame(width: layerWidth, height: layerHeight)
                        .offset(x: 2, y: yOffset + 2)
                    
                    // Main needle layer with gradient
                    EnhancedPineLayerShape(layerIndex: layer)
                .fill(RadialGradient(
                    colors: [
                                Color(red: 0.15, green: 0.6, blue: 0.2),
                                Color(red: 0.1, green: 0.45, blue: 0.15),
                                Color(red: 0.05, green: 0.35, blue: 0.1)
                    ],
                            center: UnitPoint(x: 0.3, y: 0.2),
                    startRadius: 0,
                            endRadius: layerWidth * 0.8
                        ))
                        .frame(width: layerWidth, height: layerHeight)
                        .offset(y: yOffset)
                    
                    // Highlight details
                    EnhancedPineLayerShape(layerIndex: layer)
                        .stroke(Color(red: 0.2, green: 0.7, blue: 0.3).opacity(0.4), lineWidth: 1)
                        .frame(width: layerWidth * 0.9, height: layerHeight * 0.9)
                        .offset(y: yOffset)
                    
                    // Animated snow particles for mature trees
                    if stage == .mature && layer < 2 {
                        ForEach(0..<3, id: \.self) { particle in
            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 3, height: 3)
                                .offset(
                                    x: cos(animationOffset + Double(particle) * 2) * Double(layerWidth * 0.2),
                                    y: yOffset + sin(animationOffset + Double(particle) * 1.5) * 5
                                )
                                .animation(
                                    .easeInOut(duration: 4 + Double(particle))
                                    .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        }
                    }
                }
                .opacity(layerOpacity(for: layer))
            }
            
            // Animated pine cones for mature trees
            if stage == .mature {
                ForEach(0..<3, id: \.self) { cone in
                    PineConeShape()
                        .fill(Color(red: 0.4, green: 0.2, blue: 0.1))
                        .frame(width: 8, height: 12)
                        .offset(
                            x: cos(Double(cone) * 2.1) * Double(size.width * 0.2),
                            y: -size.height * 0.1 + sin(animationOffset + Double(cone)) * 3
                        )
                        .animation(
                            .easeInOut(duration: 3 + Double(cone) * 0.5)
                            .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
        .onAppear {
            isAnimating = true
        }
    }
    
    // Growth stage calculations
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.35
        case .sprout: return 0.65
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.5
        case .sapling: return 0.7
        case .sprout: return 0.85
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat {
        size.width * (0.08 + CGFloat(stage.rawValue) * 0.02)
    }
    
    private var trunkHeight: CGFloat {
        size.height * (0.25 + CGFloat(stage.rawValue) * 0.1)
    }
    
    private var layerCount: Int {
        3 + stage.rawValue
    }
    
    private var baseLayerWidth: Double {
        0.6 + Double(stage.rawValue) * 0.1
    }
    
    private var layerHeightRatio: Double {
        0.18 + Double(stage.rawValue) * 0.03
    }
    
    private func layerOpacity(for layer: Int) -> Double {
        let maxOpacity = stageOpacity
        let fadeStart = max(0, layerCount - 2)
        return layer >= fadeStart ? maxOpacity * 0.7 : maxOpacity
    }
}

// Pine-specific shapes
struct PineTrunkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create tapered trunk typical of pine trees
        path.move(to: CGPoint(x: width * 0.35, y: height))
        path.addCurve(
            to: CGPoint(x: width * 0.48, y: 0),
            control1: CGPoint(x: width * 0.25, y: height * 0.7),
            control2: CGPoint(x: width * 0.4, y: height * 0.3)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.52, y: 0),
            control1: CGPoint(x: width * 0.5, y: height * 0.1),
            control2: CGPoint(x: width * 0.5, y: height * 0.1)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.65, y: height),
            control1: CGPoint(x: width * 0.6, y: height * 0.3),
            control2: CGPoint(x: width * 0.75, y: height * 0.7)
        )
        path.closeSubpath()
        
        return path
    }
}

struct EnhancedPineLayerShape: Shape {
    let layerIndex: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.minY)
        let baseWidth = rect.width
        let height = rect.height
        
        // Start at the top center
        path.move(to: center)
        
        // Create detailed needle edges with natural variation
        let needleCount = 16 + layerIndex * 2
        let angleStep = .pi / Double(needleCount / 2)
        
        for i in 0...needleCount {
            let angle = -angleStep * Double(needleCount / 2) + angleStep * Double(i)
            let isLeft = i <= needleCount / 2
            
            // Create natural needle variation
            let needleLength = sin(Double(i) * 0.8) * 0.15 + 0.85
            let baseDistance = baseWidth / 2 * needleLength
            let verticalPos = height * (0.3 + 0.7 * abs(sin(angle * 1.5)))
            
            // Add small random variations for natural look
            let randomVariation = sin(Double(i * layerIndex + 7)) * 0.1
            let finalDistance = baseDistance * (1 + randomVariation)
            
            let x = center.x + cos(angle) * finalDistance
            let y = center.y + verticalPos
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                // Add slight curves for organic feel
                let controlDistance = finalDistance * 0.3
                let controlX = center.x + cos(angle) * controlDistance
                let controlY = center.y + verticalPos * 0.5
                
                path.addQuadCurve(
                    to: CGPoint(x: x, y: y),
                    control: CGPoint(x: controlX, y: controlY)
                )
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct PineConeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Create oval pine cone shape
        path.addEllipse(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return path
    }
}

// Enhanced placeholder trees (simplified versions for now)
struct EnhancedMapleTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    
    var body: some View {
        // Enhanced maple with beautiful fall colors
        ZStack {
            // Trunk
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.25, blue: 0.1),
                        Color(red: 0.55, green: 0.35, blue: 0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: trunkWidth, height: trunkHeight)
                .offset(y: size.height * 0.25)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 2, y: 2)
            
            // Maple crown with autumn colors
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.8, green: 0.6, blue: 0.2),
                        Color(red: 0.9, green: 0.4, blue: 0.1),
                        Color(red: 0.7, green: 0.2, blue: 0.1)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: crownWidth * 0.6
                ))
                .frame(width: crownWidth, height: crownHeight)
                .offset(y: crownYOffset)
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
    }
    
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat { size.width * (0.1 + CGFloat(stage.rawValue) * 0.03) }
    private var trunkHeight: CGFloat { size.height * (0.2 + CGFloat(stage.rawValue) * 0.1) }
    private var crownWidth: CGFloat { size.width * (0.4 + CGFloat(stage.rawValue) * 0.15) }
    private var crownHeight: CGFloat { size.height * (0.3 + CGFloat(stage.rawValue) * 0.15) }
    private var crownYOffset: CGFloat { -size.height * (0.05 + CGFloat(stage.rawValue) * 0.05) }
}

struct EnhancedCherryTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    
    var body: some View {
                            ZStack {
            // Trunk
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.35, green: 0.2, blue: 0.1),
                        Color(red: 0.5, green: 0.3, blue: 0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: trunkWidth, height: trunkHeight)
                .offset(y: size.height * 0.25)
            
            // Cherry blossom crown
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.8, blue: 0.9),
                        Color(red: 0.9, green: 0.6, blue: 0.8),
                        Color(red: 0.4, green: 0.7, blue: 0.3)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: crownWidth * 0.6
                ))
                .frame(width: crownWidth, height: crownHeight)
                .offset(y: crownYOffset)
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
    }
    
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat { size.width * (0.08 + CGFloat(stage.rawValue) * 0.02) }
    private var trunkHeight: CGFloat { size.height * (0.2 + CGFloat(stage.rawValue) * 0.08) }
    private var crownWidth: CGFloat { size.width * (0.35 + CGFloat(stage.rawValue) * 0.12) }
    private var crownHeight: CGFloat { size.height * (0.25 + CGFloat(stage.rawValue) * 0.12) }
    private var crownYOffset: CGFloat { -size.height * (0.03 + CGFloat(stage.rawValue) * 0.03) }
}

struct EnhancedWillowTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    
    var body: some View {
        ZStack {
            // Trunk
            RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [
                        Color(red: 0.4, green: 0.25, blue: 0.1),
                        Color(red: 0.6, green: 0.4, blue: 0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: trunkWidth, height: trunkHeight)
                .offset(y: size.height * 0.25)
            
            // Drooping willow crown
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.5, green: 0.7, blue: 0.3),
                        Color(red: 0.3, green: 0.6, blue: 0.2),
                        Color(red: 0.2, green: 0.4, blue: 0.15)
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: crownWidth * 0.6
                ))
                .frame(width: crownWidth, height: crownHeight * 1.2)
                .offset(y: crownYOffset)
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
    }
    
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat { size.width * (0.12 + CGFloat(stage.rawValue) * 0.03) }
    private var trunkHeight: CGFloat { size.height * (0.25 + CGFloat(stage.rawValue) * 0.1) }
    private var crownWidth: CGFloat { size.width * (0.45 + CGFloat(stage.rawValue) * 0.15) }
    private var crownHeight: CGFloat { size.height * (0.25 + CGFloat(stage.rawValue) * 0.1) }
    private var crownYOffset: CGFloat { -size.height * (0.02 + CGFloat(stage.rawValue) * 0.03) }
}

struct EnhancedBirchTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    
    var body: some View {
        ZStack {
            // Distinctive white birch trunk with black stripes
            Rectangle()
                .fill(Color.white)
                .frame(width: trunkWidth, height: trunkHeight)
                .offset(y: size.height * 0.25)
                .overlay(
                    VStack(spacing: trunkHeight * 0.08) {
                        ForEach(0..<Int(trunkHeight / (trunkHeight * 0.1)), id: \.self) { _ in
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: trunkWidth * 1.1, height: 2)
                        }
                    }
                    .offset(y: size.height * 0.25)
                )
            
            // Delicate birch crown
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.6, green: 0.8, blue: 0.4),
                        Color(red: 0.4, green: 0.6, blue: 0.25),
                        Color(red: 0.3, green: 0.5, blue: 0.2)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: crownWidth * 0.4
                ))
                .frame(width: crownWidth, height: crownHeight)
                .offset(y: crownYOffset)
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
    }
    
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat { size.width * (0.06 + CGFloat(stage.rawValue) * 0.02) }
    private var trunkHeight: CGFloat { size.height * (0.35 + CGFloat(stage.rawValue) * 0.15) }
    private var crownWidth: CGFloat { size.width * (0.3 + CGFloat(stage.rawValue) * 0.1) }
    private var crownHeight: CGFloat { size.height * (0.2 + CGFloat(stage.rawValue) * 0.1) }
    private var crownYOffset: CGFloat { -size.height * (0.1 + CGFloat(stage.rawValue) * 0.08) }
}

struct EnhancedRedwoodTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    
    var body: some View {
        ZStack {
            // Massive redwood trunk
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.5, green: 0.3, blue: 0.2),
                        Color(red: 0.7, green: 0.4, blue: 0.3),
                        Color(red: 0.6, green: 0.35, blue: 0.25)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: trunkWidth, height: trunkHeight)
                .offset(y: size.height * 0.15)
            
            // Towering conical crown
            Triangle()
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.5, blue: 0.15),
                        Color(red: 0.15, green: 0.4, blue: 0.1),
                        Color(red: 0.1, green: 0.3, blue: 0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                .frame(width: crownWidth, height: crownHeight)
                .offset(y: crownYOffset)
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
    }
    
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat { size.width * (0.15 + CGFloat(stage.rawValue) * 0.05) }
    private var trunkHeight: CGFloat { size.height * (0.4 + CGFloat(stage.rawValue) * 0.2) }
    private var crownWidth: CGFloat { size.width * (0.4 + CGFloat(stage.rawValue) * 0.1) }
    private var crownHeight: CGFloat { size.height * (0.5 + CGFloat(stage.rawValue) * 0.2) }
    private var crownYOffset: CGFloat { -size.height * (0.2 + CGFloat(stage.rawValue) * 0.1) }
}

struct EnhancedPalmTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    
    var body: some View {
        ZStack {
            // Curved palm trunk
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.6, green: 0.4, blue: 0.2),
                        Color(red: 0.8, green: 0.6, blue: 0.4)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: trunkWidth, height: trunkHeight)
                .offset(y: size.height * 0.2)
            
            // Palm fronds
            ForEach(0..<frondCount, id: \.self) { index in
                Ellipse()
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.2),
                            Color(red: 0.2, green: 0.5, blue: 0.15)
                        ],
                        startPoint: .center,
                        endPoint: .trailing
                    ))
                    .frame(width: crownWidth * 0.6, height: crownHeight * 0.3)
                    .rotationEffect(.degrees(Double(index) * (360.0 / Double(frondCount))))
                    .offset(y: crownYOffset)
            }
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
    }
    
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat { size.width * (0.08 + CGFloat(stage.rawValue) * 0.02) }
    private var trunkHeight: CGFloat { size.height * (0.4 + CGFloat(stage.rawValue) * 0.15) }
    private var crownWidth: CGFloat { size.width * (0.4 + CGFloat(stage.rawValue) * 0.2) }
    private var crownHeight: CGFloat { size.height * (0.15 + CGFloat(stage.rawValue) * 0.1) }
    private var crownYOffset: CGFloat { -size.height * (0.2 + CGFloat(stage.rawValue) * 0.1) }
    private var frondCount: Int { 4 + stage.rawValue * 2 }
}

struct EnhancedDefaultTreeShape: View {
    let size: CGSize
    let stage: TreeStage
    let animationOffset: Double
    
    var body: some View {
        ZStack {
            // Default trunk
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.2, blue: 0.1),
                        Color(red: 0.6, green: 0.3, blue: 0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: trunkWidth, height: trunkHeight)
                .offset(y: size.height * 0.25)
            
            // Default crown
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.4, green: 0.7, blue: 0.2),
                        Color(red: 0.3, green: 0.6, blue: 0.18),
                        Color(red: 0.2, green: 0.5, blue: 0.15)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: crownWidth * 0.5
                ))
                .frame(width: crownWidth, height: crownHeight)
                .offset(y: crownYOffset)
        }
        .scaleEffect(stageScale)
        .opacity(stageOpacity)
    }
    
    private var stageScale: CGFloat {
        switch stage {
        case .seed: return 0.1
        case .sapling: return 0.3
        case .sprout: return 0.6
        case .mature: return 1.0
        }
    }
    
    private var stageOpacity: Double {
        switch stage {
        case .seed: return 0.6
        case .sapling: return 0.75
        case .sprout: return 0.9
        case .mature: return 1.0
        }
    }
    
    private var trunkWidth: CGFloat { size.width * (0.1 + CGFloat(stage.rawValue) * 0.03) }
    private var trunkHeight: CGFloat { size.height * (0.2 + CGFloat(stage.rawValue) * 0.1) }
    private var crownWidth: CGFloat { size.width * (0.4 + CGFloat(stage.rawValue) * 0.15) }
    private var crownHeight: CGFloat { size.height * (0.3 + CGFloat(stage.rawValue) * 0.15) }
    private var crownYOffset: CGFloat { -size.height * (0.05 + CGFloat(stage.rawValue) * 0.05) }
}

// Helper shape for triangular trees
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Maple Tree - Distinctive broad crown
struct MapleTreeShape: View {
    let size: CGSize
    
    var body: some View {
                            ZStack {
            // Trunk
            RoundedRectangle(cornerRadius: 6)
                                    .fill(LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.25, blue: 0.1),
                        Color(red: 0.55, green: 0.35, blue: 0.2)
                    ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                .frame(width: size.width * 0.12, height: size.height * 0.35)
                .offset(y: size.height * 0.325)
            
            // Maple crown with characteristic lobed shape
            MapleLeafShape()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.6, green: 0.8, blue: 0.2),
                        Color(red: 0.4, green: 0.6, blue: 0.15),
                        Color(red: 0.2, green: 0.4, blue: 0.1)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * 0.4
                ))
                .frame(width: size.width * 0.85, height: size.height * 0.7)
                .offset(y: -size.height * 0.05)
        }
    }
}

struct MapleLeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        // Create maple-like crown with multiple lobes
        path.move(to: CGPoint(x: center.x, y: rect.minY))
        
        // Main central lobe (top)
        path.addCurve(
            to: CGPoint(x: center.x + rect.width * 0.15, y: center.y - rect.height * 0.2),
            control1: CGPoint(x: center.x + rect.width * 0.1, y: rect.minY + rect.height * 0.1),
            control2: CGPoint(x: center.x + rect.width * 0.15, y: center.y - rect.height * 0.3)
        )
        
        // Right side lobes
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: center.y),
            control1: CGPoint(x: center.x + rect.width * 0.3, y: center.y - rect.height * 0.1),
            control2: CGPoint(x: rect.maxX - rect.width * 0.1, y: center.y - rect.height * 0.1)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x + rect.width * 0.2, y: rect.maxY),
            control1: CGPoint(x: rect.maxX - rect.width * 0.1, y: center.y + rect.height * 0.2),
            control2: CGPoint(x: center.x + rect.width * 0.3, y: rect.maxY - rect.height * 0.1)
        )
        
        // Bottom and left side
        path.addCurve(
            to: CGPoint(x: center.x - rect.width * 0.2, y: rect.maxY),
            control1: CGPoint(x: center.x + rect.width * 0.1, y: rect.maxY),
            control2: CGPoint(x: center.x - rect.width * 0.1, y: rect.maxY)
        )
        
        path.addCurve(
            to: CGPoint(x: rect.minX, y: center.y),
            control1: CGPoint(x: center.x - rect.width * 0.3, y: rect.maxY - rect.height * 0.1),
            control2: CGPoint(x: rect.minX + rect.width * 0.1, y: center.y + rect.height * 0.2)
        )
        
        path.addCurve(
            to: CGPoint(x: center.x - rect.width * 0.15, y: center.y - rect.height * 0.2),
            control1: CGPoint(x: rect.minX + rect.width * 0.1, y: center.y - rect.height * 0.1),
            control2: CGPoint(x: center.x - rect.width * 0.3, y: center.y - rect.height * 0.1)
        )
        
        // Close to top
        path.addCurve(
            to: CGPoint(x: center.x, y: rect.minY),
            control1: CGPoint(x: center.x - rect.width * 0.15, y: center.y - rect.height * 0.3),
            control2: CGPoint(x: center.x - rect.width * 0.1, y: rect.minY + rect.height * 0.1)
        )
        
        return path
    }
}

// Cherry Tree - Delicate with blossoms
struct CherryTreeShape: View {
    let size: CGSize
    
    var body: some View {
                            ZStack {
            // Trunk
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.35, green: 0.2, blue: 0.1),
                        Color(red: 0.5, green: 0.3, blue: 0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: size.width * 0.1, height: size.height * 0.35)
                .offset(y: size.height * 0.325)
            
            // Main foliage crown
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.4, green: 0.7, blue: 0.3),
                        Color(red: 0.2, green: 0.5, blue: 0.2)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: size.width * 0.3
                ))
                .frame(width: size.width * 0.7, height: size.height * 0.55)
                .offset(y: -size.height * 0.05)
            
            // Cherry blossoms scattered throughout
            ForEach(0..<12, id: \.self) { index in
                let angle = Double(index) * 30.0
                let radius = size.width * 0.25
                let x = cos(angle * .pi / 180) * radius
                let y = sin(angle * .pi / 180) * radius * 0.6 - size.height * 0.05
                
                CherryBlossomShape()
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.8, blue: 0.9),
                            Color(red: 1.0, green: 0.6, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: size.width * 0.06, height: size.width * 0.06)
                    .offset(x: x, y: y)
            }
        }
    }
}

struct CherryBlossomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let petalLength = rect.width * 0.4
        
        // Create 5-petal cherry blossom
        for i in 0..<5 {
            let angle = Double(i) * 72.0 * .pi / 180
            let petalTip = CGPoint(
                x: center.x + cos(angle) * petalLength,
                y: center.y + sin(angle) * petalLength
            )
            
            let control1 = CGPoint(
                x: center.x + cos(angle - 0.3) * petalLength * 0.6,
                y: center.y + sin(angle - 0.3) * petalLength * 0.6
            )
            
            let control2 = CGPoint(
                x: center.x + cos(angle + 0.3) * petalLength * 0.6,
                y: center.y + sin(angle + 0.3) * petalLength * 0.6
            )
            
            if i == 0 {
                path.move(to: center)
            }
            
            path.addQuadCurve(to: petalTip, control: control1)
            path.addQuadCurve(to: center, control: control2)
        }
        
        return path
    }
}

// Willow Tree - Drooping branches
struct WillowTreeShape: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Trunk
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.25, blue: 0.1),
                        Color(red: 0.6, green: 0.4, blue: 0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: size.width * 0.14, height: size.height * 0.4)
                .offset(y: size.height * 0.3)
            
            // Main crown
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.4, green: 0.6, blue: 0.2),
                        Color(red: 0.2, green: 0.4, blue: 0.15)
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: size.width * 0.4
                ))
                .frame(width: size.width * 0.6, height: size.height * 0.4)
                .offset(y: -size.height * 0.15)
            
            // Drooping branches
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * 45.0
                let startRadius = size.width * 0.25
                let x = cos(angle * .pi / 180) * startRadius
                
                WillowBranchShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.5, blue: 0.2),
                                Color(red: 0.2, green: 0.4, blue: 0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .frame(width: size.width * 0.15, height: size.height * 0.5)
                    .offset(x: x, y: size.height * 0.05)
            }
        }
    }
}

struct WillowBranchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create drooping curved branch
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        let control1 = CGPoint(x: rect.midX + rect.width * 0.3, y: rect.height * 0.3)
        let control2 = CGPoint(x: rect.midX - rect.width * 0.2, y: rect.height * 0.7)
        let end = CGPoint(x: rect.midX + rect.width * 0.1, y: rect.maxY)
        
        path.addCurve(to: end, control1: control1, control2: control2)
        
        return path
    }
}

// Birch Tree - Tall, slender with distinctive bark
struct BirchTreeShape: View {
    let size: CGSize
    
    var body: some View {
                            ZStack {
            // Main trunk with birch bark pattern
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: size.width * 0.08, height: size.height * 0.6)
                .offset(y: size.height * 0.2)
                .overlay(
                    // Birch bark horizontal stripes
                    VStack(spacing: size.height * 0.03) {
                        ForEach(0..<8, id: \.self) { _ in
                                Rectangle()
                                .fill(Color.black)
                                .frame(width: size.width * 0.1, height: 2)
                        }
                    }
                    .offset(y: size.height * 0.2)
                )
            
            // Small, delicate crown
            Ellipse()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.5, green: 0.7, blue: 0.3),
                        Color(red: 0.3, green: 0.5, blue: 0.2)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: size.width * 0.2
                ))
                .frame(width: size.width * 0.5, height: size.height * 0.45)
                .offset(y: -size.height * 0.15)
            
            // Additional smaller branches
            ForEach(0..<6, id: \.self) { index in
                let angle = Double(index) * 60.0
                let radius = size.width * 0.15
                let x = cos(angle * .pi / 180) * radius
                let y = sin(angle * .pi / 180) * radius * 0.5 - size.height * 0.1
                
                Circle()
                    .fill(Color(red: 0.4, green: 0.6, blue: 0.25).opacity(0.7))
                    .frame(width: size.width * 0.12, height: size.width * 0.12)
                    .offset(x: x, y: y)
            }
        }
    }
}

// Redwood Tree - Very tall, majestic
struct RedwoodTreeShape: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Massive trunk
            RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(
                    colors: [
                        Color(red: 0.5, green: 0.3, blue: 0.2),
                        Color(red: 0.7, green: 0.4, blue: 0.3)
                    ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                .frame(width: size.width * 0.2, height: size.height * 0.7)
                .offset(y: size.height * 0.15)
                                
                                // Bark texture
            VStack(spacing: 4) {
                ForEach(0..<12, id: \.self) { _ in
                                    Rectangle()
                        .fill(Color(red: 0.4, green: 0.25, blue: 0.15).opacity(0.6))
                        .frame(width: size.width * 0.18, height: 2)
                }
            }
            .offset(y: size.height * 0.15)
            
            // Towering conical crown
            RedwoodCrownShape()
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.4, blue: 0.1),
                        Color(red: 0.1, green: 0.3, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: size.width * 0.6, height: size.height * 0.8)
                .offset(y: -size.height * 0.2)
        }
    }
}

struct RedwoodCrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create tall, narrow conical shape
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        // Left side with slight curves
        let leftControl1 = CGPoint(x: rect.midX - rect.width * 0.1, y: rect.height * 0.3)
        let leftControl2 = CGPoint(x: rect.midX - rect.width * 0.3, y: rect.height * 0.7)
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.maxY),
            control1: leftControl1,
            control2: leftControl2
        )
        
        // Bottom
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.maxY))
        
        // Right side
        let rightControl1 = CGPoint(x: rect.midX + rect.width * 0.3, y: rect.height * 0.7)
        let rightControl2 = CGPoint(x: rect.midX + rect.width * 0.1, y: rect.height * 0.3)
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: rightControl1,
            control2: rightControl2
        )
        
        return path
    }
}

// Palm Tree - Tropical with fronds
struct PalmTreeShape: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Curved trunk
            PalmTrunkShape()
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.6, green: 0.4, blue: 0.2),
                        Color(red: 0.8, green: 0.6, blue: 0.4)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: size.width * 0.12, height: size.height * 0.7)
                .offset(y: size.height * 0.15)
            
            // Palm fronds
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * 45.0
                
                PalmFrondShape()
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.1),
                            Color(red: 0.1, green: 0.4, blue: 0.05)
                        ],
                        startPoint: .center,
                        endPoint: .topTrailing
                    ))
                    .frame(width: size.width * 0.4, height: size.height * 0.25)
                    .rotationEffect(.degrees(angle))
                    .offset(y: -size.height * 0.25)
            }
            
            // Coconuts
            ForEach(0..<3, id: \.self) { index in
                let angle = Double(index) * 120.0
                let radius = size.width * 0.08
                let x = cos(angle * .pi / 180) * radius
                let y = sin(angle * .pi / 180) * radius
                
                Ellipse()
                    .fill(Color(red: 0.4, green: 0.3, blue: 0.1))
                    .frame(width: size.width * 0.06, height: size.width * 0.08)
                    .offset(x: x, y: y - size.height * 0.2)
            }
        }
    }
}

struct PalmTrunkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create slightly curved palm trunk
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        
        let control1 = CGPoint(x: rect.midX - rect.width * 0.2, y: rect.height * 0.7)
        let control2 = CGPoint(x: rect.midX + rect.width * 0.1, y: rect.height * 0.3)
        let top = CGPoint(x: rect.midX, y: rect.minY)
        
        path.addCurve(to: top, control1: control1, control2: control2)
        
        // Add thickness by creating the other side
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 0.5, y: rect.minY))
        
        let rightControl1 = CGPoint(x: rect.midX + rect.width * 0.6, y: rect.height * 0.3)
        let rightControl2 = CGPoint(x: rect.midX + rect.width * 0.3, y: rect.height * 0.7)
        
        path.addCurve(
            to: CGPoint(x: rect.midX + rect.width * 0.5, y: rect.maxY),
            control1: rightControl1,
            control2: rightControl2
        )
        
        path.closeSubpath()
        return path
    }
}

struct PalmFrondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create palm frond shape
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Main frond curve
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.2)
        )
        
        // Add leaf segments along the frond
        for i in 0..<6 {
            let progress = Double(i) / 5.0
            let x = rect.minX + rect.width * progress
            let y = rect.maxY - rect.height * progress * 0.8
            
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x - rect.width * 0.1, y: y - rect.height * 0.1))
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + rect.width * 0.1, y: y - rect.height * 0.1))
        }
        
        return path
    }
}

// Default Tree - Generic tree shape
struct DefaultTreeShape: View {
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Trunk
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.2, blue: 0.1),
                        Color(red: 0.6, green: 0.3, blue: 0.15)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: size.width * 0.12, height: size.height * 0.4)
                .offset(y: size.height * 0.3)
            
            // Crown - simple but elegant
            Circle()
                .fill(RadialGradient(
                    colors: [
                        Color(red: 0.4, green: 0.7, blue: 0.2),
                        Color(red: 0.2, green: 0.5, blue: 0.15)
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: size.width * 0.35
                ))
                .frame(width: size.width * 0.7, height: size.height * 0.55)
                .offset(y: -size.height * 0.05)
            
            // Highlight for dimension
                Circle()
                .fill(Color(red: 0.5, green: 0.8, blue: 0.3).opacity(0.4))
                .frame(width: size.width * 0.4, height: size.height * 0.3)
                .offset(x: -size.width * 0.1, y: -size.height * 0.1)
        }
    }
}

// Update the existing LeafCluster for backward compatibility
struct LeafCluster: View {
    let size: Double
    let angle: Double
    
    var body: some View {
        TreeShape.create(.defaultTree, size: CGSize(width: size, height: size))
            .rotationEffect(.degrees(angle))
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
        
        @MainActor func getWaterDrops() -> Int {
            // Only return waterdrops for authenticated users
            guard AccountManager.shared.isLoggedIn else { return 0 }
            
            let defaults = UserDefaults.standard
            switch self {
            case .search:
                return defaults.integer(forKey: "totalSearchWaterDrops")
            case .donation:
                return defaults.integer(forKey: "totalDonationWaterDrops")
            case .post:
                return defaults.integer(forKey: "totalPostWaterDrops")
            }
        }
        
        @MainActor func addWaterDrops(_ amount: Int) {
            // Only award waterdrops to authenticated users
            guard AccountManager.shared.isLoggedIn else { return }
            
            let defaults = UserDefaults.standard
            let key: String
            switch self {
            case .search:
                key = "totalSearchWaterDrops"
            case .donation:
                key = "totalDonationWaterDrops"
            case .post:
                key = "totalPostWaterDrops"
            }
            
            let currentTotal = defaults.integer(forKey: key)
            defaults.set(currentTotal + amount, forKey: key)
            NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
        }
    }
}

struct FloatingBubble: View {
    let type: ActivityBubble.ActivityType
    @State private var animating = false
    @State private var waterdrops: Int = 0
    
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
                    Text("\(waterdrops)")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white)
            }
        }
        .scaleEffect(animating ? 1.1 : 1.0)
        .onAppear {
            updateWaterdrops()
            withAnimation(
                Animation
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                animating = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .waterDropsDidChange)) { _ in
            updateWaterdrops()
        }
    }
    
    private func updateWaterdrops() {
        // Only show waterdrops for authenticated users
        Task { @MainActor in
            waterdrops = AccountManager.shared.isLoggedIn ? type.getWaterDrops() : 0
        }
    }
}

struct RewardCounterView: View {
    let type: ActivityBubble.ActivityType
    @Binding var isPresented: Bool
    @State private var countedValue: Int = 0
    
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
                    Task { @MainActor in
                        let rewardAmount = type.getWaterDrops()
                        // Animate counting
                        withAnimation(.easeOut(duration: 2.0)) {
                            for i in 0...rewardAmount {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (2.0 / Double(rewardAmount))) {
                                    countedValue = i
                                }
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

// Tree Gallery for guest users
struct TreeGalleryView: View {
    @State private var currentTreeIndex = 0
    @State private var timer: Timer?
    
    let guestTreeTypes = [
        ("Oak", TreeShape.TreeType.oak, "Strong and enduring"),
        ("Pine", TreeShape.TreeType.pine, "Evergreen beauty"),
        ("Maple", TreeShape.TreeType.maple, "Autumn colors"),
        ("Cherry", TreeShape.TreeType.cherry, "Spring blossoms"),
        ("Willow", TreeShape.TreeType.willow, "Graceful branches"),
        ("Birch", TreeShape.TreeType.birch, "White bark elegance"),
        ("Redwood", TreeShape.TreeType.redwood, "Towering majesty"),
        ("Palm", TreeShape.TreeType.palm, "Tropical paradise")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Current tree display
            VStack(spacing: 8) {
                TreeShape.create(guestTreeTypes[currentTreeIndex].1, size: CGSize(width: 120, height: 120))
                
                Text(guestTreeTypes[currentTreeIndex].0)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(guestTreeTypes[currentTreeIndex].2)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Tree indicator dots
            HStack(spacing: 8) {
                ForEach(0..<guestTreeTypes.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentTreeIndex ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentTreeIndex)
                }
            }
            
            // Guest message
            VStack(spacing: 8) {
                Text("🌱 Preview Mode")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Create an account to plant and grow your own trees!")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startTreeRotation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTreeRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentTreeIndex = (currentTreeIndex + 1) % guestTreeTypes.count
            }
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
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
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
                    if !AccountManager.shared.hasAnyAccess {
                        // Authentication prompt for Trees view
                        VStack(spacing: 20) {
                            Image(systemName: "tree.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Grow Your Virtual Tree")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Create an account to start growing your own virtual tree and track your environmental impact")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button {
                                viewModel.showingCreateAccount = true
                            } label: {
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .frame(width: 160)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else if AccountManager.shared.isGuestMode {
                        // Guest mode - show tree gallery but no planting
                        VStack(spacing: 20) {
                            VStack(spacing: 8) {
                                Text("Tree Gallery")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Explore different tree types")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        .padding()
                    } else {
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
                        if AccountManager.shared.isGuestMode {
                            // Guest mode - show tree gallery
                            TreeGalleryView()
                                .frame(height: 300)
                        } else {
                            TreeView(viewModel: viewModel)
                                .frame(height: 300)
                        }
                        
                        // Floating activity bubbles - only show for authenticated users
                        if AccountManager.shared.isLoggedIn {
                            ForEach(activityBubbles) { bubble in
                                FloatingBubble(type: bubble.type)
                                    .position(bubble.position)
                                    .onTapGesture {
                                        selectedActivity = bubble.type
                                        showingRewardCounter = true
                                    }
                            }
                        }
                        
                        // Water drops animation only for logged in users
                        if AccountManager.shared.isLoggedIn {
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
                    }
                    
                    Spacer()
                    
                    // Control buttons
                    if AccountManager.shared.isGuestMode {
                        // Guest mode buttons
                        VStack(spacing: 16) {
                            Button {
                                viewModel.showingCreateAccount = true
                            } label: {
                                Text("Create Account to Plant Trees")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                AccountManager.shared.exitGuestMode()
                            } label: {
                                Text("Exit Guest Mode")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    } else if AccountManager.shared.isLoggedIn {
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
                    }
                }
                
                // Reward counter overlay - only show for authenticated users
                if showingRewardCounter, let activity = selectedActivity, AccountManager.shared.isLoggedIn {
                    RewardCounterView(
                        type: activity,
                        isPresented: $showingRewardCounter
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
            .fullScreenCover(isPresented: $viewModel.showingTreeTypeSelection) {
                TreeTypeSelectionView(viewModel: viewModel)
            }
            .alert("Account Required", isPresented: $viewModel.showingLoginAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Create Account") {
                    viewModel.showingCreateAccount = true
                }
            } message: {
                Text("You need to create an account to use this feature.")
            }
            .sheet(isPresented: $showingManageAccount) {
                ManageAccountView(profileViewModel: ProfileViewModel())
            }
            .sheet(isPresented: $viewModel.showingCreateAccount) {
                CreateAccountView()
            }
        }
        .onAppear {
            initializeActivityBubbles()
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
    
    private func initializeActivityBubbles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        activityBubbles = [
            ActivityBubble(
                type: .search,
                position: CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.3),
                velocity: CGPoint(x: 1, y: 1)
            ),
            ActivityBubble(
                type: .donation,
                position: CGPoint(x: screenWidth * 0.7, y: screenHeight * 0.4),
                velocity: CGPoint(x: -1, y: 1)
            ),
            ActivityBubble(
                type: .post,
                position: CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.6),
                velocity: CGPoint(x: 1, y: -1)
            )
        ]
    }
    
    private func updateBubblePositions() {
        let bounds = UIScreen.main.bounds
        let padding: CGFloat = 40
        
        for i in activityBubbles.indices {
            // Update position
            activityBubbles[i].position.x += activityBubbles[i].velocity.x
            activityBubbles[i].position.y += activityBubbles[i].velocity.y
            
            // Bounce off edges
            if activityBubbles[i].position.x <= padding || activityBubbles[i].position.x >= bounds.width - padding {
                activityBubbles[i].velocity.x *= -1
            }
            if activityBubbles[i].position.y <= padding || activityBubbles[i].position.y >= bounds.height - padding {
                activityBubbles[i].velocity.y *= -1
            }
        }
    }
}

// Update UserStats class
@MainActor
class UserStats: ObservableObject {
    @Published var posts: Int = 0
    @Published var tracking: Int = 0
    @Published var followers: Int = 0
    @Published var waterDrops: Int = 0
    @Published var treesPlanted: Int = 0
    @Published var achievements: Int = 0
    @Published var growthDays: Int = 0
    @Published var totalLikes: Int = 0
    @Published var totalComments: Int = 0
    @Published var isLoading: Bool = false
    @Published var showingLoginPrompt: Bool = false
    private let appStartDateKey = "appStartDate"
    
    static let shared = UserStats() // Singleton instance for global access
    
    init() {
        fetchUserStats()
        
        // Observe authentication state changes
        NotificationCenter.default.addObserver(
            forName: .waterDropsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.fetchUserStats()
            }
        }
        
        // Observe authentication changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AuthenticationChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.fetchUserStats()
            }
        }
    }
    
    func fetchUserStats() {
        // If user is not logged in, reset all stats to 0
        guard AccountManager.shared.isLoggedIn else {
            resetStatsToZero()
            return
        }
        
        Task {
            await fetchFromBackendOrFallback()
        }
    }
    
    private func resetStatsToZero() {
        self.posts = 0
        self.tracking = 0
        self.followers = 0
        self.waterDrops = 0
        self.treesPlanted = 0
        self.achievements = 0
        self.growthDays = 0
        self.totalLikes = 0
        self.totalComments = 0
    }
    
    private func fetchFromBackendOrFallback() async {
        isLoading = true
        
        do {
            // Try to get authentication token first
            guard let user = AuthenticationService.shared.currentUser else {
                throw NSError(domain: "UserStats", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
            }
            
            // Get token for authenticated user
            let token = try await user.getIDToken()
            
            // Fetch user data from backend
            let userData = try await AccountService.shared.fetchCurrentUser(token: token)
            
            // Update published properties with backend data
            await MainActor.run {
                self.posts = userData.posts
                self.tracking = userData.tracking
                self.followers = userData.followers
                self.waterDrops = userData.waterDrops
                self.treesPlanted = userData.treesPlanted
                self.achievements = userData.achievements
                self.growthDays = userData.growthDays
                self.totalLikes = userData.totalLikes
                self.totalComments = userData.totalComments
                
                // Also update UserDefaults for backward compatibility
                UserDefaults.standard.set(self.posts, forKey: "userPosts")
                UserDefaults.standard.set(self.tracking, forKey: "userTracking")
                UserDefaults.standard.set(self.followers, forKey: "userFollowers")
                UserDefaults.standard.set(self.waterDrops, forKey: "userWaterDrops")
                UserDefaults.standard.set(self.treesPlanted, forKey: "userTreesPlanted")
                UserDefaults.standard.set(self.achievements, forKey: "userAchievements")
                UserDefaults.standard.set(self.totalLikes, forKey: "userTotalLikes")
                UserDefaults.standard.set(self.totalComments, forKey: "userTotalComments")
                
                // Notify observers of water drops change
                NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
            }
            
        } catch {
            print("Failed to fetch from backend, falling back to local storage: \(error)")
            // Fallback to local UserDefaults data
            await MainActor.run {
        self.posts = UserDefaults.standard.integer(forKey: "userPosts")
        self.tracking = UserDefaults.standard.integer(forKey: "userTracking")
        self.followers = UserDefaults.standard.integer(forKey: "userFollowers")
        self.waterDrops = UserDefaults.standard.integer(forKey: "userWaterDrops")
        self.treesPlanted = UserDefaults.standard.integer(forKey: "userTreesPlanted")
        self.achievements = UserDefaults.standard.integer(forKey: "userAchievements")
        self.totalLikes = UserDefaults.standard.integer(forKey: "userTotalLikes")
        self.totalComments = UserDefaults.standard.integer(forKey: "userTotalComments")
        
        // Calculate growth days
                if let startDate = UserDefaults.standard.object(forKey: self.appStartDateKey) as? Date {
            self.growthDays = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        } else {
            // First time app launch
                    UserDefaults.standard.set(Date(), forKey: self.appStartDateKey)
            self.growthDays = 0
        }
        
        // Notify observers of current water drops
        NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
            }
        }
        
        isLoading = false
    }
    
    func requireAuthentication() -> Bool {
        guard AccountManager.shared.isLoggedIn else {
            showingLoginPrompt = true
            return false
        }
        return true
    }
    
    func addPost() {
        guard requireAuthentication() else { return }
        posts += 1
        UserDefaults.standard.set(posts, forKey: "userPosts")
        Task { await syncWithBackend() }
    }
    
    func addFollower() {
        guard requireAuthentication() else { return }
        followers += 1
        UserDefaults.standard.set(followers, forKey: "userFollowers")
        Task { await syncWithBackend() }
    }
    
    func removeFollower() {
        guard requireAuthentication() else { return }
        followers = max(0, followers - 1)
        UserDefaults.standard.set(followers, forKey: "userFollowers")
        Task { await syncWithBackend() }
    }
    
    func addFollowing() {
        guard requireAuthentication() else { return }
        tracking += 1
        UserDefaults.standard.set(tracking, forKey: "userTracking")
        Task { await syncWithBackend() }
    }
    
    func removeFollowing() {
        guard requireAuthentication() else { return }
        tracking = max(0, tracking - 1)
        UserDefaults.standard.set(tracking, forKey: "userTracking")
        Task { await syncWithBackend() }
    }
    
    func addLike() {
        guard requireAuthentication() else { return }
        totalLikes += 1
        UserDefaults.standard.set(totalLikes, forKey: "userTotalLikes")
        Task { await syncWithBackend() }
    }
    
    func removeLike() {
        guard requireAuthentication() else { return }
        totalLikes = max(0, totalLikes - 1)
        UserDefaults.standard.set(totalLikes, forKey: "userTotalLikes")
        Task { await syncWithBackend() }
    }
    
    func addComment() {
        guard requireAuthentication() else { return }
        totalComments += 1
        UserDefaults.standard.set(totalComments, forKey: "userTotalComments")
        Task { await syncWithBackend() }
    }
    
    func removeComment() {
        guard requireAuthentication() else { return }
        totalComments = max(0, totalComments - 1)
        UserDefaults.standard.set(totalComments, forKey: "userTotalComments")
        Task { await syncWithBackend() }
    }
    
    func addWaterDrops(_ amount: Int) {
        guard requireAuthentication() else { return }
        waterDrops += amount
        UserDefaults.standard.set(waterDrops, forKey: "userWaterDrops")
        NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
        Task { await syncWithBackend() }
    }
    
    func useWaterDrops(_ amount: Int) -> Bool {
        guard requireAuthentication() else { return false }
        if waterDrops >= amount {
            waterDrops -= amount
            UserDefaults.standard.set(waterDrops, forKey: "userWaterDrops")
            NotificationCenter.default.post(name: .waterDropsDidChange, object: nil)
            Task { await syncWithBackend() }
            return true
        }
        return false
    }
    
    func addSearchWaterDrops() {
        guard requireAuthentication() else { return }
        let searchReward = 10
        addWaterDrops(searchReward)
        Task { @MainActor in
            ActivityBubble.ActivityType.search.addWaterDrops(searchReward)
        }
    }
    
    func addPostWaterDrops() {
        guard requireAuthentication() else { return }
        let postReward = 30
        Task { @MainActor in
            ActivityBubble.ActivityType.post.addWaterDrops(postReward)
        }
        addWaterDrops(postReward)
    }
    
    func addDonationWaterDrops(amount: Int) {
        guard requireAuthentication() else { return }
        let donationReward = amount * 5
        Task { @MainActor in
            ActivityBubble.ActivityType.donation.addWaterDrops(donationReward)
        }
        addWaterDrops(donationReward)
    }
    
    private func syncWithBackend() async {
        guard AccountManager.shared.isLoggedIn,
              let user = AuthenticationService.shared.currentUser else { return }
        
        do {
            let token = try await user.getIDToken()
            let statsUpdate = UserStatsUpdate(
                posts: posts,
                tracking: tracking,
                followers: followers,
                waterDrops: waterDrops,
                treesPlanted: treesPlanted,
                achievements: achievements,
                totalLikes: totalLikes,
                totalComments: totalComments
            )
            try await NetworkService.shared.syncUserStats(token: token, stats: statsUpdate)
        } catch {
            print("Failed to sync user stats with backend: \(error.localizedDescription)")
        }
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

struct MeResponse: Codable {
    let username: String
    let email: String
    let avatarUrl: URL?

    let posts: Int
    let tracking: Int
    let followers: Int
    let waterDrops: Int
    let treesPlanted: Int
    let achievements: Int
    let growthDays: Int
    let totalLikes: Int
    let totalComments: Int

    let dateOfBirth: Date?
    let selectedUnit: String
    let country: String
    let language: String
}

actor AccountService {
  static let shared = AccountService()
  private let baseURL = URL(string: Config.API.baseURL)!
  func fetchCurrentUser(token: String) async throws -> MeResponse {
    let url = baseURL.appendingPathComponent("/api/accounts/me/")
    var req = URLRequest(url: url)
    req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    let (data, resp) = try await URLSession.shared.data(for: req)
    guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
      throw URLError(.badServerResponse)
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(MeResponse.self, from: data)
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
        VStack(spacing: 0) {
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    ZStack {
                        // Background gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.green.opacity(0.2),
                                Color.blue.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Image placeholder with overlay
                        Rectangle()
                            .fill(Color.green.opacity(0.3))
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                    Text("Image \(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 220)
            
            // Custom page indicator
            HStack(spacing: 12) {
                ForEach(0..<images.count, id: \.self) { index in
                    Capsule()
                        .fill(currentIndex == index ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: currentIndex == index ? 24 : 8, height: 8)
                        .animation(.spring(), value: currentIndex)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct ServiceTeamView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ImageSlider()
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Our Service Team")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                    
                    Text("We are a dedicated team of environmental enthusiasts working tirelessly to make our planet greener. Our mission is to inspire and enable individuals to contribute to environmental sustainability through simple, everyday actions.")
                        .font(.body)
                        .padding(.horizontal, 24)
                    
                    Text("What We Do")
                        .font(.headline)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                    
                    Text("• Plant and maintain trees across urban and rural areas\n• Educate communities about environmental conservation\n• Organize local cleanup initiatives\n• Provide sustainable solutions for waste management\n• Partner with organizations to maximize environmental impact")
                        .font(.body)
                        .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
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
    @State private var showingCreateAccount = false
    
    let predefinedAmounts = [1.0, 5.0, 20.0, 100.0, 200.0, 500.0]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ImageSlider()
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Make a Difference")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                    
                    Text("Your donation helps us plant more trees and create a sustainable future. Every dollar counts towards making our planet greener and healthier for future generations.")
                        .font(.body)
                        .padding(.horizontal, 24)
                    
                    Text("Benefits")
                        .font(.headline)
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                    
                    Text("• Each dollar donated plants a new tree\n• Get 5x water drops for every dollar\n• Track your environmental impact\n• Receive regular updates about your contribution")
                        .font(.body)
                        .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
                
                // Donation amounts
                VStack(spacing: 16) {
                    Text("Select Amount")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(predefinedAmounts, id: \.self) { amount in
                            Button {
                                selectedAmount = amount
                                if AccountManager.shared.isLoggedIn {
                                    showingPaymentSheet = true
                                } else {
                                    showingLoginAlert = true
                                }
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
                    .padding(.horizontal, 24)
                    
                    if selectedAmount == nil {
                        TextField("Enter amount", text: $customAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 24)
                        
                        Button {
                            if Double(customAmount) != nil {
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
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.vertical, 24)
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
                showingCreateAccount = true
            }
        } message: {
            Text("You need to create an account to make a donation.")
        }
        .sheet(isPresented: $showingCreateAccount) {
            CreateAccountView()
        }
        .onChange(of: selectedAmount) { _, newValue in
            if !AccountManager.shared.isLoggedIn {
                showingLoginAlert = true
                selectedAmount = nil
            }
        }
        .onChange(of: customAmount) { _, newValue in
            if !AccountManager.shared.isLoggedIn && !newValue.isEmpty {
                showingLoginAlert = true
                customAmount = ""
            }
        }
    }
    
    private func handlePaymentCompletion() {
        // Only process rewards for authenticated users
        guard AccountManager.shared.isLoggedIn else {
            dismiss()
            return
        }
        
        let amount = selectedAmount ?? Double(customAmount) ?? 0
        
        // Add waterdrops locally
        UserStats.shared.addDonationWaterDrops(amount: Int(amount))
        
        // Record donation in backend
        Task {
            await recordDonationInBackend(amount: amount)
        }
        
        dismiss()
    }
    
    private func recordDonationInBackend(amount: Double) async {
        guard AccountManager.shared.isLoggedIn,
              let userId = AccountManager.shared.userId else { return }
        
        do {
            try await NetworkService.shared.recordDonation(
                userId: userId,
                amount: amount,
                currency: "USD",
                paymentMethod: "apple_pay"
            )
        } catch {
            print("Failed to record donation in backend: \(error.localizedDescription)")
        }
    }
}

// 3) Your updated PaymentHandlerView


struct PaymentHandlerView: View {
  let amount: Double
  let onCompletion: (Bool) -> Void

  private let handler = PaymentHandler()
  @State private var isProcessing = false
  @State private var errorMessage: String?

  var body: some View {
    VStack(spacing: 20) {
      // Header
      VStack(spacing: 8) {
        Text("Donation")
          .font(.title2)
          .fontWeight(.bold)
        
      Text("Pay \(formattedAmount)")
        .font(.headline)
          .foregroundColor(.green)
      }
      
      // Benefits
      VStack(spacing: 12) {
        HStack {
          Image(systemName: "drop.fill")
            .foregroundColor(.blue)
          Text("Earn \(Int(amount * 5)) Water Drops")
            .font(.subheadline)
        }
        
        HStack {
          Image(systemName: "leaf.fill")
            .foregroundColor(.green)
          Text("Support environmental projects")
            .font(.subheadline)
        }
      }
      .padding()
      .background(Color(UIColor.systemGray6))
      .cornerRadius(12)

      if isProcessing {
        VStack {
          ProgressView()
          Text("Processing payment...")
            .font(.caption)
            .foregroundColor(.gray)
        }
      } else {
        ApplePayButton(style: .black, type: .donate) {
          isProcessing = true
        handler.startPayment(total: NSDecimalNumber(value: amount)) { success in
            isProcessing = false
            if success {
              // Show success feedback
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onCompletion(true)
              }
            } else {
              errorMessage = "Payment failed. Please try again."
            }
        }
      }
      .frame(height: 45)
      .padding(.horizontal)
        .disabled(isProcessing)
      }
      
      if let error = errorMessage {
        Text(error)
          .foregroundColor(.red)
          .font(.caption)
      }

      Button("Cancel") {
        onCompletion(false)
      }
      .foregroundColor(.red)
      .disabled(isProcessing)
    }
    .padding()
  }

  private var formattedAmount: String {
    let fmt = NumberFormatter()
    fmt.numberStyle = .currency
    fmt.currencyCode = "USD"
    return fmt.string(from: amount as NSNumber) ?? "$\(amount)"
  }
}

// 2) A simple PaymentHandler that presents Apple Pay and calls your completion


class PaymentHandler: NSObject, PKPaymentAuthorizationControllerDelegate {
  static let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
  static let merchantIdentifier = "merchant.com.yourcompany.releaf"  // ← your Merchant ID

  private var completion: ((Bool) -> Void)?

  /// Call this to start the payment sheet.
  func startPayment(total: NSDecimalNumber, completion: @escaping (Bool) -> Void) {
    guard PKPaymentAuthorizationController.canMakePayments(usingNetworks: Self.supportedNetworks) else {
      completion(false)
      return
    }
    self.completion = completion
    
    let request = PKPaymentRequest()
    request.merchantIdentifier   = Self.merchantIdentifier
    request.countryCode          = "US"                 // your country
    request.currencyCode         = "USD"                // your currency
    request.merchantCapabilities = .threeDSecure
    request.supportedNetworks    = Self.supportedNetworks
    request.paymentSummaryItems  = [
      PKPaymentSummaryItem(label: "Releaf Order", amount: total),
      PKPaymentSummaryItem(label: "Your Company", amount: total)
    ]
    
    let controller = PKPaymentAuthorizationController(paymentRequest: request)
    controller.delegate = self
    controller.present(completion: nil)
  }

  // MARK: – PKPaymentAuthorizationControllerDelegate

  func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                      didAuthorizePayment payment: PKPayment,
                                      handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    // TODO: send payment.token to your backend for processing
    // For demo, we just succeed immediately:
    completion(.init(status: .success, errors: nil))
    self.completion?(true)
  }

  func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
    controller.dismiss(completion: nil)
    // If user cancelled without authorizing, call completion(false)
    // Note: didAuthorizePayment will have already called on success
    if let onDone = completion {
      onDone(false)
      completion = nil
    }
  }
}
struct ApplePayButton: UIViewRepresentable {
  let style: PKPaymentButtonStyle
  let type:  PKPaymentButtonType
  let action: () -> Void

  func makeUIView(context: Context) -> PKPaymentButton {
    let btn = PKPaymentButton(paymentButtonType: type, paymentButtonStyle: style)
    btn.addTarget(context.coordinator,
                  action: #selector(Coordinator.tapped),
                  for: .touchUpInside)
    return btn
  }

  func updateUIView(_ uiView: PKPaymentButton, context: Context) {
    // No updates needed for PKPaymentButton
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(action: action)
  }

  class Coordinator: NSObject {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
    @objc func tapped() { 
        action() 
    }
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
    @State private var accountName = ""
    @State private var email = ""
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
        .onAppear {
            // Load authenticated user information
            Task { @MainActor in
                accountName = AccountManager.shared.displayName ?? ""
                email = AccountManager.shared.userEmail ?? ""
            }
        }
    }
    
    private func saveAccount() {
        // Save profile information to UserDefaults
        UserDefaults.standard.set(accountName, forKey: "accountName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        // Sync with backend
        Task {
            await syncProfileWithBackend()
        }
        
        showingSaveConfirmation = true
    }
    
    private func syncProfileWithBackend() async {
        guard AccountManager.shared.isLoggedIn,
              let user = AuthenticationService.shared.currentUser else { return }
        
        do {
            let token = try await user.getIDToken()
            let profileUpdate = UserProfileUpdate(
                username: accountName.isEmpty ? nil : accountName,
                dateOfBirth: nil, // We'll add this when the UI supports it
                selectedUnit: UserDefaults.standard.string(forKey: "selectedUnit"),
                country: nil, // We'll add this when the UI supports it
                language: nil, // We'll add this when the UI supports it
                avatarData: profileViewModel.profileImage?.jpegData(compressionQuality: 0.8)
            )
            try await NetworkService.shared.updateUserProfile(token: token, profileData: profileUpdate)
        } catch {
            print("Failed to sync profile with backend: \(error.localizedDescription)")
        }
    }
    
    private func deleteAccount() {
        // Sign out from authentication service
        Task { @MainActor in
            AccountManager.shared.signOut()
        }
        dismiss()
    }
}

// Update ProfileView to include Manage Account button
struct ProfileView: View {
    @StateObject private var userStats = UserStats()
    @StateObject private var profileViewModel = ProfileViewModel()
    @ObservedObject private var accountManager = AccountManager.shared
    @State private var dateOfBirth = Date()
    @State private var selectedUnit = "Metric"
    @State private var selectedCountry = "United States"
    @State private var selectedLanguage = "English"
    @State private var showingManageAccount = false
    @State private var showingStatusPopup = false
    @State private var showingCreateAccount = false
    @AppStorage("selectedLanguage") private var selectedLanguageCode: String = ""
    let units = ["Metric", "Imperial"]
    let countries = ["United States", "Canada", "United Kingdom", "Australia", "Germany", "France", "Japan", "China"]
    let languages: [(code: String, name: String)] = [
      ("",    "System Default"),
      ("en",  "English"),
      ("es",  "Español"),
      ("fr",  "Français"),
      ("de",  "Deutsch"),
      ("zh-Hans", "中文"),
      ("ja",  "日本語")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if accountManager.isGuestMode {
                        // Guest mode profile view
                        VStack(spacing: 24) {
                            // Profile placeholder
                            VStack(spacing: 20) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                VStack(spacing: 8) {
                                    Text("Guest Mode")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("You're browsing as a guest with limited features")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            // Call to action
                            VStack(spacing: 16) {
                                Button {
                                    showingCreateAccount = true
                                } label: {
                                    Text("Create Account")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                                
                                Button {
                                    AccountManager.shared.exitGuestMode()
                                } label: {
                                    Text("Exit Guest Mode")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Create an account to unlock all features!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding()
                        
                    } else if !accountManager.isLoggedIn {
                        // Not logged in profile view
                        VStack(spacing: 24) {
                            // Profile placeholder
                            VStack(spacing: 20) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                VStack(spacing: 8) {
                                    Text("Welcome to Releaf!")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("Create an account to track your environmental impact")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            // Zero stats grid to show what they'd get
                            VStack(spacing: 16) {
                                Text("Your Stats")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 20) {
                                    StatBlock(title: "Posts", value: "0")
                                    StatBlock(title: "Tracking", value: "0")
                                    StatBlock(title: "Followers", value: "0")
                                    StatBlock(title: "WaterDrops", value: "0")
                                    StatBlock(title: "Trees Planted", value: "0")
                                    StatBlock(title: "Achievements", value: "0")
                                    StatBlock(title: "Growth Days", value: "0")
                                    StatBlock(title: "Likes", value: "0")
                                    StatBlock(title: "Comments", value: "0")
                                }
                                .opacity(0.5)
                            }
                            
                            // Call to action
                            VStack(spacing: 16) {
                                Button {
                                    showingCreateAccount = true
                                } label: {
                                    Text("Create Account")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                                
                                Text("Join our community to start tracking your sustainable journey!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding()
                        
                    } else {
                        // Profile Header - Logged in
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
                                Text(accountManager.displayName ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                                Text(accountManager.userEmail ?? "No email")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // User Status Badge
                            let currentStatus = UserStatus.calculateStatus(treesPlanted: userStats.treesPlanted)
                            Button {
                                withAnimation(.spring()) {
                                    showingStatusPopup = true
                                }
                            } label: {
                                Text(currentStatus.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(currentStatus.color)
                                    )
                            }
                            .padding(.top, 4)
                            .overlay {
                                if showingStatusPopup {
                                    StatusPopupView(
                                        currentStatus: currentStatus,
                                        isPresented: $showingStatusPopup
                                    )
                                }
                            }
                            
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
                                StatBlock(title: "Posts", value: userStats.isLoading ? "..." : "\(userStats.posts)")
                                StatBlock(title: "Tracking", value: userStats.isLoading ? "..." : "\(userStats.tracking)")
                                StatBlock(title: "Followers", value: userStats.isLoading ? "..." : "\(userStats.followers)")
                                StatBlock(title: "WaterDrops", value: userStats.isLoading ? "..." : "\(userStats.waterDrops)")
                                StatBlock(title: "Trees Planted", value: userStats.isLoading ? "..." : "\(userStats.treesPlanted)")
                                StatBlock(title: "Achievements", value: userStats.isLoading ? "..." : "\(userStats.achievements)")
                                StatBlock(title: "Growth Days", value: userStats.isLoading ? "..." : "\(userStats.growthDays)")
                                StatBlock(title: "Likes", value: userStats.isLoading ? "..." : "\(userStats.totalLikes)")
                                StatBlock(title: "Comments", value: userStats.isLoading ? "..." : "\(userStats.totalComments)")
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    }
                    
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
                    
                    // Settings Section - Only show if logged in
                    if accountManager.isLoggedIn {
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
                                .onChange(of: selectedUnit) { _, newValue in
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
                              Picker("", selection: $selectedLanguageCode) {
                                ForEach(languages, id: \.code) { lang in
                                  Text(lang.name).tag(lang.code)
                                }
                              }
                              .pickerStyle(.menu)
                              .labelsHidden()
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            // Sign Out
                            Button {
                                Task { @MainActor in
                                    AccountManager.shared.signOut()
                                }
                            } label: {
                                SettingRow(title: "Sign Out") {
                                    Image(systemName: "arrow.right.square")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                            }
                            .foregroundColor(.red)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        }
                    }
                    
                    // Others (Previously Additional Options)
                    VStack(alignment: .leading, spacing: 24) {
                        Text("OTHERS")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            if !accountManager.isGuestMode {
                                NavigationLink(destination: Text("Favorites")) {
                                    SettingRow(title: "Favorites") {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Divider()
                                    .padding(.horizontal)
                            }
                            
                            NavigationLink(destination: HelpSupportView()) {
                                SettingRow(title: "Help & Support") {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Divider()
                                .padding(.horizontal)
                            
                            NavigationLink(destination: TermsOfServiceView()) {
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
            .navigationTitle(accountManager.isGuestMode ? "Hi, Guest!" : "Hi, \(accountManager.displayName ?? "Friend")!")
            .onAppear {
                userStats.fetchUserStats()
                profileViewModel.loadProfileImage()
            }
            .sheet(isPresented: $profileViewModel.showingProfileOptions) {
                ProfilePhotoOptionsView(viewModel: profileViewModel)
            }
            .sheet(isPresented: $showingCreateAccount) {
                CreateAccountView()
            }
            .sheet(isPresented: $userStats.showingLoginPrompt) {
                CreateAccountView()
            }
            .overlay {
                if showingStatusPopup {
                    GeometryReader { geometry in
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showingStatusPopup = false
                                }
                            }
                        
                        VStack {
                            Spacer()
                            StatusPopupView(
                                currentStatus: UserStatus.calculateStatus(treesPlanted: userStats.treesPlanted),
                                isPresented: $showingStatusPopup
                            )
                        }
                    }
                }
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

// Model for material categories
struct MaterialCategory: Identifiable {
    let id = UUID()
    let name: String
    let systemImage: String
    let color: Color
}

struct MaterialMenuView: View {
    @Binding var isPresented: Bool
    @State private var selectedCategory: MaterialCategory?
    @State private var showPosts = false

    let categories = [
        MaterialCategory(name: "Metals", systemImage: "bolt.fill", color: .orange),
        MaterialCategory(name: "Plastic", systemImage: "arrow.triangle.2.circlepath", color: .blue),
        MaterialCategory(name: "Glass", systemImage: "drop.fill", color: .cyan),
        MaterialCategory(name: "Wood", systemImage: "leaf.fill", color: .brown),
        MaterialCategory(name: "Porcelain", systemImage: "circle.grid.3x3.fill", color: .gray),
        MaterialCategory(name: "Others", systemImage: "ellipsis.circle.fill", color: .purple)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Material Categories")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()

                    Divider()

                    // Categories Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(categories) { category in
                            Button {
                                selectedCategory = category
                                showPosts = true
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: category.systemImage)
                                        .font(.system(size: 24))
                                        .foregroundColor(category.color)
                                        .frame(width: 50, height: 50)
                                        .background(category.color.opacity(0.1))
                                        .clipShape(Circle())

                                    Text(category.name)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 10)
                .frame(width: 300)

                // Navigation to posts view
                if let selected = selectedCategory, showPosts {
                    NavigationLink(
                        destination: MaterialPostsView(category: selected),
                        isActive: $showPosts
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
        }
    }
}

struct DiscoveryView: View {
    @State private var selectedTab: DiscoveryTab = .explore
    @State private var showingMaterialMenu = false

    // ← your fetch state
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    enum DiscoveryTab { case follow, explore, nearby }

    var body: some View {
        NavigationView {
            ScrollView {
                // 1) HEADER
                VStack(alignment: .leading, spacing: 4) {
                    Text("Community")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Discover the meticulous inspirations from others!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // 2) TABS TOOLBAR
                HStack {
                    // … your three buttons for Follow / Explore / Nearby …
                    // (exactly as you had them)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)

                Divider()

                // 3) CONTENT AREA
                Group {
                    switch selectedTab {
                    case .follow:
                        Text("Follow Content")
                            .padding()

                    case .explore:
                        if isLoading {
                            ProgressView("Loading posts…")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        }
                        else if let msg = errorMessage {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                Text("Error loading posts")
                                    .font(.headline)
                                Text(msg)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        }
                        else {
                            LazyVStack(spacing: 16) {
                                ForEach(posts) { post in
                                    PostRow(post: post)
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                    case .nearby:
                        Text("Nearby Content")
                            .padding()
                    }
                }
                .animation(.default, value: isLoading) // optional
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingMaterialMenu) {
                MaterialMenuView(isPresented: $showingMaterialMenu)
            }
            .task {
                await loadPosts()
            }
        }
    }

    private func loadPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await NetworkService.shared.fetchCommunityPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct PostRow: View {
  let post: Post
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(post.title)
        .font(.headline)
      Text(post.content)
        .font(.body)
        .lineLimit(3)
      HStack {
        Text(post.author)
          .font(.caption)
        Spacer()
        Text(post.timestamp, style: .date)
          .font(.caption)
      }
    }
    .padding()
    .background(Color(.secondarySystemBackground))
    .cornerRadius(8)
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
            
            DiscoveryView()
                .tabItem {
                    Label("Discovery", systemImage: "safari.fill")
                }
            
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
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Camera settings are configured once in makeUIViewController
    }
    
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

// Add these new views before ContentView

struct PlantedTreesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userStats = UserStats()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<userStats.treesPlanted, id: \.self) { index in
                        PlantedTreeCard(treeIndex: index)
                    }
                }
                .padding()
            }
            .navigationTitle("My Forest")
            .background(Color(UIColor.systemGray6))
        }
    }
}

struct PlantedTreeCard: View {
    let treeIndex: Int
    @State private var showingTrackingView = false
    @State private var showingRewardView = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Tree Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
            }
            .padding(.top)
            
            // Tree Info
            Text("Tree #\(treeIndex + 1)")
                .font(.headline)
            
            Text("Planted on \(plantedDate)")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Action Buttons
            VStack(spacing: 8) {
                Button {
                    showingTrackingView = true
                } label: {
                    Text("Track the Growth")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                Button {
                    showingRewardView = true
                } label: {
                    Text("See your Reward")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingTrackingView) {
            TreeTrackingView(treeIndex: treeIndex)
        }
        .sheet(isPresented: $showingRewardView) {
            TreeRewardView(treeIndex: treeIndex)
        }
    }
    
    private var plantedDate: String {
        let date = Calendar.current.date(byAdding: .day, value: -treeIndex, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TreeTrackingView: View {
    let treeIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Tree Growth Tracking Coming Soon!")
                .navigationTitle("Track Growth")
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

struct TreeRewardView: View {
    let treeIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showingCertificate = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                
                if !showingCertificate {
                    // Celebration Animation
                    CelebrationView {
                        withAnimation {
                            showingCertificate = true
                        }
                    }
                } else {
                    // Certificate View
                    ScrollView {
                        VStack(spacing: 24) {
                            CertificateView(treeIndex: treeIndex)
                                .padding()
                            
                            // Action Buttons
                            VStack(spacing: 16) {
                                Button {
                                    showingShareSheet = true
                                } label: {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Certificate")
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                                
                                Button {
                                    generateAndSavePDF()
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.down.doc")
                                        Text("Download as PDF")
                                    }
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Tree Certificate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [generateCertificateImage()])
            }
        }
    }
    
    private func generateCertificateImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 600))
        return renderer.image { context in
            // Certificate rendering code here
            // This is a placeholder that creates a basic image
            let rect = CGRect(x: 0, y: 0, width: 800, height: 600)
            UIColor.white.setFill()
            context.fill(rect)
        }
    }
    
    private func generateAndSavePDF() {
        // PDF generation code will go here
        // For now, this is just a placeholder
    }
}

// Add these structs before CelebrationView
struct Firework: Identifiable {
    let id = UUID()
    var position: CGPoint
    var hue: Double
    var scale: CGFloat = 0.1
    var opacity: Double = 1.0
}

struct FireworkView: View {
    let hue: Double
    
    var body: some View {
        ZStack {
            // Inner sparkles
            ForEach(0..<8) { index in
                Rectangle()
                    .fill(Color(hue: hue, saturation: 1, brightness: 1))
                    .frame(width: 3, height: 12)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
            
            // Outer sparkles
            ForEach(0..<12) { index in
                Rectangle()
                    .fill(Color(hue: hue, saturation: 0.8, brightness: 1))
                    .frame(width: 2, height: 20)
                    .rotationEffect(.degrees(Double(index) * 30))
            }
            
            // Center burst
            Circle()
                .fill(Color.white)
                .frame(width: 6, height: 6)
                .blur(radius: 1)
        }
        .blur(radius: 0.5)
    }
}

struct CelebrationView: View {
    let onComplete: () -> Void
    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var fireworks: [Firework] = []
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Fireworks
            ForEach(fireworks) { firework in
                FireworkView(hue: firework.hue)
                    .position(firework.position)
                    .scaleEffect(firework.scale)
                    .opacity(firework.opacity)
            }
            
            // Original leaf celebration
            ForEach(0..<12) { index in
                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                    .rotationEffect(.degrees(Double(index) * 30 + rotation))
                    .offset(x: cos(Double(index) * .pi / 6) * 100,
                            y: sin(Double(index) * .pi / 6) * 100)
            }
            
            VStack(spacing: 20) {
                Image(systemName: "tree.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Congratulations!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("You've planted a tree!")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            // Start original animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1
                opacity = 1
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Start fireworks
            startFireworks()
            
            // Transition to certificate view after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                timer?.invalidate()
                onComplete()
            }
        }
    }
    
    private func startFireworks() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            // Create new firework
            let firework = Firework(
                position: CGPoint(
                    x: CGFloat.random(in: screenWidth * 0.2...screenWidth * 0.8),
                    y: CGFloat.random(in: screenHeight * 0.2...screenHeight * 0.7)
                ),
                hue: Double.random(in: 0...1)
            )
            
            fireworks.append(firework)
            
            // Animate the firework
            withAnimation(.easeOut(duration: 0.5)) {
                let index = fireworks.count - 1
                fireworks[index].scale = CGFloat.random(in: 0.5...1.0)
            }
            
            withAnimation(.easeIn(duration: 0.8).delay(0.1)) {
                let index = fireworks.count - 1
                fireworks[index].opacity = 0
            }
            
            // Remove old fireworks
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if !fireworks.isEmpty {
                    fireworks.removeFirst()
                }
            }
        }
    }
}

// Add CertificateView struct
struct CertificateView: View {
    let treeIndex: Int
    
    var body: some View {
        VStack(spacing: 24) {
            // Certificate Header
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Certificate of Achievement")
                .font(.title)
                .fontWeight(.bold)
            
            // Decorative Line
            Rectangle()
                .frame(height: 2)
                .frame(width: 100)
                .foregroundColor(.green)
            
            // Certificate Content
            VStack(spacing: 16) {
                Text("This certifies that")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("User") // Will be updated to use AccountManager when available
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("has successfully planted")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("Tree #\(treeIndex + 1)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("on")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(plantedDate)
                    .font(.title3)
                    .fontWeight(.medium)
            }
            
            // Signature Line
            HStack {
                VStack {
                    Rectangle()
                        .frame(height: 1)
                        .frame(width: 200)
                        .foregroundColor(.gray)
                    
                    Text("Releaf Team")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var plantedDate: String {
        let date = Calendar.current.date(byAdding: .day, value: -treeIndex, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// Update the StatusPopupView struct
struct StatusPopupView: View {
    let currentStatus: UserStatus
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Header
            VStack(spacing: 8) {
                Text("Achievement Levels")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Track your environmental impact")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // Status List
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(UserStatus.allCases), id: \.self) { status in
                        HStack(spacing: 16) {
                            // Status Icon with animated background
                            ZStack {
                                Circle()
                                    .fill(status.color.opacity(isStatusActive(status) ? 0.15 : 0.05))
                                    .frame(width: 48, height: 48)
                                
                                if isStatusActive(status) {
                                    Circle()
                                        .stroke(status.color.opacity(0.3), lineWidth: 2)
                                        .frame(width: 48, height: 48)
                                }
                                
                                Image(systemName: getStatusIcon(for: status))
                                    .font(.system(size: 22))
                                    .foregroundColor(isStatusActive(status) ? status.color : .gray.opacity(0.5))
                            }
                            
                            // Status Info
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Text(status.title)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(isStatusActive(status) ? .primary : .gray)
                                    
                                    if status == currentStatus {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.system(size: 16))
                                    }
                                }
                                
                                Text(getRequirementText(for: status))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Trees Badge
                            VStack(alignment: .center, spacing: 2) {
                                Text("\(status.rawValue * 20)")
                                    .font(.system(size: 16, weight: .bold))
                                Text("trees")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(isStatusActive(status) ? .white : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(status.color.opacity(isStatusActive(status) ? 1.0 : 0.2))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(status == currentStatus ? 
                                    status.color.opacity(0.1) : 
                                    Color(UIColor.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(status == currentStatus ? 
                                            status.color.opacity(0.3) : 
                                            Color.clear, 
                                            lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.65)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
        .transition(.move(edge: .bottom))
    }
    
    private func isStatusActive(_ status: UserStatus) -> Bool {
        status.rawValue <= currentStatus.rawValue
    }
    
    private func getRequirementText(for status: UserStatus) -> String {
        switch status {
        case .ecoAware:
            return "Begin your environmental journey"
        case .greenStarter:
            return "Plant 20 trees to become a Green Starter"
        case .sustainableSeeker:
            return "Plant 40 trees to become a Sustainable Seeker"
        case .ecoWarrior:
            return "Plant 60 trees to become an Eco Warrior"
        case .earthGuardian:
            return "Plant 80 trees to become an Earth Guardian"
        case .ecoChampion:
            return "Plant 100 trees to become an Eco Champion"
        }
    }
    
    private func getStatusIcon(for status: UserStatus) -> String {
        switch status {
        case .ecoAware:
            return "leaf.circle"
        case .greenStarter:
            return "leaf.fill"
        case .sustainableSeeker:
            return "leaf.arrow.triangle.circlepath"
        case .ecoWarrior:
            return "leaf.arrow.triangle.2.circlepath"
        case .earthGuardian:
            return "leaf.arrow.triangle.2.circlepath.fill"
        case .ecoChampion:
            return "crown.fill"
        }
    }
}

// Add TreeTypeSelectionView
struct TreeTypeSelectionView: View {
    @ObservedObject var viewModel: TreeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header with timer
                VStack(spacing: 16) {
                    Image(systemName: "timer")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Choose Your Tree Type")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("You have \(viewModel.formatTimeRemaining()) to select your tree type")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("If no selection is made, the default tree (Oak) will be chosen automatically.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top)
                
                // Tree types grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(viewModel.treeTypes) { tree in
                            Button {
                                viewModel.selectTreeType(tree)
                                dismiss()
                            } label: {
                                TreeTypeCard(tree: tree, isSelected: false)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Tree Planting Complete!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        // Select default tree
                        if let defaultTree = viewModel.treeTypes.first {
                            viewModel.selectTreeType(defaultTree)
                        }
                        dismiss()
                    }
                }
            }
        }
        .interactiveDismissDisabled() // Prevent swipe to dismiss
    }
}

struct TreeTypeCard: View {
    let tree: TreeType
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Beautiful tree preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.98, blue: 0.92),
                            Color(red: 0.88, green: 0.95, blue: 0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 80)
                
                getTreeShape(for: tree.name)
                    .scaleEffect(0.6)
                    .frame(height: 80)
            }
            
            // Header with tree name
            VStack(alignment: .leading, spacing: 4) {
                Text(tree.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(tree.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            // Key features
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(tree.features.prefix(2)), id: \.self) { feature in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 4, height: 4)
                        Text(feature)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Cost display
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 12))
                    Text("\(tree.waterdropsCost)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
            }
        }
        .padding(12)
        .frame(height: 220)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.green : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    // Helper function to get the appropriate tree shape for preview
    private func getTreeShape(for treeName: String) -> some View {
        let treeType: TreeShape.TreeType
        let size = CGSize(width: 60, height: 60)
        
        switch treeName.lowercased() {
        case "oak":
            treeType = .oak
        case "pine":
            treeType = .pine
        case "maple":
            treeType = .maple
        case "cherry":
            treeType = .cherry
        case "willow":
            treeType = .willow
        case "birch":
            treeType = .birch
        case "redwood":
            treeType = .redwood
        case "palm":
            treeType = .palm
        default:
            treeType = .defaultTree
        }
        
        return TreeShape.create(treeType, size: size)
    }
}

// Add TreeWaterdropsView
struct TreeWaterdropsView: View {
    let tree: TreeType
    @ObservedObject var viewModel: TreeViewModel
    @Binding var isPresented: Bool
    @State private var showingProcessing = false
    @State private var showingSuccess = false
    @State private var showingError: Bool = false
    @State private var showingInsufficientWaterdrops = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Tree Preview
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: tree.icon)
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                        }
                        
                        Text(tree.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(tree.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Waterdrops Cost Section
                    VStack(spacing: 8) {
                        Text("Cost")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("\(tree.waterdropsCost)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical)
                    
                    // Current Waterdrops
                    VStack(spacing: 8) {
                        Text("Your Waterdrops")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("\(viewModel.waterDrops)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Confirm Button
                    Button {
                        if viewModel.waterDrops >= tree.waterdropsCost {
                            processTransaction()
                        } else {
                            showingInsufficientWaterdrops = true
                        }
                    } label: {
                        HStack {
                            Text("Plant Tree")
                            Text("\(tree.waterdropsCost) 💧")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(16)
                        .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding()
                }
            }
            .navigationTitle("Plant Tree")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .overlay {
                if showingProcessing {
                    ProcessingOverlay()
                }
            }
            .alert("Tree Planted!", isPresented: $showingSuccess) {
                Button("OK") {
                    viewModel.selectedTree = tree
                    isPresented = false
                }
            }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("An error occurred while planting the tree. Please try again.")
        }
            .alert("Insufficient Waterdrops", isPresented: $showingInsufficientWaterdrops) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You need \(tree.waterdropsCost) waterdrops to plant this tree. You currently have \(viewModel.waterDrops) waterdrops.")
            }
        }
    }
    
    private func processTransaction() {
        showingProcessing = true
        
        // Simulate transaction processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if UserStats.shared.useWaterDrops(tree.waterdropsCost) {
                showingSuccess = true
            } else {
                showingError = true
            }
            showingProcessing = false
        }
    }
}

// Add ProcessingOverlay
struct ProcessingOverlay: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.green, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
                
                Text("Processing Payment...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color(UIColor.systemBackground).opacity(0.9))
            .cornerRadius(20)
        }
    }
}

// Add Activity enum before FloatingBubbleView
enum Activity {
    case post
    case search
    case donation(amount: Int)
}

struct FloatingBubbleView: View {
    let activity: Activity
    let waterdrops: Int
    let onTap: () -> Void
    @State private var isAnimating = false
    @State private var showingReward = false
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                onTap()
                showingReward = true
            }
        } label: {
            ZStack {
                // Bubble background
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.2),
                            Color.green.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.green.opacity(0.2), radius: 5, x: 0, y: 2)
                
                VStack(spacing: 2) {
                    // Activity icon
                    Image(systemName: getActivityIcon())
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                    
                    // Waterdrops label
                    Text("+\(waterdrops)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                }
                
                // Animated reward popup
                if showingReward {
                    Text("+\(waterdrops)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                        .offset(y: -40)
                        .transition(.scale.combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showingReward = false
                                }
                            }
                        }
                }
            }
        }
        .buttonStyle(.plain)
        .offset(y: isAnimating ? -10 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private func getActivityIcon() -> String {
        switch activity {
        case .post: return "square.and.pencil"
        case .search: return "magnifyingglass"
        case .donation: return "heart.fill"
        }
    }
}

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthenticationService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingPasswordMismatch = false
    @State private var isSecured = true
    @State private var isConfirmSecured = true
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
                ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Create Your Account")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Choose how you'd like to sign up")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    // Real Authentication Methods
                    VStack(spacing: 16) {
                        // Apple Sign In
                        SignInWithAppleButton(.signUp,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                Task { await performAppleSignUp(result) }
                            }
                        )
                        .frame(height: 50)
                        .cornerRadius(10)
                        
                        // Google Sign In
                        Button {
                            Task { await performGoogleSignUp() }
                        } label: {
                            HStack {
                                Image(systemName: "globe") // Replace with actual Google logo if available
                                    .frame(width: 24, height: 24)
                                Text("Continue with Google")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                }
                .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .disabled(isLoading)
                        
                        // Email/Password Sign Up
                        Button {
                            Task { await performEmailSignUp() }
                        } label: {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24, height: 24)
                                Text("Continue with Email")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal)
                    
                    // Email/Password Form (if email option is selected)
                    if showEmailForm {
                        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .foregroundColor(.gray)
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                            }
                            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .foregroundColor(.gray)
                HStack {
                    if isSecured {
                        SecureField("Create password", text: $password)
                    } else {
                        TextField("Create password", text: $password)
                    }
                    Button {
                        isSecured.toggle()
                    } label: {
                        Image(systemName: isSecured ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Must be at least 6 characters")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .foregroundColor(.gray)
                HStack {
                    if isConfirmSecured {
                        SecureField("Confirm password", text: $confirmPassword)
                    } else {
                        TextField("Confirm password", text: $confirmPassword)
                    }
                    Button {
                        isConfirmSecured.toggle()
                    } label: {
                        Image(systemName: isConfirmSecured ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
            Button {
                                Task { await performEmailSignUp() }
            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                } else {
                                        Text("Create Account")
                                            .fontWeight(.bold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canCreateAccount ? Color.green : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(12)
                            }
                            .disabled(!canCreateAccount || isLoading)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                
                Spacer()
                
                                    // Continue without account option
                    VStack(spacing: 16) {
                        Button {
                            AccountManager.shared.continueAsGuest()
                            dismiss()
                        } label: {
                            Text("Continue without an account")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Text("Limited features available without an account")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.vertical, 16)
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("By continuing, you agree to our")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                // Handle terms tap
                            }
                            .font(.footnote)
                            
                            Text("and")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            Button("Privacy Policy") {
                                // Handle privacy tap
                            }
                            .font(.footnote)
                        }
                    }
                    .padding(.bottom, 32)
            }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                dismiss()
                    }
                }
            }
        }
        .alert("Authentication Error", isPresented: .constant(authService.errorMessage != nil)) {
            Button("OK") {
                authService.errorMessage = nil
            }
        } message: {
            Text(authService.errorMessage ?? "")
        }
        .alert("Password Mismatch", isPresented: $showingPasswordMismatch) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please make sure your passwords match.")
        }
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    @State private var showEmailForm: Bool = false
    
    private var canCreateAccount: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let isValidEmail = emailPredicate.evaluate(with: email)
        return !email.isEmpty && isValidEmail && password.count >= 6 && confirmPassword == password && showEmailForm
    }
    
    private func performAppleSignUp(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        do {
            let authorization = try result.get()
            try await authService.handleAppleSignIn(authorization: authorization)
            print("✅ Apple Sign In successful")
        } catch {
            print("❌ Apple Sign In error: \(error.localizedDescription)")
            await MainActor.run {
                authService.errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
    
    private func performGoogleSignUp() async {
        isLoading = true
        do {
            try await authService.signInWithGoogle()
            print("✅ Google Sign In successful")
        } catch {
            print("❌ Google Sign In error: \(error.localizedDescription)")
            await MainActor.run {
                authService.errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
    
    private func performEmailSignUp() async {
        if !showEmailForm {
            showEmailForm = true
            return
        }
        
        guard password == confirmPassword else {
            showingPasswordMismatch = true
            return
        }
        
        isLoading = true
        do {
            try await authService.signUp(email: email, password: password)
            print("✅ Email Sign Up successful")
        } catch {
            print("❌ Email Sign Up error: \(error.localizedDescription)")
            await MainActor.run {
                authService.errorMessage = error.localizedDescription
            }
        }
        isLoading = false
    }
    

}



struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Terms of Service (\"Terms\")")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Group {
                    Text("Our Terms of Service were last updated on April 11, 2025")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Thank you for choosing to be part of our community at Releaf, a mobile searching based application that provides recycling inspirations and methods.")
                    
                    Text("Please read these terms and conditions carefully before using Our Service.")
                    
                    Text("Interpretation and Definitions")
                        .font(.headline)
                    
                    Text("Interpretation")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.")
                    
                    Text("Definitions")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("For the purposes of these Terms of Service:")
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DefinitionItem(term: "\"Account\"", definition: "means a unique account created for You to access our Service or parts of our Service.")
                        DefinitionItem(term: "\"Company\"", definition: "(referred to as either \"the Company\", \"We\", \"Us\" or \"Our\" in this Agreement) refers to Releaf.")
                        DefinitionItem(term: "\"Country\"", definition: "refers to United States of America.")
                        DefinitionItem(term: "\"Content\"", definition: "refers to content such as text, images, or other information that can be posted, uploaded to or otherwise made available by You, regardless of the form of that content.")
                        DefinitionItem(term: "\"Device\"", definition: "means any device that can access the Service such as a cell phone or a digital tablet.")
                        DefinitionItem(term: "\"Feedback\"", definition: "means feedback, innovations or suggestions sent by You regarding the attributes, performance or features of our Service.")
                        DefinitionItem(term: "\"Service\"", definition: "refers to the Application.")
                        DefinitionItem(term: "\"Terms of Service\"", definition: "(also referred as \"Terms\") mean these Terms of Service that form the entire agreement between You and the Company regarding the use of the Service.")
                        DefinitionItem(term: "\"Third-party Social Media Service\"", definition: "means any services or content (including data, information, products or services) provided by a third-party that may be displayed, included or made available by the Service.")
                        DefinitionItem(term: "\"Application\"", definition: "refers to Releaf, accessible from the Apple Store.")
                        DefinitionItem(term: "\"You\"", definition: "means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.")
                    }
                    
                    Text("Acknowledgment")
                        .font(.headline)
                    Text("These are the Terms of Service governing the use of this Service and the agreement that operates between You and the Company. These Terms of Service set out the rights and obligations of all users regarding the use of the Service.")
                    
                    Text("Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms of Service. These Terms of Service apply to all visitors, users and others who access or use the Service.")
                    
                    Text("By accessing or using the Service You agree to be bound by these Terms of Service. If You disagree with any part of these Terms of Service then You may not access the Service.")
                    
                    Text("Your access to and use of the Service is also conditioned on Your acceptance of and compliance with the Privacy Policy of the Company. Our Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your personal information when You use the Application or the Website and tells You about Your privacy rights and how the law protects You. Please read Our Privacy Policy carefully before using Our Service.")
                    
                    Text("User Accounts")
                        .font(.headline)
                    Text("When You create an account with Us, You must provide Us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of Your account on Our Service.")
                    
                    Text("You are responsible for safeguarding the password that You use to access the Service and for any activities or actions under Your password, whether Your password is with Our Service or a Third-Party Social Media Service.")
                    
                    Text("You agree not to disclose Your password to any third party. You must notify Us immediately upon becoming aware of any breach of security or unauthorized use of Your account.")
                    
                    Text("You may not use as a username the name of another person or entity or that is not lawfully available for use, a name or trademark that is subject to any rights of another person or entity other than You without appropriate authorization, or a name that is otherwise offensive, vulgar or obscene.")
                    
                    Text("Content")
                        .font(.headline)
                    
                    Text("Your Right to Post Content")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Our Service allows You to post Content. You are responsible for the Content that You post to the Service, including its legality, reliability, and appropriateness.")
                    
                    Text("By posting Content to the Service, You grant Us the right and license to use, modify, publicly perform, publicly display, reproduce, and distribute such Content on and through the Service. You retain any and all of Your rights to any Content You submit, post or display on or through the Service and You are responsible for protecting those rights. You agree that this license includes the right for Us to make Your Content available to other users of the Service, who may also use Your Content subject to these Terms.")
                    
                    Text("You represent and warrant that: (i) the Content is Yours (You own it) or You have the right to use it and grant Us the rights and license as provided in these Terms, and (ii) the posting of Your Content on or through the Service does not violate the privacy rights, publicity rights, copyrights, contract rights or any other rights of any person.")
                    
                    Text("Content Restrictions")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("The Company is not responsible for the content of the Service's users. You expressly understand and agree that You are solely responsible for the Content and for all activity that occurs under your account, whether done so by You or any third person using Your account.")
                    
                    Text("You may not transmit any Content that is unlawful, offensive, upsetting, intended to disgust, threatening, libelous, defamatory, obscene or otherwise objectionable. Examples of such objectionable Content include, but are not limited to, the following:")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Unlawful or promoting unlawful activity.")
                        BulletPoint(text: "Defamatory, discriminatory, or mean-spirited content, including references or commentary about religion, race, sexual orientation, gender, national/ethnic origin, or other targeted groups.")
                        BulletPoint(text: "Spam, machine – or randomly – generated, constituting unauthorized or unsolicited advertising, chain letters, any other form of unauthorized solicitation, or any form of lottery or gambling.")
                        BulletPoint(text: "Containing or installing any viruses, worms, malware, trojan horses, or other content that is designed or intended to disrupt, damage, or limit the functioning of any software, hardware or telecommunications equipment or to damage or obtain unauthorized access to any data or other information of a third person.")
                        BulletPoint(text: "Infringing on any proprietary rights of any party, including patent, trademark, trade secret, copyright, right of publicity or other rights.")
                        BulletPoint(text: "Impersonating any person or entity including the Company and its employees or representatives.")
                        BulletPoint(text: "Violating the privacy of any third person.")
                        BulletPoint(text: "False information and features.")
                    }
                    
                    Text("The Company reserves the right, but not the obligation, to, in its sole discretion, determine whether or not any Content is appropriate and complies with these Terms, refuse or remove this Content. The Company further reserves the right to make formatting and edits and change the manner of any Content. The Company can also limit or revoke the use of the Service if You post such objectionable Content. As the Company cannot control all content posted by users and/or third parties on the Service, you agree to use the Service at your own risk. You understand that by using the Service You may be exposed to content that You may find offensive, indecent, incorrect or objectionable, and You agree that under no circumstances will the Company be liable in any way for any content, including any errors or omissions in any content, or any loss or damage of any kind incurred as a result of your use of any content.")
                    
                    Text("Content Backups")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Although regular backups of Content are performed, the Company does not guarantee there will be no loss or corruption of data.")
                    
                    Text("Corrupt or invalid backup points may be caused by, without limitation, Content that is corrupted prior to being backed up or that changes during the time a backup is performed.")
                    
                    Text("The Company will provide support and attempt to troubleshoot any known or discovered issues that may affect the backups of Content. But You acknowledge that the Company has no liability related to the integrity of Content or the failure to successfully restore Content to a usable state.")
                    
                    Text("You agree to maintain a complete and accurate copy of any Content in a location independent of the Service.")
                    
                    Text("The Donation Service")
                        .font(.headline)
                    Text("We will honour your giving and generosity by using your donation effectively and we endeavour to channel your donation to a charitable cause. Once you confirm to us through the Website that you wish to proceed with your donation your transaction will be processed through our payment services provider, Apple Pay. By confirming that you wish to proceed with your donation you authorise Apple Pay to request funds from your credit or debit card provider. Apple Pay will only process your donation in US dollars.")
                    
                    Text("Payment via Apple Pay")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Apple Pay as the Sole Payment Method")
                            .fontWeight(.semibold)
                        Text("All monetary donations within the App are processed exclusively through Apple Pay. By making a donation, you agree to abide by Apple's terms and conditions relating to Apple Pay. For more information, please refer to Apple Pay Terms.")
                        
                        Text("Voluntary and Non-Refundable")
                            .fontWeight(.semibold)
                        Text("Donations are completely voluntary. Once a donation has been submitted via Apple Pay, it is non-refundable unless required by applicable law. If you have questions regarding a donation, please contact our support team at releaf330@gmail.com.")
                        
                        Text("Processing and Receipt")
                            .fontWeight(.semibold)
                        Text("Upon successful transaction via Apple Pay, you may receive a receipt or confirmation notice. If you do not receive a confirmation or encounter any issues during the transaction, please reach out to releaf330@gmail.com.")
                        
                        Text("Use of Funds")
                            .fontWeight(.semibold)
                        Text("All donations made through Apple Pay will be used for the purpose described within the App (e.g., operational costs, charitable contributions). If our intended use changes, we will notify you and update these Terms accordingly.")
                        
                        Text("Disclaimer of Liability")
                            .fontWeight(.semibold)
                        Text("Releaf is not liable for any issues, claims, or disputes arising from Apple Pay transactions, including payment failures, unauthorized transactions, or data breaches on Apple's side. Any disputes regarding the processing of donations via Apple Pay must be directed to Apple or your financial institution.")
                        
                        Text("Legal and Tax Implications")
                            .fontWeight(.semibold)
                        Text("Depending on your jurisdiction and our legal status, your donation may or may not be tax-deductible. You are solely responsible for understanding and fulfilling any tax obligations related to your donation.")
                        
                        Text("Updates to This Section")
                            .fontWeight(.semibold)
                        Text("We reserve the right to modify this Donations section at any time. If we make changes, we will notify you by updating the \"Last Modified\" date at the top of these Terms or through other communication channels.")
                    }
                    
                    Text("Copyright Policy")
                        .font(.headline)
                    
                    Text("Intellectual Property Infringement")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("We respect the intellectual property rights of others. It is Our policy to respond to any claim that Content posted on the Service infringes a copyright or other intellectual property infringement of any person.")
                    
                    Text("If You are a copyright owner, or authorized on behalf of one, and You believe that the copyrighted work has been copied in a way that constitutes copyright infringement that is taking place through the Service, You must submit Your notice in writing to the attention of our copyright agent via email (releaf330@gmail.com) and include in Your notice a detailed description of the alleged infringement.")
                    
                    Text("You may be held accountable for damages (including costs and attorneys' fees) for misrepresenting that any Content is infringing Your copyright.")
                    
                    Text("DMCA Notice and DMCA Procedure for Copyright Infringement Claims")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("You may submit a notification pursuant to the Digital Millennium Copyright Act (DMCA) by providing our Copyright Agent with the following information in writing (see 17 U.S.C 512(c)(3) for further detail):")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "An electronic or physical signature of the person authorized to act on behalf of the owner of the copyright's interest.")
                        BulletPoint(text: "A description of the copyrighted work that You claim has been infringed, including the URL (i.e., web page address) of the location where the copyrighted work exists or a copy of the copyrighted work.")
                        BulletPoint(text: "Identification of the URL or other specific location on the Service where the material that You claim is infringing is located.")
                        BulletPoint(text: "Your address, telephone number, and email address.")
                        BulletPoint(text: "A statement by You that You have a good faith belief that the disputed use is not authorized by the copyright owner, its agent, or the law.")
                        BulletPoint(text: "A statement by You, made under penalty of perjury, that the above information in Your notice is accurate and that You are the copyright owner or authorized to act on the copyright owner's behalf.")
                    }
                    
                    Text("You can contact our copyright agent via email (releaf330@gmail.com). Upon receipt of a notification, the Company will take whatever action, in its sole discretion, it deems appropriate, including removal of the challenged content from the Service.")
                    
                    Text("Intellectual Property")
                        .font(.headline)
                    Text("The Service and its original content (excluding Content provided by You or other users), features and functionality are and will remain the exclusive property of the Company and its licensors.")
                    
                    Text("The Service is protected by copyright, trademark, and other laws of both the Country and foreign countries.")
                    
                    Text("Our trademarks and trade dress may not be used in connection with any product or service without the prior written consent of the Company.")
                    
                    Text("Your Feedback to Us")
                        .font(.headline)
                    Text("You assign all rights, title and interest in any Feedback You provide the Company. If for any reason such assignment is ineffective, You agree to grant the Company a non-exclusive, perpetual, irrevocable, royalty free, worldwide right and license to use, reproduce, disclose, sub-license, distribute, modify and exploit such Feedback without restriction.")
                    
                    Text("Termination")
                        .font(.headline)
                    Text("We may terminate or suspend Your Account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if You breach these Terms of Service.")
                    
                    Text("Upon termination, Your right to use the Service will cease immediately. If You wish to terminate Your Account, You may simply discontinue using the Service.")
                    
                    Text("\"AS IS\" and \"AS AVAILABLE\" Disclaimer")
                        .font(.headline)
                    Text("The Service is provided to You \"AS IS\" and \"AS AVAILABLE\" and with all faults and defects without warranty of any kind. To the maximum extent permitted under applicable law, the Company, on its own behalf, expressly disclaims all warranties, whether express, implied, statutory or otherwise, with respect to the Service, including all implied warranties of title and non-infringement, and warranties that may arise out of usage. Without limitation to the foregoing, the Company provides no warranty or undertaking, and makes no representation of any kind that the Service will meet Your requirements, achieve any intended results, be compatible or work with any other software, applications, systems or services, operate without interruption, meet any performance or reliability standards or be error free or that any errors or defects can or will be corrected.")
                    
                    Text("Without limiting the foregoing, neither the Company nor any of the company's provider makes any representation or warranty of any kind, express or implied: (i) as to the operation or availability of the Service, or the information, content, and materials or products included thereon; (ii) that the Service will be uninterrupted or error-free; (iii) as to the accuracy, reliability, or currency of any information or content provided through the Service; or (iv) that the Service, its servers, the content, or e-mails sent from or on behalf of the Company are free of viruses, scripts, trojan horses, worms, malware, timebombs or other harmful components.")
                    
                    Text("Some jurisdictions do not allow the exclusion of certain types of warranties or limitations on applicable statutory rights of a consumer, so some or all of the above exclusions and limitations may not apply to You. But in such a case the exclusions and limitations set forth in this section shall be applied to the greatest extent enforceable under applicable law.")
                    
                    Text("Governing Law")
                        .font(.headline)
                    Text("The laws of the Country, excluding its conflicts of law rules, shall govern this Terms and Your use of the Service. Your use of the Application may also be subject to other local, state, national, or international laws.")
                    
                    Text("Disputes Resolution")
                        .font(.headline)
                    Text("If You have any concern or dispute about the Service, You agree to first try to resolve the dispute informally by contacting the Company.")
                    
                    Text("Severability and Waiver")
                        .font(.headline)
                    
                    Text("Severability")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("If any provision of these Terms is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law and the remaining provisions will continue in full force and effect.")
                    
                    Text("Waiver")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Except as provided herein, the failure to exercise a right or to require performance of an obligation under these Terms shall not effect a party's ability to exercise such right or require such performance at any time thereafter nor shall the waiver of a breach constitute a waiver of any subsequent breach.")
                    
                    Text("Changes to These Terms of Service")
                        .font(.headline)
                    Text("We reserve the right, at Our sole discretion, to modify or replace these Terms at any time. If a revision is material We will make reasonable efforts to provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at Our sole discretion.")
                    
                    Text("By continuing to access or use Our Service after those revisions become effective, You agree to be bound by the revised terms. If You do not agree to the new terms, in whole or in part, please stop using the application and the Service.")
                    
                    Text("Contact Us")
                        .font(.headline)
                    Text("If you have any questions about these Terms of Service, You can contact us:")
                    Text("By sending us an email: releaf330@gmail.com")
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DefinitionItem: View {
    let term: String
    let definition: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(term)
                .fontWeight(.semibold)
            Text(definition)
                .foregroundColor(.secondary)
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .fontWeight(.bold)
            Text(text)
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = URL(string: "https://releaf-2o3sj.ondigitalocean.app")!
    
    // MARK: - Community Posts with proper error handling
    func fetchCommunityPosts() async throws -> [Post] {
        let postsURL = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("posts")
            .appendingPathComponent("posts/")
        
        let (data, response) = try await URLSession.shared.data(from: postsURL)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("🔍 Status Code:", http.statusCode)
        print("🔍 Body:", String(data: data, encoding: .utf8) ?? "<not utf8>")
        
        guard http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Try to decode as paginated response first, then as array
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // First try paginated format (current backend)
        if let paginatedResponse = try? decoder.decode(PaginatedResponse<Post>.self, from: data) {
            return paginatedResponse.results
        }
        
        // If that fails, try direct array format (iOS-optimized endpoints)
        if let directArray = try? decoder.decode([Post].self, from: data) {
            return directArray
        }
        
        // If both fail, return empty array
        print("⚠️ Could not decode posts response, returning empty array")
        return []
    }
    
    func createPost(title: String, content: String, imageData: Data?, author: String, authorId: String, tags: [String], timestamp: Date) async throws {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("posts")
            .appendingPathComponent("posts/")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var payload: [String: Any] = [
            "title": title,
            "content": content,
            "author": author,
            "authorId": authorId,
            "tags": tags,
            "timestamp": ISO8601DateFormatter().string(from: timestamp)
        ]
        
        if let imageData = imageData {
            payload["imageData"] = imageData.base64EncodedString()
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            let msg = String(data: data, encoding: .utf8) ?? "no body"
            throw NSError(domain: "CreatePost", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create post: \(msg)"])
        }
    }
    
    // MARK: - Materials with better error handling
    func fetchMaterialPosts(category: String) async throws -> [MaterialPost] {
        guard var comps = URLComponents(string: "\(baseURL)/api/materials") else {
            throw URLError(.badURL)
        }
        comps.queryItems = [
            URLQueryItem(name: "category", value: category)
        ]
        guard let url = comps.url else {
            throw URLError(.badURL)
        }

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Handle both array and paginated formats
        if let paginatedResponse = try? decoder.decode(PaginatedResponse<MaterialPost>.self, from: data) {
            return paginatedResponse.results
        }
        
        if let directArray = try? decoder.decode([MaterialPost].self, from: data) {
            return directArray
        }
        
        // If response format is different, return empty array
        print("⚠️ Could not decode materials response, returning empty array")
        return []
    }
    
    // MARK: - Map Locations with error handling
    func fetchMapLocations() async throws -> [MapLocationData] {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("map")
            .appendingPathComponent("locations/")
        
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        print("🗺️ Map locations response:", String(data: data, encoding: .utf8) ?? "<not utf8>")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Try direct array first
        if let directArray = try? decoder.decode([MapLocationData].self, from: data) {
            return directArray
        }
        
        // If that fails, check if it's an error response with empty locations
        if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let locations = errorResponse["locations"] as? [Any] {
            return [] // Return empty array for now
        }
        
        // If all else fails, return empty array
        print("⚠️ Could not decode map locations response, returning empty array")
        return []
    }
    
    // MARK: - Rest of your methods remain the same
    func recordTreePlanting(userId: String, treeType: String, location: (latitude: Double, longitude: Double)?) async throws {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("trees")
            .appendingPathComponent("plant/")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var payload: [String: Any] = [
            "userId": userId,
            "treeType": treeType,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let location = location {
            payload["latitude"] = location.latitude
            payload["longitude"] = location.longitude
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func recordDonation(userId: String, amount: Double, currency: String, paymentMethod: String) async throws {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("donations")
            .appendingPathComponent("record/")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "userId": userId,
            "amount": amount,
            "currency": currency,
            "paymentMethod": paymentMethod,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "status": "completed"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchDonationHistory(userId: String) async throws -> [DonationRecord] {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("donations")
            .appendingPathComponent("history/")
            .appendingPathComponent(userId)
        
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Handle both array and paginated formats
        if let paginatedResponse = try? decoder.decode(PaginatedResponse<DonationRecord>.self, from: data) {
            return paginatedResponse.results
        }
        
        if let directArray = try? decoder.decode([DonationRecord].self, from: data) {
            return directArray
        }
        
        return []
    }
}

// MARK: - Helper struct for paginated responses
struct PaginatedResponse<T: Codable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}
// Add MapLocationData model
struct MapLocationData: Codable, Identifiable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let type: String // "user" or "planter"
    let timestamp: Date
}
struct CommunityPostsGrid: View {
    @State private var showingLoginAlert = false
    @State private var showingCreateAccount = false
    @State private var communityPosts: [Post] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Community")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Discover the meticulous inspirations from others!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            if AccountManager.shared.isGuestMode {
                // Guest mode - show posts but explain limitations
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = error {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text("Error loading posts")
                                .font(.headline)
                            Text(error.localizedDescription)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            Button("Try Again") {
                                Task {
                                    await fetchPosts()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else if communityPosts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "rectangle.stack.person.crop")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No posts yet")
                                .font(.headline)
                            Text("Create an account to share your sustainability journey!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    } else {
                        // Show posts for guest users
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ],
                            spacing: 16
                        ) {
                            ForEach(communityPosts.prefix(4)) { post in
                                RelatedPostCard(post: post)
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Guest limitation message
                        VStack(spacing: 8) {
                            Text("🌱 Guest Preview")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("Create an account to post, like, and comment")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                    }
                }
            } else if !AccountManager.shared.isLoggedIn {
                // Not logged in view
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Sign in to Track Searches")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Create an account to save your search history and earn rewards")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        showingCreateAccount = true
                    } label: {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 160)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(UIColor.systemGray6).opacity(0.5))
                .cornerRadius(16)
                .padding(.horizontal, 24)
            } else {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("Error loading posts")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await fetchPosts()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if communityPosts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "rectangle.stack.person.crop")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No posts yet")
                            .font(.headline)
                        Text("Be the first to share your sustainability journey!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    // Latest community posts in 2x2 grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(communityPosts.prefix(4)) { post in
                            RelatedPostCard(post: post)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .task {
            if AccountManager.shared.hasAnyAccess {
                await fetchPosts()
            }
        }
        .sheet(isPresented: $showingCreateAccount) {
            CreateAccountView()
        }
        .alert("Create Account", isPresented: $showingLoginAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Create Account") {
                showingCreateAccount = true
            }
        } message: {
            Text("Create an account to join our sustainable community!")
        }
    }
    
    private func fetchPosts() async {
        isLoading = true
        error = nil
        
        do {
            communityPosts = try await NetworkService.shared.fetchCommunityPosts()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

struct AllPostsView: View {
    @Environment(\.dismiss) private var dismiss
    let posts: [Post]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(posts) { post in
                        RelatedPostCard(post: post)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Community Posts")
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


struct MaterialPost: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let tags: [String]
    let imageURL: URL    // assume your API returns a URL string
}

// MARK: - MaterialPostsView
struct MaterialPostsView: View {
  let category: MaterialCategory    // e.g. an enum with .name and .label

  @State private var featured:    [MaterialPost] = []
  @State private var collection:  [MaterialPost] = []
  @State private var isLoading = false
  @State private var errorMessage: String?
  
  var body: some View {
    ZStack {
      ScrollView {
        VStack(spacing: 0) {
          headerSection
          section(title: "Featured",    posts: featured,   height: 220)
          section(title: "Collections", posts: collection, height: nil)
        }
      }
      
      // Overlays for loading / error
      if isLoading {
        ProgressView("Loading \(category.name)…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color.black.opacity(0.4))
      }
      if let err = errorMessage {
        VStack {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.largeTitle).foregroundColor(.red)
          Text(err).multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
      }
    }
    .navigationTitle(category.name)
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await loadMaterialPosts()
    }
  }


  private var headerSection: some View {
    ZStack(alignment: .bottomLeading) {
      Image("placeholder_header")   // you can also download a real URL if you prefer
        .resizable().scaledToFill().frame(height: 260).clipped()
      LinearGradient(
        gradient: Gradient(colors: [ .clear, .black.opacity(0.7) ]),
        startPoint: .center, endPoint: .bottom
      )
      .frame(height: 120)
      VStack(alignment: .leading, spacing: 8) {
        Text("A BOT-anist Adventure")
          .font(.title).bold().foregroundColor(.white)
        Text("An awe‑inspiring tale…")
          .font(.subheadline).foregroundColor(.white.opacity(0.9)).lineLimit(3)
        Button("Details") { /*…*/ }
          .padding(.horizontal, 18).padding(.vertical, 8)
          .background(Color.white.opacity(0.15)).foregroundColor(.white)
          .cornerRadius(8)
      }
      .padding(24)
    }
  }

  private func section(title: String, posts: [MaterialPost], height: CGFloat?) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.title2).bold()
        .padding(.top, 24).padding(.horizontal, 16)

      if let height = height {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            ForEach(posts) { post in
              MaterialPostCard(post: post)
                .frame(width: height * 0.9, height: height)
            }
          }
          .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
      } else {
        LazyVGrid(
          columns: [ GridItem(.flexible()), GridItem(.flexible()) ],
          spacing: 16
        ) {
          ForEach(posts) { post in
            MaterialPostCard(post: post)
          }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
      }
    }
  }

  // MARK: – Data loading

  private func loadMaterialPosts() async {
    isLoading = true
    errorMessage = nil

    do {
      // Fetch _all_ posts for this category...
      let all = try await NetworkService.shared.fetchMaterialPosts(category: category.name)
      // Then split however you like:
      featured   = Array(all.prefix(3))         // top 3 as featured
      collection = Array(all.dropFirst(3))      // the rest as collection
    }
    catch {
      errorMessage = error.localizedDescription
    }

    isLoading = false
  }
}

struct MaterialPostCard: View {
    let post: MaterialPost
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
          // replaces the old `Image(post.imageName)`
          AsyncImage(url: post.imageURL) { phase in
            switch phase {
            case .empty:
              Color.gray.opacity(0.2)
            case .success(let img):
              img.resizable().scaledToFill()
            case .failure:
              Image(systemName: "photo")
                .resizable().scaledToFit().padding()
            @unknown default:
              EmptyView()
            }
          }
          .frame(height: 120)
          .clipped()
            VStack(alignment: .leading, spacing: 4) {
                Text("2024 | NR | 01:06")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(post.subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                HStack {
                    ForEach(post.tags, id: \ .self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.15))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// Update MaterialMenuView to support navigation

// MARK: - Help & Support Feedback Model
struct FeedbackItem: Identifiable, Codable {
    let id: UUID
    let type: String
    let message: String
    let createdAt: Date
}

// MARK: - Feedback Networking
extension NetworkService {
    // MARK: - Feedback (iOS-Compatible Endpoints)
    static let feedbackBaseURL = URL(string: "https://releaf-2o3sj.ondigitalocean.app/api/ios/feedback")!
    
    /// Fetch feedback as simple array (iOS-compatible)
    static func fetchFeedback() async throws -> [FeedbackItem] {
        let (data, resp) = try await URLSession.shared.data(from: feedbackBaseURL)
        
        // Debug logging
        print("🔍 Feedback Status Code:", (resp as? HTTPURLResponse)?.statusCode ?? -1)
        print("🔍 Feedback Response Body:", String(data: data, encoding: .utf8) ?? "<not utf8>")
        
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "FeedbackFetch", code: statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Failed to fetch feedback: \(errorMsg)"
            ])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([FeedbackItem].self, from: data)
    }
    
    /// Submit feedback (works for both authenticated and anonymous users)
    static func postFeedback(type: String, message: String) async throws {
        var req = URLRequest(url: feedbackBaseURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["type": type, "message": message]
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // Debug logging
        print("🔍 Submit Feedback Status:", (resp as? HTTPURLResponse)?.statusCode ?? -1)
        print("🔍 Submit Response:", String(data: data, encoding: .utf8) ?? "<not utf8>")
        
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "FeedbackSubmit", code: statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Failed to submit feedback: \(errorMsg)"
            ])
        }
    }
    
    // MARK: - User Profile & Stats
    
    /// PUT /api/accounts/profile/ - Update user profile
    func updateUserProfile(token: String, profileData: UserProfileUpdate) async throws {
        let url = baseURL.appendingPathComponent("api/accounts/profile/")
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        req.httpBody = try encoder.encode(profileData)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // Debug logging
        print("🔍 Profile Update Status:", (resp as? HTTPURLResponse)?.statusCode ?? -1)
        print("🔍 Profile Update Response:", String(data: data, encoding: .utf8) ?? "<not utf8>")
        
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ProfileUpdate", code: statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update profile: \(errorMsg)"
            ])
        }
    }
    
    /// POST /api/accounts/stats/update/ - Sync user stats
    func syncUserStats(token: String, stats: UserStatsUpdate) async throws {
        let url = baseURL.appendingPathComponent("api/accounts/stats/update/")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        req.httpBody = try encoder.encode(stats)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // Debug logging
        print("🔍 Stats Sync Status:", (resp as? HTTPURLResponse)?.statusCode ?? -1)
        print("🔍 Stats Sync Response:", String(data: data, encoding: .utf8) ?? "<not utf8>")
        
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "StatsSync", code: statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Failed to sync stats: \(errorMsg)"
            ])
        }
    }
    
    /// GET /api/accounts/me/ - Fetch current user profile
    func fetchUserProfile(token: String) async throws -> MeResponse {
        let url = baseURL.appendingPathComponent("api/accounts/me/")
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // Debug logging
        print("🔍 Fetch Profile Status:", (resp as? HTTPURLResponse)?.statusCode ?? -1)
        print("🔍 Fetch Profile Response:", String(data: data, encoding: .utf8) ?? "<not utf8>")
        
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "ProfileFetch", code: statusCode, userInfo: [
                NSLocalizedDescriptionKey: "Failed to fetch profile: \(errorMsg)"
            ])
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MeResponse.self, from: data)
    }
}

// MARK: - Alternative Feedback Methods (if you want to use traditional endpoint)
extension NetworkService {
    /// Fetch feedback using traditional paginated endpoint
    static func fetchFeedbackPaginated() async throws -> [FeedbackItem] {
        let traditionalURL = URL(string: "https://releaf-2o3sj.ondigitalocean.app/api/feedback/")!
        let (data, resp) = try await URLSession.shared.data(from: traditionalURL)
        
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Handle paginated response
        struct PaginatedResponse: Codable {
            let count: Int
            let next: String?
            let previous: String?
            let results: [FeedbackItem]
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(PaginatedResponse.self, from: data)
        return response.results
    }
}
// Add profile update models
struct UserProfileUpdate: Codable {
    let username: String?
    let dateOfBirth: Date?
    let selectedUnit: String?
    let country: String?
    let language: String?
    let avatarData: Data?
}

struct UserStatsUpdate: Codable {
    let posts: Int
    let tracking: Int
    let followers: Int
    let waterDrops: Int
    let treesPlanted: Int
    let achievements: Int
    let totalLikes: Int
    let totalComments: Int
}

struct DonationRecord: Codable, Identifiable {
    let id: UUID
    let userId: String
    let amount: Double
    let currency: String
    let paymentMethod: String
    let status: String
    let timestamp: Date
    let waterDropsEarned: Int
}

// MARK: - HelpSupportView
struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: String? = nil
    @State private var message: String = ""
    @State private var isSending = false
    @State private var showSuccess = false
    @State private var errorMessage: String? = nil

    let feedbackTypes = [
        "Rewards Redemption Issue",
        "Request Brand/Brand Rating",
        "Card Connection Issue",
        "General Question",
        "Request Feature",
        "Report Bug"
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Share Feedback")
                        .font(.title2).bold()
                        .padding(.top, 24)
                    Text("Let us know how we can improve your experience.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Feedback Type List
                VStack(spacing: 0) {
                    ForEach(feedbackTypes, id: \.self) { type in
                        Button {
                            selectedType = type
                        } label: {
                            HStack {
                                Text(type)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground))
                        }
                        Divider()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding(.horizontal)
                .padding(.bottom, 16)

                // Feedback Text Area
                VStack(alignment: .leading, spacing: 8) {
                    Text("Describe your experience or issue")
                        .font(.headline)
                    TextEditor(text: $message)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)

                // Send Button
                if AccountManager.shared.isGuestMode {
                    VStack(spacing: 8) {
                        Text("Sign in required")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Create an account to send feedback and help us improve")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                } else {
                    Button {
                        Task {
                            await sendFeedback()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if isSending {
                                ProgressView()
                            } else {
                                Text(message.isEmpty ? "Start Typing" : "Send Feedback")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(!message.isEmpty ? Color.green : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(message.isEmpty || isSending)
                    .padding(.horizontal)
                }

                // Error or Success
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                if showSuccess {
                    Text("Thank you for your feedback!")
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func sendFeedback() async {
        // Prevent guest users from sending feedback
        guard AccountManager.shared.isLoggedIn else {
            errorMessage = "Please create an account to send feedback."
            return
        }
        
        isSending = true
        errorMessage = nil
        showSuccess = false
        do {
            try await NetworkService.postFeedback(type: selectedType ?? "General", message: message)
            showSuccess = true
            message = ""
            selectedType = nil
        } catch {
            errorMessage = "Failed to send feedback. Please try again."
        }
        isSending = false
    }
}
