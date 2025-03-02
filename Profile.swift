//
//  Profile.swift
//  Treeplanting App
//
//  Created by Micheal Jiang on 02/03/2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var showingProfileSheet = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDetail = false
    @State private var selectedMenuTitle = ""
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // 1) TOP SECTION
                VStack(spacing: 12) {
                    // A row with clickable circle + "Name"
                    Button(action: {
                        showingProfileSheet = true
                    }) {
                        HStack(spacing: 20) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                            
                            Text("Your Username")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image("treeTransparent")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal)
                                    .frame(width: 140, height: 140)
                                    .cornerRadius(20)
                            
                        }
                    }
                    .padding(.horizontal)
                  
                    Text("EcoAware")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.6, green: 0.75, blue: 0.65))
                        .padding(.horizontal, 20)
                        .padding(.top, 1)
                        .padding(.bottom, 0.5)
                }
                
                
                // 2) THREE VERTICAL LINES (short, un-clickable)
                ThreeVerticalLinesSection()
                VStack(spacing: 12) {
                    HStack(spacing:20) {
                        Text("Collected WaterDrops: 0")
                            .padding(.bottom, 5)
                            .padding(.horizontal, 30)
                        Text("My Forest: 1")
                            .padding(.bottom, 5)
                            .padding(.horizontal, 30)
                    }
                }
                        .padding(.top, -10) // Negative top padding can also move everything up if desired
                        .background(Color.green.opacity(0.001))
                
                // 3) RECYCLING SIGN + FOUR TEXT BOXES
                // "tricycle" is the name of the uploaded image asset
                HStack(alignment: .top, spacing: 1) {
                    Image("tr")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .cornerRadius(20)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Accumulated 84 people have used ")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .background(Color(red:0.6, green:0.75, blue:0.65))
                        Text("Service Team")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .background(Color(red:0.6, green:0.75, blue:0.65))
                        Text("Current Collaborations")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .background(Color(red:0.6, green:0.75, blue:0.65))
                        Text("❤️Make a Donation")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .background(Color(red:0.6, green:0.75, blue:0.65))
                    }
                    Spacer()
                }
                .padding(.horizontal, 25)
                
                
                    VStack(alignment: .leading, spacing: 18) {
                        
                        NavigationLink(destination: PlaceholderView(title:"Favorites")) {
                            MenuItemRow(title:"Favorites", iconName:"star.fill")
                        }
                        
                        NavigationLink(destination: PlaceholderView(title:"Saves")) {
                            MenuItemRow(title:"Saves", iconName:"bookmark.fill")
                        }
                        
                        NavigationLink(destination: PlaceholderView(title:"Manage your account")) {
                            MenuItemRow(title: "Manage your account", iconName:"person.crop.circle.badge.plus")
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            MenuItemRow(title: "Settings", iconName: "gearshape.fill")
                        }
                        
                        NavigationLink(destination: PlaceholderView(title:"Legal")) {
                            MenuItemRow(title:"Legal", iconName:"doc.text.fill")
                        }
                        
                        NavigationLink(destination: PlaceholderView(title:"Help and feedback")) {
                            MenuItemRow(title: "Help and feedback", iconName:"questionmark.circle.fill")
                        }
                    }
                
                .padding(.horizontal)
                .background(
                    Color(red: 0.6, green: 0.75, blue: 0.65)
                        .ignoresSafeArea(.all)
                )
                Spacer().frame(height: 40) // some extra space at bottom
            }
            .padding(.top, 20)
        }
        .background(
            Color(red: 0.6, green: 0.75, blue: 0.65)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $showingProfileSheet) {
            // This is your new detail view with the circle, username, and 2 buttons
            ProfileEditSheetView()
        }
        
    }
    
    
}

struct ProfileEditSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Match your background color
            Color(red: 0.6, green: 0.75, blue: 0.65)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                // Circle in the middle
                Circle()
                    .fill(Color.blue)
                    .frame(width: 80, height: 80)
                
                // Username below it
                Text("Your Username")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                }) {
                    Text("Add Profile Photo")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                }) {
                    Text("Edit Profile Information")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 16)
        }
    }
}
// MARK: - ThreeVerticalLinesSection
/// A short row with 3 vertical lines (un-clickable)
struct ThreeVerticalLinesSection: View {
    var body: some View {
        HStack(spacing: 110) {
            Rectangle()
                .fill(Color.black)
                .frame(width: 3, height: 80)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 3, height: 80)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 3, height: 80)
        }
    }
}

// MARK: - MenuItemRow

struct MenuItemRow: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

struct PlaceholderView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text("\(title) View")
                .font(.largeTitle)
                .foregroundColor(.black)
        }
        .navigationBarTitle(title, displayMode: .inline)
        
    }
}

struct SettingsView: View {
    var body: some View {
        ZStack {
            // 1) Match background color to your home page
            
            
            // 2) A list of items
            List {
                NavigationLink(destination: PlaceholderView(title: "Email")) {
                    Text("Email: jiang.shengbo@icloud.com")
                }
                NavigationLink(destination: PlaceholderView(title: "Mobile Number")) {
                    Text("Mobile Number: +1 203 536 7510")
                }
                NavigationLink(destination: PlaceholderView(title: "Date of Birth")) {
                    Text("Date of Birth: 3/24/09")
                }
                NavigationLink(destination: PlaceholderView(title: "Units of Measure")) {
                    Text("Units of Measure")
                }
                NavigationLink(destination: PlaceholderView(title: "Payment Information")) {
                    Text("Payment Information")
                }
                NavigationLink(destination: PlaceholderView(title: "Country/Region")) {
                    Text("Country/Region")
                }
                NavigationLink(destination: PlaceholderView(title: "Language")) {
                    Text("Language")
                }
            }
            .listStyle(.plain)
            // iOS 16+ only. If on iOS 15 or earlier, remove this:
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}





// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}

