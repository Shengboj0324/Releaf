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
        ZStack {
            // Place the background first so it doesn’t block touches.
            Color(red: 0.6, green: 0.75, blue: 0.65)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    
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
                        HStack(spacing: 20) {
                            Text("Collected WaterDrops: 0")
                                .padding(.bottom, 5)
                                .padding(.horizontal, 30)
                                .fontWeight(.bold)
                            
                            Text("My Forest: 1")
                                .padding(.bottom, 5)
                                .padding(.horizontal, 30)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, -10)
                    .background(Color.green.opacity(0.001))
                    
                    // 3) RECYCLING SIGN + FOUR TEXT BOXES
                    HStack(alignment: .top, spacing: 20) {
                        // The recycling sign on the left
                        Image("tr")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)
                        
                        // 2x2 grid for the text boxes
                        VStack(spacing: 2) {
                            // First row
                            HStack(spacing: 12) {
                                NavigationLink(destination: AccumulateView()) {
                                    Text("Overall Use")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(8)
                                        .frame(width: 80, height: 80)
                                }
                                
                                NavigationLink(destination: ServiceTeamView()) {
                                    Text("Service Team")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(8)
                                        .frame(width: 80, height: 80)
                                }
                            }
                            
                            // Second row
                            HStack(spacing: 12) {
                                NavigationLink(destination: CollaborationView()) {
                                    Text("Collaborations")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(8)
                                        .frame(width: 80, height: 80)
                                }
                                
                                NavigationLink(destination: DonationView()) {
                                    Text("❤️ Make Donation")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(8)
                                        .frame(width: 80, height: 80)
                                }
                            }
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
                        
                        // If you want a real SettingsView:
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
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 20)
            }
            .background(
                Color(red: 0.6, green: 0.75, blue: 0.65)
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("Profile", displayMode: .inline)
            .sheet(isPresented: $showingProfileSheet) {
                ProfileEditSheetView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Subviews & Child Views

struct AccumulateView: View {
    var body: some View {
        Text("AccumulateView")
            .font(.largeTitle)
            .navigationBarTitle("Accumulate", displayMode: .inline)
    }
}

struct ServiceTeamView: View {
    var body: some View {
        Text("ServiceTeamView")
            .font(.largeTitle)
            .navigationBarTitle("Service Team", displayMode: .inline)
    }
}

struct CollaborationView: View {
    var body: some View {
        Text("CollaborationView")
            .font(.largeTitle)
            .navigationBarTitle("Collaborations", displayMode: .inline)
    }
}

struct DonationView: View {
    var body: some View {
        Text("DonationView")
            .font(.largeTitle)
            .navigationBarTitle("Donation", displayMode: .inline)
    }
}


struct ProfileEditSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingProfileInfoEdit = false
    @State private var showingPhotoOptions = false  // track popup state
    
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
                
                // Username below
                Text("Your Username")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Button: "Add Profile Photo"
                Button(action: {
                    showingPhotoOptions = true
                }) {
                    Text("Add Profile Photo")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                // Another button (e.g., "Edit Profile Information")
                Button(action: {
                    showingProfileInfoEdit = true
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
        // Present the custom popup as a partial sheet for photo options
        .sheet(isPresented: $showingPhotoOptions) {
            PhotoOptionsSheet(isPresented: $showingPhotoOptions)
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
        }
    }
}


struct ProfileInfoEditSheet: View {
    @Binding var currentUsername: String
    @Binding var isPresented: Bool
    
    @State private var newUsername = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.6, green: 0.75, blue: 0.65)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                // Show the current username
                Text("Your current username: \(currentUsername)")
                    .font(.headline)
                    .foregroundColor(.black)
                
                // A text field for the new username
                VStack(alignment: .leading) {
                    Text("New UserName")
                        .foregroundColor(.black)
                    TextField("", text: $newUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 16)
                
                // Save button
                Button("Save") {
                    if !newUsername.isEmpty {
                        currentUsername = newUsername
                    }
                    isPresented = false
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

struct PhotoOptionsSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            OptionBox(title: "Take Photo") {
                isPresented = false
            }
            OptionBox(title: "Choose from Album") {
                isPresented = false
            }
            OptionBox(title: "View Previous Profile Photo") {
                isPresented = false
            }
            OptionBox(title: "Save Photo") {
                isPresented = false
            }
            OptionBox(title: "Cancel") {
                isPresented = false
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }
}

struct OptionBox: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.4))
                .cornerRadius(12)
        }
    }
}

struct BottomCardPopup: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Translucent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    Button("Take Photo") { isPresented = false }
                        .optionButtonStyle()
                    Button("Choose from Album") { isPresented = false }
                        .optionButtonStyle()
                    Button("View Previous Profile Photo") { isPresented = false }
                        .optionButtonStyle()
                    Button("Save Photo") { isPresented = false }
                        .optionButtonStyle()
                    Button("Cancel") { isPresented = false }
                        .optionButtonStyle()
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .background(Color.white)
            }
        }
    }
}

// Example style extension
extension View {
    func optionButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.blue)
            .padding()
            .frame(maxWidth: .infinity)
    }
}

// The three vertical lines
struct ThreeVerticalLinesSection: View {
    var body: some View {
        HStack(spacing: 20) {
            Text("Box #1")
                .font(.subheadline)
                .foregroundColor(.black)
                .fontWeight(.bold)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 4.5, height: 60)
            
            Text("Box #2")
                .font(.subheadline)
                .foregroundColor(.black)
                .fontWeight(.bold)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 4.5, height: 60)
            
            Text("Box #3")
                .font(.subheadline)
                .foregroundColor(.black)
                .fontWeight(.bold)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 4.5, height: 60)
            
            Text("Box #4")
                .font(.subheadline)
                .foregroundColor(.black)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
    }
}

// The MenuItemRow for each row in the menu
struct MenuItemRow: View {
    let title: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(.black)
            Text(title)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

// A placeholder for sub-screens
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

// Example SettingsView
struct SettingsView: View {
    @State private var selectedCountry = "Not set"
    @State private var selectedLanguage = "Not set"
    
    var body: some View {
        ZStack {
            List {
                NavigationLink(destination: PlaceholderView(title: "Email")) {
                    Text("Email")
                }
                NavigationLink(destination: PlaceholderView(title: "Mobile Number")) {
                    Text("Mobile Number")
                }
                NavigationLink(destination: PlaceholderView(title: "Date of Birth")) {
                    Text("Data of Birth")
                }
                NavigationLink(destination: PlaceholderView(title: "Units of Measure")) {
                    Text("Units of Measure")
                }
                NavigationLink(destination: PlaceholderView(title: "Payment Information")) {
                    Text("Payment Information / Optional")
                }
                NavigationLink(destination: CountryRegionView(selectedCountry: $selectedCountry)) {
                    HStack {
                        Text("Country/Region")
                        Spacer()
                        Text(selectedCountry)
                            .foregroundColor(.gray)
                    }
                }
                NavigationLink(destination: LanguageView(selectedLanguage: $selectedLanguage)) {
                    HStack {
                        Text("Language")
                        Spacer()
                        Text(selectedLanguage)
                            .foregroundColor(.gray)
                    }
                }
                
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}




struct CountryRegionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCountry: String

    // A sample sorted list of countries.
    let countries = [
        "Australia", "Austria",
        "Belgium",
        "Canada", "China", "Denmark", "Finland",
        "France", "Germany", "Greece", "Hungary", "India",
        "Indonesia", "Italy", "Japan",
        "Netherlands", "Norway",
        "South Korea", "Spain", "Sweden",
        "Switzerland", "Turkey", "United Kingdom", "United States",
    ].sorted()
    
    @State private var tempSelection: String = ""
    
    var body: some View {
        List(countries, id: \.self) { country in
            HStack {
                Text(country)
                Spacer()
                if country == tempSelection {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())  // Allow tapping the entire row
            .onTapGesture {
                tempSelection = country
            }
        }
        .navigationBarTitle("Country/Region", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if !tempSelection.isEmpty {
                        selectedCountry = tempSelection
                    }
                    dismiss()
                }
            }
        }
        .onAppear {
            // Set the temporary selection to the current value
            tempSelection = selectedCountry
        }
    }
}

struct LanguageView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLanguage: String

    let languages = [
        "Chinese", "English",
        "French", "German", "Italian", "Japanese",
        "Korean", "Spanish",
    ].sorted()
    
    @State private var tempLanguage: String = ""
    
    var body: some View {
        List(languages, id: \.self) { language in
            HStack {
                Text(language)
                Spacer()
                if language == tempLanguage {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tempLanguage = language
            }
        }
        .navigationBarTitle("Language", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if !tempLanguage.isEmpty {
                        selectedLanguage = tempLanguage
                    }
                    dismiss()
                }
            }
        }
        .onAppear {
            tempLanguage = selectedLanguage
        }
    }
}
// Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
