import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    @State private var showingTerms = false
    @State private var showingSignOutAlert = false
    @State private var showingProfileEdit = false
    
    // Mock profile data (In a real app, this would come from your user service)
    @AppStorage("userName") private var userName = "User"
    @AppStorage("userEmail") private var userEmail = "user@example.com"
    
    var body: some View {
        List {
            // Profile Section
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.accent)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.title3.bold())
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingProfileEdit = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        ProfileStatCard(title: "Prospects", value: "150")
                        ProfileStatCard(title: "Teams", value: "30")
                        ProfileStatCard(title: "Reports", value: "45")
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Appearance Section
            Section("Appearance") {
                Toggle(isOn: $isDarkMode) {
                    Label {
                        Text("Dark Mode")
                    } icon: {
                        Image(systemName: isDarkMode ? "moon.fill" : "moon")
                            .foregroundStyle(isDarkMode ? .purple : .gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Text Size", systemImage: "textformat.size")
                        Spacer()
                        Text(String(format: "%.0f%%", fontSize * 100))
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "textformat.size.smaller")
                            .foregroundStyle(.secondary)
                        
                        Slider(value: $fontSize, in: 0.8...1.4, step: 0.1)
                        
                        Image(systemName: "textformat.size.larger")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Developer Information
            Section("Developer Information") {
                VStack(alignment: .leading, spacing: 12) {
                    DeveloperInfoRow(
                        name: "Aradhya Dubey",
                        role: "Lead Developer",
                        imageSystemName: "person.circle.fill"
                    )
                    
                    Divider()
                    
                    DeveloperInfoRow(
                        name: "Ritesh Yadav",
                        role: "Lead Developer",
                        imageSystemName: "person.circle.fill"
                    )
                }
                .padding(.vertical, 8)
            }
            
            // Legal & App Info
            Section {
                Button {
                    showingTerms = true
                } label: {
                    Label("Terms and Conditions", systemImage: "doc.text")
                }
            }
            
            // Sign Out
            Section {
                Button(role: .destructive) {
                    showingSignOutAlert = true
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingTerms) {
            TermsAndConditionsView()
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(userName: $userName, userEmail: $userEmail)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                // Handle sign out
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct DeveloperInfoRow: View {
    let name: String
    let role: String
    let imageSystemName: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageSystemName)
                .font(.title)
                .foregroundStyle(Theme.accent)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                
                Text(role)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct TermsAndConditionsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Terms and Conditions")
                            .font(.title.bold())
                        
                        Text("Last Updated: \(Date.now.formatted(date: .long, time: .omitted))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("1. Acceptance of Terms")
                            .font(.headline)
                        Text("By accessing and using Career Curve, you accept and agree to be bound by the terms and provision of this agreement.")
                        
                        Text("2. App Usage")
                            .font(.headline)
                        Text("Career Curve is designed to provide baseball prospect analytics and predictions. The data and predictions provided are for informational purposes only.")
                        
                        Text("3. Privacy Policy")
                            .font(.headline)
                        Text("We respect your privacy and are committed to protecting your personal data. Our app collects only necessary information to provide our services.")
                        
                        Text("4. Intellectual Property")
                            .font(.headline)
                        Text("All content, features, and functionality of Career Curve are owned by Aradhya Dubey and Ritesh Yadav and are protected by international copyright, trademark, and other intellectual property rights laws.")
                    }
                    
                    Group {
                        Text("5. Disclaimer")
                            .font(.headline)
                        Text("The predictions and analytics provided by Career Curve are based on available data and statistical models. We do not guarantee the accuracy of these predictions.")
                        
                        Text("6. Contact")
                            .font(.headline)
                        Text("For any questions or concerns regarding these terms, please contact the developers.")
                    }
                }
                .padding()
            }
            .navigationTitle("Terms & Conditions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Theme.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Theme.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userEmail: String
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Information") {
                    TextField("Name", text: $tempName)
                    TextField("Email", text: $tempEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                
                Section {
                    Button("Update Profile Photo") {
                        // Handle photo update
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        userName = tempName
                        userEmail = tempEmail
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempName = userName
                tempEmail = userEmail
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
} 