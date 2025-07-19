# Driver Alertness Detection App

A real-time iOS application that monitors driver alertness using computer vision and facial analysis to detect signs of fatigue or impairment, helping improve road safety.

## Features

### 🎯 Real-time Detection
- **Face Detection**: Continuous monitoring using front-facing camera
- **Eye Closure Analysis**: Detects when eyes are closed for extended periods (>2 seconds)
- **Yawning Detection**: Identifies yawning patterns indicating fatigue
- **Behavioral Analysis**: Monitors for signs of disorientation or impairment

### 🚨 Alert System
- **Three Alert Levels**:
  - 🟢 **Normal**: Alert & Safe to drive
  - 🟡 **Warning**: Showing signs of fatigue
  - 🔴 **Danger**: Unsafe to drive - immediate break recommended

### 📱 User Interface
- **Modern SwiftUI Design**: Clean, intuitive interface
- **Real-time Camera Feed**: Live preview with detection overlay
- **Status Indicators**: Visual feedback for all detection states
- **Haptic Feedback**: Device vibration for critical alerts

### 🔧 Technical Implementation
- **iOS Vision Framework**: Advanced face landmark detection
- **AVFoundation**: Camera integration and video processing
- **Real-time Processing**: Efficient frame-by-frame analysis
- **Privacy-First**: All processing done locally on device

## Technology Stack

- **SwiftUI**: Modern UI framework
- **Vision Framework**: Apple's machine learning framework for computer vision
- **AVFoundation**: Camera and media handling
- **Core ML**: Machine learning model integration
- **Combine**: Reactive programming framework

## How It Works

### Detection Algorithm

1. **Face Detection**: Uses Vision framework to detect faces in real-time
2. **Landmark Analysis**: Identifies 68 facial landmarks including eyes and mouth
3. **Eye Aspect Ratio (EAR)**: Calculates eye openness based on landmark positions
4. **Mouth Aspect Ratio (MAR)**: Measures mouth opening to detect yawning
5. **Temporal Analysis**: Tracks duration of eye closure and yawning
6. **Alert Generation**: Triggers warnings based on configurable thresholds

### Safety Thresholds

- **Eye Closure**: Alert triggered after 2+ seconds of closed eyes
- **Yawning**: Alert triggered after 1.5+ seconds of mouth opening
- **Face Detection**: Warning if no face detected for 3+ seconds

## Installation & Setup

### Prerequisites
- iOS 14.0+
- iPhone with front-facing camera
- Xcode 12.0+

### Building the App
1. Clone the repository
2. Open in Xcode
3. Build and run on iOS device (camera required)

### Permissions
The app requires camera access. Permission is requested automatically on first launch.

## Usage

1. **Launch the App**: Open the Driver Alertness Detection app
2. **Grant Camera Permission**: Allow camera access when prompted
3. **Position Your Device**: Mount device where front camera can see your face
4. **Start Detection**: Tap "Start Detection" button
5. **Monitor Alerts**: Watch for visual and haptic feedback
6. **Take Breaks**: Follow recommendations when alerts are triggered

## Safety Features

- **Automatic Detection**: No user interaction required during monitoring
- **Visual Alerts**: Color-coded interface changes
- **Haptic Feedback**: Device vibration for critical alerts
- **Real-time Processing**: Immediate feedback on driver state

## Privacy & Security

- **Local Processing**: All analysis performed on-device
- **No Data Collection**: No facial data stored or transmitted
- **Camera Access Only**: Minimal permissions required
- **Secure Framework**: Uses Apple's Vision framework

## File Structure

```
Driver_Alertness_Detection/
├── ContentView.swift              # Main SwiftUI interface
├── AlertnessDetector.swift        # Core detection logic
├── CameraPreviewView.swift        # Camera preview component
├── Info.plist                     # App configuration & permissions
├── Assets.xcassets/              # App icons and images
└── Driver_Alertness_DetectionApp.swift  # App entry point
```

## Key Components

### AlertnessDetector
- Core class managing face detection and behavioral analysis
- Integrates with Vision framework for real-time processing
- Manages camera session and video output
- Calculates eye aspect ratio (EAR) and mouth aspect ratio (MAR)

### CameraPreviewView
- SwiftUI wrapper for AVCaptureVideoPreviewLayer
- Displays real-time camera feed
- Handles view lifecycle and layout updates

### ContentView
- Main user interface
- Real-time status display
- Alert visualizations and controls

## Future Enhancements

- [ ] Head pose estimation for distraction detection
- [ ] Calibration for individual users
- [ ] Voice alerts and notifications
- [ ] Integration with car systems
- [ ] Driving pattern analysis
- [ ] Multiple face detection support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add appropriate tests
5. Submit a pull request

## License

This project is developed for educational and safety purposes. Please ensure compliance with local regulations regarding driver monitoring systems.

## Disclaimer

This app is designed as a safety aid and should not be the sole method of ensuring driver alertness. Always prioritize proper rest and responsible driving practices.

---

**Stay Alert, Stay Safe! 🚗✨** 