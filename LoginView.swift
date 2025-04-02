import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var isShowingEmailSignup = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.6, blue: 0.4),
                    Color(red: 0.1, green: 0.4, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    // Background pattern
                    ForEach(0..<20) { i in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 20...60))
                            .position(
                                x: CGFloat.random(in: -20...400),
                                y: CGFloat.random(in: -20...400)
                            )
                    }
                }
            )
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo
                Image("releaf_logo") // Make sure to add your logo to assets
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .padding(.bottom, 40)
                
                Text("GLOBAL SUSTAINABILITY TRACKER™")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(2)
                
                Spacer()
                
                VStack(spacing: 16) {
                    // Email Sign Up Button
                    Button {
                        isShowingEmailSignup = true
                    } label: {
                        HStack {
                            Text("Sign Up with e-mail")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                        .padding(.horizontal, 20)
                    }
                    
                    // Or connect with text
                    Text("or connect with")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Social login options
                    HStack(spacing: 20) {
                        // Apple login
                        Button {
                            // Handle Apple login
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "apple.logo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                )
                        }
                        
                        // Google login
                        Button {
                            // Handle Google login
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "g.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                )
                        }
                        
                        // Facebook login
                        Button {
                            // Handle Facebook login
                        } label: {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "f.square.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.blue)
                                )
                        }
                    }
                }
                .padding(.bottom, 50)
                
                // Terms and Privacy
                VStack(spacing: 8) {
                    Text("By signing in, I agree to our")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 4) {
                        Button {
                            // Show Terms of Service
                        } label: {
                            Text("Terms of Service")
                                .underline()
                        }
                        
                        Text("and")
                        
                        Button {
                            // Show Privacy Policy
                        } label: {
                            Text("Privacy Policy")
                                .underline()
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $isShowingEmailSignup) {
            EmailSignupView()
        }
    }
}

struct EmailSignupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isSecured = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Create your account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                
                VStack(spacing: 16) {
                    // Email field
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    // Password field
                    HStack {
                        if isSecured {
                            SecureField("Password", text: $password)
                        } else {
                            TextField("Password", text: $password)
                        }
                        
                        Button {
                            isSecured.toggle()
                        } label: {
                            Image(systemName: isSecured ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 32)
                
                Button {
                    // Handle sign up
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(25)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
} 
