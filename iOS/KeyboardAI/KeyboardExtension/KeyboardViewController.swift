import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    
    private var hostingController: UIHostingController<KeyboardMainView>?
    private let keyboardViewModel = KeyboardViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardViewModel.inputProxy = textDocumentProxy
        keyboardViewModel.advanceToNextInput = { [weak self] in
            self?.advanceToNextInputMode()
        }
        
        let keyboardView = KeyboardMainView(viewModel: keyboardViewModel)
        let hostingController = UIHostingController(rootView: keyboardView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.hostingController = hostingController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardViewModel.inputProxy = textDocumentProxy
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        keyboardViewModel.inputProxy = textDocumentProxy
        keyboardViewModel.updateCurrentText()
    }
}
