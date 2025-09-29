//
//  File.swift
//  HandTeste
//
//  Created by Débora Cristina Silva Ferreira on 25/09/25.
//

import Foundation
import ARKit
import AVFoundation
import Vision


public class ARViewController: UIViewController, @MainActor ARSessionDelegate {
    public var arView: ARSCNView!
    public var showPreview = false
    private var frameCounter = 0
    private let handPosePredictionInterval = 20
    public var currentHandState: HandState = .unknown
    public var onHandStateChanged: ((HandState) -> Void)?
    private var handPoseHandler: HandPoseHandler!
    public var cameraFrame: CGRect

    public init(cameraFrame: CGRect, showPreview: Bool) {
        self.cameraFrame = cameraFrame
        self.showPreview = showPreview
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        do {
            handPoseHandler = try HandPoseHandler()
        } catch {
            fatalError("Failed to init HandPoseHandler: \(error)")
        }
        setupARView(showPreview: showPreview)
    }
    
    func setupARView(showPreview: Bool) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: createARView(showPreview: showPreview)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { enabled in
                DispatchQueue.main.async {
                    if enabled {
                        self.createARView(showPreview: showPreview)
                    } else {
                        print("Camera access denied")
                    }
                }
            }
        case .denied, .restricted:
            print("Camera access denied")

        @unknown default:
            print("Unknown camera authorization status")
        }
    }
    
    
    func createARView(showPreview: Bool) {
        
        arView = ARSCNView(frame: cameraFrame)
        arView.session.delegate = self
        
        if showPreview {
            view.addSubview(arView)
        }
        
        let configuration = ARWorldTrackingConfiguration()
        if ARFaceTrackingConfiguration.isSupported {
            let faceTrackingConfig = ARFaceTrackingConfiguration()
            arView.session.run(faceTrackingConfig)
        } else {
            arView.session.run(configuration)
        }
    }
    
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCounter += 1
        
        if frameCounter % handPosePredictionInterval != 0 {
            return
        }
        
        let pixelBuffer = frame.capturedImage
        let request = handPoseHandler.getRequest()
        request.revision = VNDetectHumanHandPoseRequestRevision1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        }  catch {
            assertionFailure("Human Pose Request failed: \(error.localizedDescription)")
        }
        
        guard let handPoses = request.results, !handPoses.isEmpty else {
            return
        }
        
        if let handObservation = handPoses.first,
           let (state, _) = handPoseHandler.predictHandState(from: handObservation) {
            changeHandState(name: state)
        }
    }
    
    private func changeHandState(name: HandState) {
        currentHandState = name
        onHandStateChanged?(name)
        
        switch name {
        case .open:
            print("Mão aberta detectada!")
        case .closed:
            print("Mão fechada detectada!")
        case .unknown:
            break
        }
    }
}

