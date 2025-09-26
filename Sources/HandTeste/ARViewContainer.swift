//
//  File.swift
//  HandTeste
//
//  Created by Débora Cristina Silva Ferreira on 26/09/25.
//

import Foundation
import ARKit
import UIKit
import SwiftUI

public struct ARViewContainer: UIViewControllerRepresentable {
    @Binding var showPreview: Bool
    @Binding var currentHandState: HandState
     let arViewController = ARViewController()
    
    
    public init(showPreview: Binding<Bool>, currentHandState: Binding<HandState>) {
        self._showPreview = showPreview
        self._currentHandState = currentHandState
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        arViewController.showPreview = showPreview
        arViewController.onHandStateChanged = {  newState in
            DispatchQueue.main.async {
                self._currentHandState.wrappedValue = newState
            }
        }
        return arViewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let viewController = uiViewController as? ARViewController
        viewController?.showPreview = showPreview
    }
    
    public func getCurrentHandState() -> HandState {
        return arViewController.currentHandState
    }
    
    public func startCamera() {
        arViewController.startCamera()
    }
    
    public func stopCamera() {
        arViewController.stopCamera()
    }
}
