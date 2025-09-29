//
//  File.swift
//  HandTeste
//
//  Created by Débora Cristina Silva Ferreira on 25/09/25.
//

import Foundation
import ARKit


public class ARViewController: UIViewController, @MainActor ARSessionDelegate {
    private var arView: ARSCNView!
    public var showPreview = false
    private var frameCounter = 0
    private let handPosePredictionInterval = 20
    public var currentHandState: HandState = .unknown
    var onHandStateChanged: ((HandState) -> Void)?
    private var handPoseHandler: HandPoseHandler!
    
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
        arView = ARSCNView(frame: view.bounds)
        arView.session.delegate = self
        
        if showPreview {
            view.addSubview(arView)
        }
        // generak world tracking
        
        let configuration = ARWorldTrackingConfiguration()
        
        // enable the front camera
        if ARFaceTrackingConfiguration.isSupported {
            let faceTrackingConfig = ARFaceTrackingConfiguration()
            arView.session.run(faceTrackingConfig)
        } else {
            // not supported
            // show an alert
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
