# Driver Alertness Detection App

<div align="center">
  <img alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-06 at 01 06 14" src="https://github.com/user-attachments/assets/5f77fd84-721c-446f-908d-6bd124c876b0" width="450" height="750" />
  <h3>AI-Powered Driver Safety Monitoring</h3>
  <p>Advanced computer vision technology to detect fatigue and drowsiness in real-time</p>
</div>

---

## 📱 Screenshots

<div align="center">
  <img src="screenshots/main-screen.png" alt="Main Detection Screen" width="300">
  <img width="706" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-06 at 01 06 14" src="https://github.com/user-attachments/assets/67155f31-0463-4d82-9aed-c0e64bceb327" />

  <img src="screenshots/statistics.png" alt="Statistics Dashboard" width="300">
  <img src="screenshots/trip-history.png" alt="Trip History" width="300">
  <img src="screenshots/settings.png" alt="Settings Screen" width="300">
</div>

*Screenshots showing the main detection interface, analytics dashboard, trip history, and settings*

---

## 🎯 Features

### 🔍 Real-Time Monitoring
- **Face Detection**: Advanced facial recognition using Apple's Vision framework
- **Eye Tracking**: Monitors blink rate and eye closure duration
- **Yawn Detection**: Identifies mouth movements indicating drowsiness
- **Head Position Analysis**: Tracks head movement and positioning

### 🚨 Smart Alert System
- **Multi-Level Alerts**: Normal → Warning → Danger progression
- **Customizable Sensitivity**: Adjust detection thresholds to your preference
- **Haptic Feedback**: Physical alerts for critical situations
- **Audio Alerts**: Optional sound notifications
- **Visual Indicators**: Clear on-screen status displays

### 📊 Analytics & Insights
- **Trip Recording**: Automatic logging of driving sessions
- **Safety Scores**: Comprehensive scoring based on multiple factors
- **Fatigue Trends**: Historical analysis of alertness patterns
- **Detailed Metrics**: Blink counts, yawn frequency, reaction times
- **Performance Tracking**: Monitor improvement over time

### 🆘 Emergency Features
- **SOS Button**: One-tap emergency alert system
- **Emergency Contacts**: Notify designated contacts in critical situations
- **Location Sharing**: Share current location during emergencies
- **Automatic Alerts**: System can trigger alerts for prolonged dangerous states

### ⚙️ Customization
- **Alert Sensitivity**: Fine-tune detection parameters
- **Personal Calibration**: Customize for individual facial features
- **Privacy Controls**: All processing done locally on device
- **Dark Mode Support**: Optimized for night driving
- **Cross-Platform**: Works on both iOS and macOS

---

## 🏗️ Technical Architecture

### Core Components

#### `AlertnessDetector.swift`
The heart of the application containing:
- **Vision Framework Integration**: Face landmark detection
- **Real-time Analysis**: Continuous monitoring algorithms
- **Alert Logic**: Multi-threshold detection system
- **Data Models**: Trip recording and statistics

#### `ContentView.swift`
Main interface featuring:
- **Live Camera Feed**: Real-time video preview
- **Status Dashboard**: Current alertness indicators
- **Glassmorphic UI**: Modern, translucent design elements
- **Tab Navigation**: Organized feature access

#### `CameraPreviewView.swift`
Cross-platform camera implementation:
- **iOS Support**: UIKit integration
- **macOS Support**: AppKit compatibility
- **AVFoundation**: Camera session management

### Detection Algorithms

```swift
// Eye Aspect Ratio (EAR) Calculation
private func calculateEyeOpenness(eyePoints: [CGPoint]) -> Float {
    let verticalDist1 = abs(p1.y - p5.y)
    let verticalDist2 = abs(p2.y - p6.y)
    let horizontalDist = abs(p3.x - p4.x)
    
    let ear = (verticalDist1 + verticalDist2) / (2.0 * horizontalDist)
    return Float(max(0.0, min(1.0, ear)))
}

// Mouth Aspect Ratio (MAR) for Yawn Detection
private func calculateMouthOpenness(mouthPoints: [CGPoint]) -> Float {
    let verticalDist = abs(topMouth.y - bottomMouth.y)
    let horizontalDist = abs(leftMouth.x - rightMouth.x)
    
    let mar = verticalDist / horizontalDist
    return Float(max(0.0, min(1.0, mar)))
}
```

---

## 🚀 Installation & Setup

### Prerequisites
- **Xcode 15.0+**
- **iOS 17.0+ / macOS 14.0+**
- **Camera permissions**
- **Device with front-facing camera**

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/Driver_Alertness_Detection.git
   cd Driver_Alertness_Detection
   ```

2. **Open in Xcode**
   ```bash
   open Driver_Alertness_Detection.xcodeproj
   ```

3. **Configure Signing**
   - Select your development team
   - Update bundle identifier if needed
   - Ensure camera permissions are configured

4. **Build and Run**
   - Select target device/simulator
   - Press ⌘+R to build and run

### Permissions Configuration

The app requires camera access for facial detection. Permissions are automatically requested on first launch, but you can also:

1. Go to **Settings > Privacy & Security > Camera**
2. Enable access for **Driver Alertness Detection**

---

## 🎮 Usage Guide

### Getting Started

<img src="screenshots/getting-started.png" alt="Getting Started Flow" width="600">

1. **Launch the App**: Open Driver Alertness Detection
2. **Grant Permissions**: Allow camera access when prompted
3. **Position Yourself**: Ensure face is clearly visible in camera
4. **Start Monitoring**: Tap the monitoring toggle to begin

### Main Interface

<img src="screenshots/main-interface-annotated.png" alt="Main Interface" width="600">

The main screen displays:
- **Live Camera Feed**: Your face with detection overlays
- **Alert Status**: Current safety level (Safe/Warning/Danger)
- **Detection Indicators**: Face, eyes, yawn, and head position status
- **Emergency Button**: Quick access to SOS features

### Understanding Alert Levels

| Level | Indicator | Description | Action |
|-------|-----------|-------------|--------|
| 🟢 **Safe** | Green | Normal alertness detected | Continue driving safely |
| 🟡 **Warning** | Orange | Signs of fatigue detected | Take precautions |
| 🔴 **Danger** | Red | Unsafe to continue driving | **STOP DRIVING** |

### Statistics Dashboard

<img src="screenshots/statistics-annotated.png" alt="Statistics Dashboard" width="600">

Track your performance with:
- **Daily Metrics**: Driving time, warnings, safety score
- **Trend Analysis**: Fatigue patterns over time
- **Detailed Analytics**: Blink rates, reaction times, yawn frequency

---

## 🔧 Customization

### Alert Sensitivity

<img src="screenshots/sensitivity-settings.png" alt="Sensitivity Settings" width="400">

Adjust detection sensitivity in **Settings > Alert Settings**:
- **Low**: Less sensitive, fewer false alerts
- **Medium**: Balanced detection (recommended)
- **High**: Maximum sensitivity, earliest warnings

### Personal Calibration

<img src="screenshots/calibration-flow.png" alt="Calibration Process" width="600">

Personalize detection for your unique features:

1. Go to **Settings > Safety Features > Calibrate Detection**
2. Follow the 3-step calibration process:
   - **Step 1**: Face positioning
   - **Step 2**: Eye movement patterns
   - **Step 3**: Yawn detection calibration

### Privacy Settings

All facial processing is performed locally on your device:
- ✅ **No data transmitted** to external servers
- ✅ **No video recording** or storage
- ✅ **Complete privacy** of biometric data
- ✅ **Export/delete data** anytime

---

## 📊 Data & Analytics

### Trip Recording

Every driving session is automatically recorded with:
- **Start/End Times**: Precise trip duration
- **Safety Metrics**: Warnings, dangers, overall score
- **Fatigue Analysis**: Maximum fatigue level reached
- **Performance Trends**: Improvement tracking

### Statistics Overview

<img src="screenshots/analytics-dashboard.png" alt="Analytics Dashboard" width="600">

#### Key Metrics
- **Total Driving Time**: Cumulative monitoring time
- **Safety Score**: Overall performance rating (0-100%)
- **Warning Count**: Number of fatigue warnings
- **Trip History**: Detailed session records

#### Trend Analysis
- **Daily Patterns**: Best/worst driving times
- **Weekly Progress**: Performance improvements
- **Fatigue Correlation**: Factors affecting alertness

---

## 🔒 Privacy & Security

### Data Protection
- **Local Processing**: All AI/ML computations on-device
- **No Cloud Storage**: Trip data stored locally only
- **Zero Biometric Upload**: Facial data never leaves device
- **User Control**: Complete data ownership and management

### Permissions
| Permission | Purpose | Required |
|------------|---------|----------|
| Camera | Facial detection and monitoring | ✅ Yes |
| Photos | Export trip data (optional) | ⚪ Optional |
| Notifications | Alert delivery | ⚪ Optional |

---

## 🛠️ Technical Specifications

### System Requirements
- **iOS**: 17.0 or later
- **macOS**: 14.0 or later
- **RAM**: Minimum 4GB (8GB recommended)
- **Storage**: 50MB app size + data storage
- **Camera**: Front-facing camera required

### Performance Optimization
- **Real-time Processing**: 30 FPS face detection
- **Battery Efficient**: Optimized algorithms for extended use
- **Background Mode**: Continues monitoring when app is active
- **Memory Management**: Efficient resource utilization

### Compatibility
| Feature | iOS | macOS |
|---------|-----|-------|
| Face Detection | ✅ | ✅ |
| Camera Access | ✅ | ✅ |
| Haptic Feedback | ✅ | ❌ |
| Notifications | ✅ | ✅ |
| Background Processing | ✅ | ✅ |

---

## 🤝 Contributing

We welcome contributions to improve driver safety technology!

### Development Setup
1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Follow Swift coding standards
4. Add tests for new functionality
5. Submit pull request

### Areas for Contribution
- [ ] Additional detection algorithms
- [ ] UI/UX improvements
- [ ] Performance optimizations
- [ ] Accessibility features
- [ ] Localization support

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Driver Safety Solutions

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🆘 Support

### Troubleshooting

#### Camera Issues
- **No camera preview**: Check camera permissions in Settings
- **Poor detection**: Ensure good lighting and clear face visibility
- **App crashes**: Restart app and ensure adequate device memory

#### Performance Issues
- **Slow detection**: Close background apps to free memory
- **Battery drain**: Use optimized settings in low-power situations
- **Overheating**: Take breaks during extended monitoring sessions

---

## 🙏 Acknowledgments

- **Apple Vision Framework**: Core facial detection technology
- **SwiftUI Community**: UI/UX inspiration and best practices
- **Safety Research**: Academic papers on driver fatigue detection
- **Beta Testers**: Early adopters who helped refine the experience

---

## 📱 Download

<div align="center">
  <a href="https://apps.apple.com/app/driver-alertness-detection/id123456789">
    <img src="screenshots/app-store-badge.png" alt="Download on App Store" width="200">
  </a>
</div>

**Version 1.0** - Available soon on the App Store

---

<div align="center">
  <h3>🚗 Drive Safe. Stay Alert. Arrive Alive. 🚗</h3>
  <p>Developed By Sourabh Chauhan for safer roads</p>
</div> 
