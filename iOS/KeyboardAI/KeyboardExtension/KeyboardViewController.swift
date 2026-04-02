import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardMainView>?
    private var keyboardViewModel: KeyboardViewModel?
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        let vm = KeyboardViewModel()
        vm.inputProxy = textDocumentProxy
        vm.advanceToNextInput = { [weak self] in
            self?.advanceToNextInputMode()
        }
        self.keyboardViewModel = vm

        let keyboardView = KeyboardMainView(viewModel: vm)
        let hc = UIHostingController(rootView: keyboardView)
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        hc.view.backgroundColor = .clear

        addChild(hc)
        view.addSubview(hc.view)
        hc.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hc.view.topAnchor.constraint(equalTo: view.topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.hostingController = hc

        // Set an explicit height so iOS knows the keyboard has content
        let hc2 = view.heightAnchor.constraint(equalToConstant: 300)
        hc2.priority = .defaultHigh
        hc2.isActive = true
        self.heightConstraint = hc2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardViewModel?.inputProxy = textDocumentProxy
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardViewModel?.inputProxy = textDocumentProxy
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        keyboardViewModel?.inputProxy = textDocumentProxy
        keyboardViewModel?.updateCurrentText()
    }
}
