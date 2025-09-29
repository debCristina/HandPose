//
//  File.swift
//  HandTeste
//
//  Created by Débora Cristina Silva Ferreira on 25/09/25.
//

import Foundation
import Vision

/// `HandPoseHandler` integra o Vision e o modelo CoreML `HandGestures6`
///  para detextar e classificar o estado da mão (aberta, fechada ou desconhecida)
///
class HandPoseHandler {
    
    /// Modelo CoreML usado para classificar os gestos da mão.
    private let model: HandGestures6
    
    /// Request do Vision configurada para detectar até uma mão por vez.
    private let handPoseRequest: VNDetectHumanHandPoseRequest  = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1
        return request
    }()
    
    /// Inicializa o modelo `HandGestures6` com suporte a CPU e GPU.
    init() throws {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU
        self.model = try HandGestures6(configuration: config)
    }
    
    /// Recebe uma observação de pose da mão detectada pelo Vision e classifica
    /// o estado da mão utilizando o modelo CoreML.
    ///
    /// - Parameter observation: A observação da mão retornada pelo Vision.
    /// - Returns: Uma tupla com o estado da mão (`.open`, `.closed`, `.unknown`)
    ///   e o nível de confiança da predição. Retorna `nil` se a confiança < 0.9
    ///   ou se a predição falhar.
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
    
    /// Retorna a request do Vision configurada para detectar uma mão.
    ///
    /// - Returns: Uma instância de `VNDetectHumanHandPoseRequest`.
    func getRequest() -> VNDetectHumanHandPoseRequest {
        return handPoseRequest
    }
}
