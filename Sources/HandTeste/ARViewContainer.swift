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
     let arViewController = ARViewController()
    
    
    public init(showPreview: Binding<Bool>) {
        self._showPreview = showPreview
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        arViewController.showPreview = showPreview
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
