import SwiftUI
import UIKit

public class AsgardChatbotVC: UIHostingController<AsgardChatbotView> {
    
    private let theme: AsgardThemeConfig
    
    public init(viewModel: AsgardChatbotViewModel, isModal: Bool = true) {
        self.theme = viewModel.uiConfig.theme
        super.init(rootView: AsgardChatbotView(viewModel: viewModel, isModal: isModal))
        self.title = viewModel.uiConfig.title
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var isModal: Bool {
        if let nav = navigationController {
            if nav.viewControllers.first == self && presentingViewController != nil {
                return true // from present
            }
            return false // from push
        }
        return presentingViewController != nil
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let leftButton: UIBarButtonItem
        if isModal {
            leftButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.down"),
                style: .plain,
                target: self,
                action: #selector(closeTapped)
            )
        } else {
            leftButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(closeTapped)
            )
        }
        leftButton.tintColor = UIColor(theme.botMessage.textColor)
        navigationItem.leftBarButtonItem = leftButton
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(theme.chatbot.backgroundColor)
        let textColor = UIColor(theme.botMessage.textColor)
        navBarAppearance.titleTextAttributes = [.foregroundColor: textColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance
        self.view.backgroundColor = UIColor(theme.chatbot.backgroundColor)
        navigationController?.view.backgroundColor = UIColor(theme.chatbot.backgroundColor)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
        navigationController?.navigationBar.compactAppearance = defaultAppearance
    }

    @objc private func closeTapped() {
        if isModal {
            self.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
} 
