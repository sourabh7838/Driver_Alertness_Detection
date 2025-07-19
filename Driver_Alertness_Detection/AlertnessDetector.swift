import Foundation
import AVFoundation
import Vision
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Alert Level Enum
enum AlertLevel {
    case normal
    case warning
    case danger
    
    var color: Color {
        switch self {
        case .normal:
            return .green
        case .warning:
            return .orange
        case .danger:
            return .red
        }
    }
    
    var displayText: String {
        switch self {
        case .normal:
            return "Alert & Safe"
        case .warning:
            return "Showing Signs of Fatigue"
        case .danger:
            return "⚠️ TAKE A BREAK - UNSAFE TO DRIVE"
        }
    }
    
    var iconName: String {
        switch self {
        case .normal: return "checkmark.shield.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.octagon.fill"
        }
    }
    
    var shortText: String {
        switch self {
        case .normal: return "Safe"
        case .warning: return "Caution"
        case .danger: return "Danger"
        }
    }
}

// MARK: - Daily Stats Model
struct DailyStats {
    var totalDrivingTime: TimeInterval = 0
    var totalWarnings: Int = 0
    var totalDangerAlerts: Int = 0
    var totalBlinks: Int = 0
    var totalYawns: Int = 0
    var averageFatigueScore: Double = 0.0
    var tripsCompleted: Int = 0
}

// MARK: - Trip Record Model
struct TripRecord: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let maxFatigueScore: Double
    let warningCount: Int
    let dangerCount: Int
    let safetyRating: Double
    
    init(startTime: Date, endTime: Date, duration: TimeInterval, maxFatigueScore: Double, warningCount: Int, dangerCount: Int, safetyRating: Double) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.maxFatigueScore = maxFatigueScore
        self.warningCount = warningCount
        self.dangerCount = dangerCount
        self.safetyRating = safetyRating
    }
}

// MARK: - Alertness Detector Class
class AlertnessDetector: NSObject, ObservableObject {
    @Published var faceDetected = false
    @Published var eyesClosed = false
    @Published var yawning = false
    @Published var alertLevel: AlertLevel = .normal
    @Published var isRunning = false
    @Published var fatigueScore: Double = 0.0
    @Published var isSessionRunning = false
    @Published var currentTripDuration: TimeInterval = 0
    @Published var totalBlinks: Int = 0
    @Published var totalYawns: Int = 0
    @Published var averageReactionTime: Double = 0.0
    
    // Trip Recording
    @Published var isRecordingTrip = false
    @Published var tripStartTime: Date?
    @Published var dailyStats = DailyStats()
    @Published var tripHistory: [TripRecord] = []
    
    // Camera and Vision components
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    // Face detection variables
    private var eyeClosedTimer: Timer?
    private var yawnTimer: Timer?
    private var eyeClosedDuration: TimeInterval = 0
    private var yawnDuration: TimeInterval = 0
    private var lastFaceDetectionTime: Date = Date()
    
    // Thresholds for detection
    private let eyeClosedThreshold: TimeInterval = 2.0  // 2 seconds
    private let yawnThreshold: TimeInterval = 1.5       // 1.5 seconds
    private let faceDetectionTimeout: TimeInterval = 3.0 // 3 seconds
    
    // Camera preview layer
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        // Don't setup camera immediately - wait for permission check
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        // Check if camera setup has already been done
        if captureSession.inputs.count > 0 {
            return
        }
        
        // Check camera permission first
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            print("Camera permission not granted")
            return
        }
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get front camera")
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            // Clear any existing inputs/outputs first
            captureSession.beginConfiguration()
            
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            } else {
                print("Cannot add camera input")
                captureSession.commitConfiguration()
                return
            }
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            } else {
                print("Cannot add video output")
                captureSession.commitConfiguration()
                return
            }
            
            captureSession.sessionPreset = .medium
            captureSession.commitConfiguration()
            
            // Create preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            
            print("Camera setup completed successfully")
            
        } catch {
            print("Error setting up camera: \(error)")
            captureSession.commitConfiguration()
        }
    }
    
    // MARK: - Public Methods
    func startDetection() {
        sessionQueue.async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.isRunning = true
                self.isSessionRunning = true
                self.resetDetectionState()
            }
        }
    }
    
    func stopDetection() {
        sessionQueue.async {
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                self.isRunning = false
                self.isSessionRunning = false
                self.resetDetectionState()
            }
        }
    }
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
            startDetection()
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                        self?.startDetection()
                    }
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    }
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
    
    // MARK: - Private Methods
    private func resetDetectionState() {
        faceDetected = false
        eyesClosed = false
        yawning = false
        alertLevel = .normal
        eyeClosedTimer?.invalidate()
        yawnTimer?.invalidate()
        eyeClosedDuration = 0
        yawnDuration = 0
    }
    
    private func updateAlertLevel() {
        let currentTime = Date()
        let timeSinceLastFaceDetection = currentTime.timeIntervalSince(lastFaceDetectionTime)
        
        if !faceDetected || timeSinceLastFaceDetection > faceDetectionTimeout {
            alertLevel = .warning
            return
        }
        
        if eyesClosed && eyeClosedDuration > eyeClosedThreshold {
            alertLevel = .danger
            triggerAlert()
        } else if yawning && yawnDuration > yawnThreshold {
            alertLevel = .danger
            triggerAlert()
        } else if eyesClosed || yawning {
            alertLevel = .warning
        } else {
            alertLevel = .normal
        }
    }
    
    private func triggerAlert() {
        // Haptic feedback (iOS only)
        #if canImport(UIKit)
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        #elseif canImport(AppKit)
        // macOS doesn't have haptic feedback, could play a sound instead
        NSSound.beep()
        #endif
        
        // Could add sound alert here
        print("🚨 ALERT: Driver appears unsafe to drive!")
    }
    
    // MARK: - Face Detection Logic
    private func detectFaces(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Face detection error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation] else {
                DispatchQueue.main.async {
                    self.faceDetected = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.processFaceObservations(observations)
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
    
    private func processFaceObservations(_ observations: [VNFaceObservation]) {
        guard let face = observations.first else {
            faceDetected = false
            updateAlertLevel()
            return
        }
        
        faceDetected = true
        lastFaceDetectionTime = Date()
        
        // Analyze eye closure
        if let landmarks = face.landmarks {
            analyzeEyeClosure(landmarks: landmarks)
            analyzeMouth(landmarks: landmarks)
        }
        
        updateAlertLevel()
    }
    
    private func analyzeEyeClosure(landmarks: VNFaceLandmarks2D) {
        guard let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye else {
            return
        }
        
        let leftEyeOpenness = calculateEyeOpenness(eyePoints: leftEye.normalizedPoints)
        let rightEyeOpenness = calculateEyeOpenness(eyePoints: rightEye.normalizedPoints)
        
        let averageOpenness = (leftEyeOpenness + rightEyeOpenness) / 2
        let eyesClosedThreshold: Float = 0.2
        
        let currentEyesClosed = averageOpenness < eyesClosedThreshold
        
        if currentEyesClosed != eyesClosed {
            eyesClosed = currentEyesClosed
            
            if eyesClosed {
                // Start timer for eye closure duration
                eyeClosedTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                    self?.eyeClosedDuration += 0.1
                }
            } else {
                // Reset timer
                eyeClosedTimer?.invalidate()
                eyeClosedDuration = 0
            }
        }
    }
    
    private func analyzeMouth(landmarks: VNFaceLandmarks2D) {
        guard let mouth = landmarks.outerLips else {
            return
        }
        
        let mouthOpenness = calculateMouthOpenness(mouthPoints: mouth.normalizedPoints)
        let yawnThreshold: Float = 0.04
        
        let currentYawning = mouthOpenness > yawnThreshold
        
        if currentYawning != yawning {
            yawning = currentYawning
            
            if yawning {
                // Start timer for yawn duration
                yawnTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                    self?.yawnDuration += 0.1
                }
            } else {
                // Reset timer
                yawnTimer?.invalidate()
                yawnDuration = 0
            }
        }
    }
    
    private func calculateEyeOpenness(eyePoints: [CGPoint]) -> Float {
        guard eyePoints.count >= 6 else { 
            print("Insufficient eye points: \(eyePoints.count)")
            return 1.0 
        }
        
        // Calculate eye aspect ratio (EAR) with safety checks
        let p1 = eyePoints[1]
        let p2 = eyePoints[5]
        let p3 = eyePoints[2]
        let p4 = eyePoints[4]
        let p5 = eyePoints[0]
        let p6 = eyePoints[3]
        
        let verticalDist1 = abs(p1.y - p5.y)
        let verticalDist2 = abs(p2.y - p6.y)
        let horizontalDist = abs(p3.x - p4.x)
        
        // Avoid division by zero
        guard horizontalDist > 0.001 else {
            return 1.0
        }
        
        let ear = (verticalDist1 + verticalDist2) / (2.0 * horizontalDist)
        return Float(max(0.0, min(1.0, ear))) // Clamp to valid range
    }
    
    private func calculateMouthOpenness(mouthPoints: [CGPoint]) -> Float {
        guard mouthPoints.count >= 12 else { 
            print("Insufficient mouth points: \(mouthPoints.count)")
            return 0.0 
        }
        
        // Calculate mouth aspect ratio with safety checks
        let topMouth = mouthPoints[3]
        let bottomMouth = mouthPoints[9]
        let leftMouth = mouthPoints[0]
        let rightMouth = mouthPoints[6]
        
        let verticalDist = abs(topMouth.y - bottomMouth.y)
        let horizontalDist = abs(leftMouth.x - rightMouth.x)
        
        // Avoid division by zero
        guard horizontalDist > 0.001 else {
            return 0.0
        }
        
        let mar = verticalDist / horizontalDist
        return Float(max(0.0, min(1.0, mar))) // Clamp to valid range
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension AlertnessDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        detectFaces(in: pixelBuffer)
    }
} 