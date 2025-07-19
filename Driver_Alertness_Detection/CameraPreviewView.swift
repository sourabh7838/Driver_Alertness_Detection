import SwiftUI
import AVFoundation

#if canImport(UIKit)
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    let alertnessDetector: AlertnessDetector
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.previewLayer = alertnessDetector.previewLayer
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // Update the preview layer if needed
        if uiView.previewLayer != alertnessDetector.previewLayer {
            uiView.previewLayer = alertnessDetector.previewLayer
        }
    }
}

class CameraPreviewUIView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            if let oldLayer = oldValue {
                oldLayer.removeFromSuperlayer()
            }
            
            if let newLayer = previewLayer {
                layer.addSublayer(newLayer)
                newLayer.frame = bounds
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

#elseif canImport(AppKit)
import AppKit

struct CameraPreviewView: NSViewRepresentable {
    let alertnessDetector: AlertnessDetector
    
    func makeNSView(context: Context) -> CameraPreviewNSView {
        let view = CameraPreviewNSView()
        view.previewLayer = alertnessDetector.previewLayer
        return view
    }
    
    func updateNSView(_ nsView: CameraPreviewNSView, context: Context) {
        // Update the preview layer if needed
        if nsView.previewLayer != alertnessDetector.previewLayer {
            nsView.previewLayer = alertnessDetector.previewLayer
        }
    }
}

class CameraPreviewNSView: NSView {
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            if let oldLayer = oldValue {
                oldLayer.removeFromSuperlayer()
            }
            
            if let newLayer = previewLayer {
                layer?.addSublayer(newLayer)
                newLayer.frame = bounds
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }
}

#endif 