//
//  File.swift
//  HandTeste
//
//  Created by Débora Cristina Silva Ferreira on 25/09/25.
//

#if canImport(UIKit)
import Foundation
import UIKit
import ARKit

class ARViewController: UIViewController, ARSessionDelegate {
    private var frameCounter = 0
    private let handPosePredictionInterval = 30
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        frameCounter += 1
        let pixelBuffer = frame.capturedImage
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectContourRequestRevision1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Human Pose Request failed: \(error.localizedDescription)")
        }
        
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {
            // no effects to draw
            return
        }
        
        let handObservations = handPoses.first
        
        
        if frameCounter % handPosePredictionInterval == 0 {
            guard let keypointsMultiArray = try? handObservations!.keypointsMultiArray() else {
                fatalError("Failed to create key points array")
            }
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .cpuAndGPU
                // ML model version setup
                let model = try HandGestures.init(configuration: config)
                
                let handPosePrediction = try model.prediction(poses: keypointsMultiArray)
                let confidence = handPosePrediction.labelProbabilities[handPosePrediction.label]!
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.thirdLabel.text = "\(self.convertToPercentage(confidence))%"
                }
                print("labelProbabilities \(handPosePrediction.labelProbabilities)")
                
                if confidence > 0.9 {
                    print("handPosePrediction: \(handPosePrediction.label)")
                    renderHandPose(name: handPosePrediction.label)
                } else {
                    print("handPosePrediction: \(handPosePrediction.label)")
                    cleanEmojii()
                    
                }
                
            } catch let error {
                print("Failure HandyModel: \(error.localizedDescription)")
            }
        }
    }
}
#endif

