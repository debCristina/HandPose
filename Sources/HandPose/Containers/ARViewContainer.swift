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

///`ARViewContainer` é o ponto de entrada do package para a sua aplicação SwiftUI.
///
/// `ARViewContainer` é um wrapper SwiftUI que integra um `ARViewController`
/// dentro de uma interface SwiftUI.
///
/// Ele permite que o estado da mão detectado pelo AR seja transmitido para
/// SwiftUI através do binding `currentHandState`, e controla a exibição da
/// visualização AR com o binding `showPreview`.
///
/// ### Bindings:
/// - `showPreview`: controla se a visualização AR deve ser exibida.
/// - `currentHandState`: recebe atualizações do estado da mão detectado pelo AR.
///
/// ### Funcionalidades:
/// - `makeUIViewController`: cria e configura o `ARViewController`, incluindo
///   o callback `onHandStateChanged` para atualizar o binding `currentHandState`.
/// - `updateUIViewController`: mantém o binding `showPreview` sincronizado
///   com o `ARViewController`.
///
/// ### Como implementar:
/// ```swift
/// // Modifique o preview da câmera de acordo com a sua preferência.
/// @State private var showPreview = true
/// // Preferível inicializar a variável como .unknown
/// @State private var handState: HandState = .unknown
///
///var body: some View {
///     ARViewContainer(showPreview: $showPreview, currentHandState: $handState)
/// }
/// ```
///
/// ### Informações complemantares
/// - Você pode manipular o tamanho do preview da câmera.
///```swift
///var body: some View {
///     ARViewContainer(showPreview: $showPreview, currentHandState: $handState).frame(width: width, height: height)
/// }
/// ```
/// - Não da para finzalizar a câmera depois que ela foi instanciada, não venha me perguntar nada sobre isso.
public struct ARViewContainer: UIViewControllerRepresentable {
    /// `showPreview`: é um binding com valor Booleano que controla se a visualização AR deve ser exibida.
    @Binding var showPreview: Bool
    
    /// `currentHandState`: é uma variável que controla o estado atual da mão detectado.
    @Binding var currentHandState: HandState
    
    var camera = CGRect()
    
    /// ARViewController responsável pelo funcionamento interno
    /// do reconhecimento de gestos.
    let arViewController: ARViewController
    
    /// Inicializa um `ARViewContainer` com bindings para SwiftUI.
    ///
    /// - Parameters:
    ///   - showPreview: Binding que controla se a visualização AR deve ser exibida.
    ///   - currentHandState: Binding que recebe atualizações do estado da mão detectado.
    public init(showPreview: Binding<Bool>, currentHandState: Binding<HandState>) {
        self._showPreview = showPreview
        self._currentHandState = currentHandState
        self.arViewController = ARViewController(cameraFrame: camera, showPreview: showPreview.wrappedValue)

    }
    
    /// Cria e configura o `ARViewController` para uso em SwiftUI.
    ///
    /// - Parameters:
    ///   - context: O contexto da UIViewControllerRepresentable.
    /// - Returns: Uma instância configurada de `ARViewController` com callback
    ///   para atualizar `currentHandState`.
    public func makeUIViewController(context: Context) -> some UIViewController {
        arViewController.showPreview = showPreview
        arViewController.onHandStateChanged = {  newState in
            DispatchQueue.main.async {
                self._currentHandState.wrappedValue = newState
            }
        }
        return arViewController
    }
    
    /// Atualiza o `ARViewController` quando os bindings SwiftUI mudam.
    ///
    /// - Parameters:
    ///   - uiViewController: O `UIViewController` gerenciado (ARViewController).
    ///   - context: O contexto da UIViewControllerRepresentable.
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let viewController = uiViewController as? ARViewController
        viewController?.showPreview = showPreview
    }
    

}
