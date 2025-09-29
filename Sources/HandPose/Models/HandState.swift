//
//  File.swift
//  HandTeste
//
//  Created by Débora Cristina Silva Ferreira on 25/09/25.
//

import Foundation

/// `HandState` representa os possíveis estados de uma mão detectada.
public enum HandState {
    /// Mão aberta
    case open
    
    /// Mão fechada
    case closed
    
    ///Estado indefinido ou não reconheciedo
    case unknown
}
