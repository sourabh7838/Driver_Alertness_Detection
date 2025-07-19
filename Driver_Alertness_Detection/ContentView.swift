//
//  ContentView.swift
//  Driver_Alertness_Detection
//
//  Created by SOURABH CHAUHAN on 05/07/25.
//

import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @StateObject private var alertnessDetector = AlertnessDetector()
    @State private var showingPermissionAlert = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Dynamic background with animated gradient
            AnimatedBackgroundView()
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Main Detection View
                MainDetectionView(alertnessDetector: alertnessDetector)
                    .tabItem {
                        Image(systemName: "eye.fill")
                        Text("Monitor")
                    }
                    .tag(0)
                
                // Statistics View
                StatisticsView(alertnessDetector: alertnessDetector)
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Stats")
                    }
                    .tag(1)
                
                // Trip History View
                TripHistoryView()
                    .tabItem {
                        Image(systemName: "car.fill")
                        Text("Trips")
                    }
                    .tag(2)
                
                // Settings View
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(3)
            }
            .accentColor(.white)
            .onAppear {
                setupTabBarAppearance()
            }
        }
        .onAppear {
            alertnessDetector.checkCameraPermission { granted in
                if !granted {
                    showingPermissionAlert = true
                }
            }
        }
        .alert("Camera Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                #if canImport(UIKit)
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                #elseif canImport(AppKit)
                // On macOS, direct the user to System Preferences
                if let settingsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                    NSWorkspace.shared.open(settingsUrl)
                }
                #endif
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to use driver alertness monitoring.")
        }
    }
    
    private func setupTabBarAppearance() {
        #if canImport(UIKit)
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
        // macOS doesn't have UITabBar, the TabView styling is handled differently
    }
}

// MARK: - Animated Background View
struct AnimatedBackgroundView: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black,
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.6),
                Color.black
            ]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Main Detection View
struct MainDetectionView: View {
    @ObservedObject var alertnessDetector: AlertnessDetector
    @State private var pulseAnimation = false
    @State private var showEmergencyAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header Section
                HeaderSection()
                
                // Camera Preview Card
                CameraPreviewCard(alertnessDetector: alertnessDetector)
                
                // Alert Status Card
                AlertStatusCard(alertnessDetector: alertnessDetector, pulseAnimation: $pulseAnimation)
                
                // Detection Stats Cards
                DetectionStatsCards(alertnessDetector: alertnessDetector)
                
                // Emergency Button
                EmergencyButton(showEmergencyAlert: $showEmergencyAlert)
                
                Spacer(minLength: 100) // Space for tab bar
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation.toggle()
            }
        }
        .alert("Emergency Alert Sent", isPresented: $showEmergencyAlert) {
            Button("OK") { }
        } message: {
            Text("Emergency contacts have been notified of your location and status.")
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 35))
                    .foregroundStyle(.linearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Driver Safety")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("AI-Powered Alertness Monitor")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text(getCurrentTime())
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

// MARK: - Camera Preview Card
struct CameraPreviewCard: View {
    @ObservedObject var alertnessDetector: AlertnessDetector
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 15) {
                HStack {
                    Text("Live Camera Feed")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(alertnessDetector.isRunning ? 1 : 0.3)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: alertnessDetector.isRunning)
                    
                    Text("LIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                CameraPreviewView(alertnessDetector: alertnessDetector)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Alert Status Card
struct AlertStatusCard: View {
    @ObservedObject var alertnessDetector: AlertnessDetector
    @Binding var pulseAnimation: Bool
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 20) {
                HStack {
                    Text("Alert Status")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Safe")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                }
                
                // Large Status Indicator
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .stroke(alertnessDetector.alertLevel.color.opacity(0.3), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .stroke(alertnessDetector.alertLevel.color, lineWidth: 8)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseAnimation && alertnessDetector.alertLevel != .normal ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        VStack(spacing: 5) {
                            Image(systemName: alertnessDetector.alertLevel.iconName)
                                .font(.system(size: 30))
                                .foregroundColor(alertnessDetector.alertLevel.color)
                            
                            Text(alertnessDetector.alertLevel.shortText)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text(alertnessDetector.alertLevel.displayText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(alertnessDetector.alertLevel.color)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut, value: alertnessDetector.alertLevel)
                }
            }
        }
    }
}

// MARK: - Detection Stats Cards
struct DetectionStatsCards: View {
    @ObservedObject var alertnessDetector: AlertnessDetector
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCard(
                title: "Face Detection",
                status: alertnessDetector.faceDetected,
                icon: "face.smiling.inverse",
                color: .green
            )
            
            StatCard(
                title: "Eye Monitoring",
                status: !alertnessDetector.eyesClosed,
                icon: "eye.fill",
                color: .blue
            )
            
            StatCard(
                title: "Yawn Detection",
                status: !alertnessDetector.yawning,
                icon: "mouth.fill",
                color: .orange
            )
            
            StatCard(
                title: "Head Position",
                status: alertnessDetector.faceDetected,
                icon: "person.fill",
                color: .purple
            )
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let status: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(status ? color : .red)
                    
                    Spacer()
                    
                    Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(status ? .green : .red)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(status ? "Normal" : "Alert")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(status ? .green : .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 90)
    }
}

// MARK: - Emergency Button
struct EmergencyButton: View {
    @Binding var showEmergencyAlert: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            triggerEmergency()
        }) {
            HStack(spacing: 15) {
                Image(systemName: "sos.circle.fill")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Emergency Alert")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Tap to notify emergency contacts")
                        .font(.caption)
                        .opacity(0.8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.linearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
    
    private func triggerEmergency() {
        // Trigger haptic feedback (iOS only)
        #if canImport(UIKit)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        #elseif canImport(AppKit)
        // macOS doesn't have haptic feedback, use sound instead
        NSSound.beep()
        #endif
        
        // In a real app, this would send location and alert to emergency contacts
        showEmergencyAlert = true
    }
}

// MARK: - Glassmorphic Card
struct GlassmorphicCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}



#Preview {
    ContentView()
}
