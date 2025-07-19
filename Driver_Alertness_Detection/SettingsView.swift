import SwiftUI

struct SettingsView: View {
    @State private var enableSoundAlerts = true
    @State private var enableHapticFeedback = true
    @State private var alertSensitivity: Double = 0.5
    @State private var enableEmergencyContacts = false
    @State private var enableDarkMode = true
    @State private var autoStartTrips = false
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    @State private var showingCalibration = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    ProfileSection()
                    
                    AlertSettingsSection(
                        enableSoundAlerts: $enableSoundAlerts,
                        enableHapticFeedback: $enableHapticFeedback,
                        alertSensitivity: $alertSensitivity
                    )
                    
                    AppPreferencesSection(
                        enableDarkMode: $enableDarkMode,
                        autoStartTrips: $autoStartTrips
                    )
                    
                    SafetyFeaturesSection(
                        enableEmergencyContacts: $enableEmergencyContacts,
                        showingCalibration: $showingCalibration
                    )
                    
                    DataPrivacySection(
                        showingPrivacy: $showingPrivacy
                    )
                    
                    AboutSupportSection(
                        showingAbout: $showingAbout
                    )
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Settings")
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        // Temporarily commented out until we fix the view structure
        // .sheet(isPresented: $showingPrivacy) {
        //     PrivacyView()
        // }
        // .sheet(isPresented: $showingCalibration) {
        //     CalibrationView()
        // }
    }
}

// MARK: - Profile Section
struct ProfileSection: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Driver Profile")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Safety-First Driver")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 15) {
                        ProfileStat(label: "Trips", value: "24")
                        ProfileStat(label: "Safety", value: "96%")
                        ProfileStat(label: "Hours", value: "48h")
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Profile Stat
struct ProfileStat: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Alert Settings Section
struct AlertSettingsSection: View {
    @Binding var enableSoundAlerts: Bool
    @Binding var enableHapticFeedback: Bool
    @Binding var alertSensitivity: Double
    
    var body: some View {
        SettingsSection(title: "Alert Settings", icon: "bell.fill", iconColor: .orange) {
            VStack(spacing: 20) {
                SettingsToggle(
                    title: "Sound Alerts",
                    subtitle: "Play audio alerts for warnings",
                    icon: "speaker.fill",
                    isOn: $enableSoundAlerts
                )
                
                SettingsToggle(
                    title: "Haptic Feedback",
                    subtitle: "Vibrate device for critical alerts",
                    icon: "iphone.radiowaves.left.and.right",
                    isOn: $enableHapticFeedback
                )
                
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "gauge.medium")
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Alert Sensitivity")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Text("Adjust detection sensitivity")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: $alertSensitivity, in: 0...1)
                            .accentColor(.purple)
                        
                        HStack {
                            Text("Low")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer()
                            
                            Text("High")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - App Preferences Section
struct AppPreferencesSection: View {
    @Binding var enableDarkMode: Bool
    @Binding var autoStartTrips: Bool
    
    var body: some View {
        SettingsSection(title: "App Preferences", icon: "gear.circle.fill", iconColor: .blue) {
            VStack(spacing: 20) {
                SettingsToggle(
                    title: "Dark Mode",
                    subtitle: "Use dark appearance",
                    icon: "moon.fill",
                    isOn: $enableDarkMode
                )
                
                SettingsToggle(
                    title: "Auto-Start Trips",
                    subtitle: "Automatically begin monitoring",
                    icon: "play.circle.fill",
                    isOn: $autoStartTrips
                )
            }
        }
    }
}

// MARK: - Safety Features Section
struct SafetyFeaturesSection: View {
    @Binding var enableEmergencyContacts: Bool
    @Binding var showingCalibration: Bool
    
    var body: some View {
        SettingsSection(title: "Safety Features", icon: "shield.checkered", iconColor: .green) {
            VStack(spacing: 15) {
                SettingsToggle(
                    title: "Emergency Contacts",
                    subtitle: "Alert contacts in danger situations",
                    icon: "person.2.fill",
                    isOn: $enableEmergencyContacts
                )
                
                SettingsButton(
                    title: "Calibrate Detection",
                    subtitle: "Personalize face detection settings",
                    icon: "viewfinder",
                    action: { showingCalibration = true }
                )
                
                SettingsButton(
                    title: "Emergency Contacts",
                    subtitle: "Manage emergency contact list",
                    icon: "phone.circle.fill",
                    action: { /* Open emergency contacts */ }
                )
            }
        }
    }
}

// MARK: - Data Privacy Section
struct DataPrivacySection: View {
    @Binding var showingPrivacy: Bool
    
    var body: some View {
        SettingsSection(title: "Data & Privacy", icon: "lock.shield.fill", iconColor: .purple) {
            VStack(spacing: 15) {
                SettingsButton(
                    title: "Privacy Policy",
                    subtitle: "View our privacy policy",
                    icon: "doc.text.fill",
                    action: { showingPrivacy = true }
                )
                
                SettingsButton(
                    title: "Export Trip Data",
                    subtitle: "Download your trip history",
                    icon: "square.and.arrow.up.fill",
                    action: { /* Export data */ }
                )
                
                SettingsButton(
                    title: "Clear All Data",
                    subtitle: "Reset app to initial state",
                    icon: "trash.fill",
                    action: { /* Clear data */ },
                    isDestructive: true
                )
            }
        }
    }
}

// MARK: - About Support Section
struct AboutSupportSection: View {
    @Binding var showingAbout: Bool
    
    var body: some View {
        SettingsSection(title: "About & Support", icon: "info.circle.fill", iconColor: .cyan) {
            VStack(spacing: 15) {
                SettingsButton(
                    title: "About App",
                    subtitle: "Version 1.0 • Learn more",
                    icon: "app.badge.checkmark.fill",
                    action: { showingAbout = true }
                )
                
                SettingsButton(
                    title: "Help & Support",
                    subtitle: "Get help and contact support",
                    icon: "questionmark.circle.fill",
                    action: { /* Open support */ }
                )
                
                SettingsButton(
                    title: "Rate App",
                    subtitle: "Leave a review on the App Store",
                    icon: "star.fill",
                    action: { /* Rate app */ }
                )
            }
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Settings Toggle
struct SettingsToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
        }
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isDestructive ? .red : .white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "eye.circle.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(.linearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                        
                        VStack(spacing: 5) {
                            Text("Driver Alertness Detection")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Version 1.0")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    VStack(spacing: 15) {
                        Text("Advanced AI-powered driver safety monitoring that uses computer vision to detect signs of fatigue and drowsiness, helping keep roads safer for everyone.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        VStack(spacing: 12) {
                            FeatureRow(icon: "eye.fill", text: "Real-time face detection")
                            FeatureRow(icon: "gauge.medium", text: "Fatigue level monitoring")
                            FeatureRow(icon: "exclamationmark.triangle.fill", text: "Smart alert system")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed analytics")
                            FeatureRow(icon: "shield.checkered", text: "Emergency safety features")
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Text("Developed with ❤️ for safer roads")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("© 2024 Driver Safety Solutions")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(30)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("About")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .preferredColorScheme(.dark)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #endif
            }
        }
    }

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

// MARK: - Privacy View
struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        PrivacySection(
                            title: "Data Collection",
                            content: "We only collect necessary data for app functionality. All facial detection is processed locally on your device and is never stored or transmitted."
                        )
                        
                        PrivacySection(
                            title: "Trip Data",
                            content: "Trip statistics and safety metrics are stored locally on your device. You have full control over this data and can export or delete it at any time."
                        )
                        
                        PrivacySection(
                            title: "Camera Access",
                            content: "Camera access is required for real-time face detection. Video feed is processed in real-time and never recorded or saved."
                        )
                        
                        PrivacySection(
                            title: "Your Rights",
                            content: "You can disable features, export your data, or delete all information at any time through the Settings page."
                        )
                    }
                }
                .padding(20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Privacy")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .preferredColorScheme(.dark)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #endif
            }
        }
    }
}

// MARK: - Privacy Section
struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Calibration View
struct CalibrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var calibrationStep = 1
    @State private var isCalibrating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Text("Calibration")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Step \(calibrationStep) of 3")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    ProgressView(value: Double(calibrationStep), total: 3)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                
                VStack(spacing: 20) {
                    Image(systemName: calibrationIcon)
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text(calibrationInstructions)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                Button(action: nextStep) {
                    Text(calibrationStep < 3 ? "Next" : "Complete")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.blue)
                        )
                }
                .disabled(isCalibrating)
            }
            .padding(30)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Calibration")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .preferredColorScheme(.dark)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                #endif
            }
        }
    }
    
    private var calibrationIcon: String {
        switch calibrationStep {
        case 1: return "face.smiling"
        case 2: return "eye.fill"
        case 3: return "mouth.fill"
        default: return "checkmark.circle.fill"
        }
    }
    
    private var calibrationInstructions: String {
        switch calibrationStep {
        case 1: return "Position yourself comfortably in front of the camera. Make sure your face is clearly visible and well-lit."
        case 2: return "Look directly at the camera and blink normally. This helps calibrate eye detection for your unique features."
        case 3: return "Open your mouth as if yawning. This calibrates yawn detection to work optimally for you."
        default: return "Calibration complete! The app is now personalized for your facial features."
        }
    }
    
    private func nextStep() {
        isCalibrating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if calibrationStep < 3 {
                calibrationStep += 1
            } else {
                dismiss()
            }
            isCalibrating = false
        }
    }
}
}
