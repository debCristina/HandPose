//
//  File.swift
//  HandTeste
//
//  Created by Débora Cristina Silva Ferreira on 25/09/25.
//

import Foundation
import Vision

class HandPoseHandler {
    private let model: HandGestures
    
    private let handPoseRequest: VNDetectHumanHandPoseRequest  = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    
    init() throws {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU
        self.model = try HandGestures(configuration: config)
    }
    
    func predictHandState(from observation: VNHumanHandPoseObservation) -> (HandState, Double)? {
        guard let keyPointsMultiArray = try? observation.keypointsMultiArray() else { return nil }
        
        do{
            let prediction = try model.prediction(poses: keyPointsMultiArray)
            let confidence = prediction.labelProbabilities[prediction.label] ?? 0.0
            
            guard confidence > 0.9 else { return nil }
            
            switch prediction.label {
            case "aberta": return (.open, confidence)
            case "fechada": return (.closed, confidence)
            default: return (.unknown, confidence)
            }
        } catch{
            print("Failure HandyModel: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getRequest() -> VNDetectHumanHandPoseRequest {
        return handPoseRequest
    }
    
    
}
