//
//  EnvironmentChanger.swift
//  Created by Teodor Marinov on 1.07.19.
//
import UIKit

private class EnvironmentChangerWindow: UIWindow {
    var button: UIButton?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let button = button else { return false }
        let buttonPoint = convert(point, to: button)
        return button.point(inside: buttonPoint, with: event)
    }
}

/// Enum cases for configuration of the layout of the floating button.
enum ButtonConfiguration {
    
    /// Configure the button layout with title.
    case title(String)
    
    /// Configure the button layout with image.
    case image(UIImage)
}

/// Protocol defining the needed behaviour of the `Envs` enum.
/// Each enum case should provide `String` representing the environment title.
public protocol EnvironmentRepresentable {
    
    /// This string is later on used for persisting the selected enviornment.
    /// `String` representing the environment title.
    var environmentTitle: String { get }
}

class EnvironmentChangerController<T>: UIViewController where T: EnvironmentRepresentable, T: CaseIterable {
    class EnvAlertAction: UIAlertAction {
        var selectedEnv: T?
    }
    
    var envs: T.Type!
    var completionHandler: ((T) -> Void)!
    
    private let ACTIVE_ENV_KEY = "CURRENT_SAVED_ENVIRONMENT"
    private let window = EnvironmentChangerWindow()
    private(set) var button: UIButton!
    private var buttonConfiguration: ButtonConfiguration!
    
    /// Instantiate with the object of environments you would like to access.
    ///
    /// - Parameters:
    ///   - envs: 'T' of type String, CaseIterable object that should preferably have environments inside.
    ///   - buttonConfiguration: Sets the button title or image that will be displayed.
    ///   - completionHandler: Add any logic you would want to execute after you selected your new environment in the completionHandler.
    /// - Note:
    ///   - If no buttonConfiguration in the constructor by default it will set the title to 'EN'.
    ///   - Saves the first environment passed in to avoid getSavedEnvironment() to return an empty string.
    public init(envs: T.Type,
                buttonConfiguration: ButtonConfiguration = .title("EN"),
                completionHandler: @escaping (T) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.envs = envs
        self.buttonConfiguration = buttonConfiguration
        self.completionHandler = completionHandler
        
        setupWindow()
        saveFirstEnvironment()
    }
    
    override func loadView() {
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func getSavedEnvironment() -> String {
        return UserDefaults.standard.string(forKey: ACTIVE_ENV_KEY) ?? ""
    }
    
    /// Resizing the whole button.
    ///
    /// - Parameters:
    ///   - newWidth: Enter the new width you would like to set.
    ///   - newHeight: Enter the new height you would like to set.
    /// - Note:
    ///   - imageEdgeInsets are calculated and set as '(height + width) / 2',
    ///     to avoid having inaccurate button image and size.
    func resizeFrame(newWidth: CGFloat, newHeight: CGFloat) {
        let imageEdgeInsets = (newWidth + newHeight) / 2
        
        button.frame.size.width = newWidth
        button.frame.size.height = newHeight
        button.imageEdgeInsets = UIEdgeInsets(top: imageEdgeInsets, left: imageEdgeInsets, bottom: imageEdgeInsets, right: imageEdgeInsets)
    }
    
    /// When initializing the controller with the given environments,
    /// saves the first found environment from the list to UserDefaults.
    private func saveFirstEnvironment() {
        guard let firstEnvironment = envs.allCases.first else { return }
        
        if getSavedEnvironment() == "" {
            UserDefaults.standard.set(firstEnvironment.environmentTitle, forKey: ACTIVE_ENV_KEY)
        }
    }
    
    /// Sets the window level to the highest magnitude so that it will display always on top.
    private func setupWindow() {
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        window.button?.addTarget(self, action: #selector(environmentButtonTapped), for: .touchUpInside)
    }
    
    /// Configuration of the button and view.
    private func setupUI() {
        let view = UIView()
        let button = UIButton(type: .custom)
        
        DispatchQueue.main.async { [weak self] in
            guard let buttonConfiguration = self?.buttonConfiguration else { return }
            switch buttonConfiguration {
            case .title(let title):
                button.setTitle(title, for: .normal)
                button.layer.cornerRadius = 4
                button.layer.borderWidth = 1
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .gray
                return
            case .image(let image):
                button.setImage(image, for: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
                button.imageView?.contentMode = .scaleAspectFit
            }
        }
        
        button.sizeToFit()
        /// Starting point of the button is always in the top left corner.
        button.frame = CGRect(origin: CGPoint(x: view.frame.minX + 20, y: view.frame.minY + 20), size: button.bounds.size)
        view.addSubview(button)
        self.view = view
        self.button = button
        window.button = button
        
        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire))
        button.addGestureRecognizer(panner)
    }
    
    /// Action handler for the pressed alert.
    ///
    /// - Parameter sender: Reads the sender as 'EnvAlertAction', so that you can pass the 'T' object in the completion handler.
    /// - Caches the rawValue of the object in UserDefaults if the user wants to use it.
    /// - Returns: Passes 'T' object to completionhandler.
    private func actionHandler(sender: UIAlertAction) {
        guard let envAlertAction = sender as? EnvAlertAction,
            let selectedEnv = envAlertAction.selectedEnv else { return }
        UserDefaults.standard.set(selectedEnv.environmentTitle, forKey: ACTIVE_ENV_KEY)
        
        let alert = UIAlertController(title: "Environment changed successfully.", message: "Please restart the app to access \(selectedEnv.environmentTitle)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        completionHandler(selectedEnv)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        let offset = panner.translation(in: view)
        panner.setTranslation(CGPoint.zero, in: view)
        var center = button.center
        center.x += offset.x
        center.y += offset.y
        button.center = center
    }
    
    @objc func environmentButtonTapped() {
        let alert = UIAlertController(title: "Current env: \(getSavedEnvironment())", message: "Please select a backend environment", preferredStyle: .actionSheet)
        
        envs.allCases.forEach {
            let alertAction = EnvAlertAction(title: $0.environmentTitle, style: .default, handler: actionHandler(sender:))
            alertAction.selectedEnv = $0
            alert.addAction(alertAction)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        /// Configured popover controller for iPad alerts.
        /// Note: Cancel buttons are removed from popovers automatically,
        /// because tapping outside the popover represents "cancel", in a popover context.
        if let popoverController = alert.popoverPresentationController,
            let currentView = UIApplication.shared.keyWindow?.rootViewController?.view {
            popoverController.sourceView = currentView
            popoverController.sourceRect = CGRect(x: currentView.bounds.midX, y: currentView.bounds.midY, width: 0, height: 0)
            /// To hide the arrow of any particular direction.
            popoverController.permittedArrowDirections = []
        }

        /// Prevents from attempting to present the same alert when clicking on the ENV change button.
        if UIApplication.shared.keyWindow?.rootViewController?.presentedViewController == nil {
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
            }
        }
    }
}
