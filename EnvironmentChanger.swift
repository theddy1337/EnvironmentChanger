//
//  EnvironmentChanger.swift
//  BJSCC
//
//  Created by Teodor Marinov on 1.07.19.
//

import Foundation

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

class EnvironmentChangerController<T>: UIViewController where T: RawRepresentable, T.RawValue == String, T: CaseIterable {
    class EnvAlertAction: UIAlertAction {
        var selectedEnv: T?
    }

    var envs: T.Type!
    var completionHandler: ((T) -> Void)!

    private let ACTIVE_ENV_KEY = "CURRENT_SAVED_ENVIRONMENT"
    private let window = EnvironmentChangerWindow()
    private(set) var button: UIButton!
    private var buttonImageString: String?
    private var buttonTitle: String?
    private var buttonImage: UIImage?

    /// Initiate with the object of environments you would like to access.
    ///
    /// - Parameters:
    ///   - envs: 'T' Object that should preferably have environments inside.
    ///   - Optional buttonTitle: Sets the title of the button that will be displayed.
    ///   - Optional buttonImage: Sets the image of the button that will be displayed.
    ///   - Optional buttonImageString: Sets the image of the button that will be displayed
    ///   - completionHandler: Add any logic you would want to execute after you selected your new environment in the completionHandler.
    /// - Note:
    ///   - If no buttonImage or buttonTitle is passed in the constructor by default it will set the title to 'EN'.
    public init(envs: T.Type, buttonImageString: String? = nil, buttonImage: UIImage? = nil, buttonTitle: String? = nil, completionHandler: @escaping (T) -> Void) {
        super.init(nibName: nil, bundle: nil)
        setupWindow()
        self.buttonImageString = buttonImageString
        self.buttonImage = buttonImage
        self.buttonTitle = buttonTitle == nil ? "EN" : buttonTitle
        self.completionHandler = completionHandler
        self.envs = envs
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        setupUI()
    }

    func getSavedEnvironment() -> String {
        guard let savedEnvironment = UserDefaults.standard.string(forKey: ACTIVE_ENV_KEY) else { return "" }

        return savedEnvironment
    }

    /// Sets the window level to the highest magnitude so that it will display always on top.
    private func setupWindow() {
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        window.button?.addTarget(self, action: #selector(environmentButtonTapped), for: .touchUpInside)
    }

    /// Configuration of the button and view
    private func setupUI() {
        let view = UIView()
        let button = UIButton(type: .custom)

        DispatchQueue.main.async { [weak self] in

            if let buttonImageString = self?.buttonImageString {
                self?.setButtonImage(button: button, image: buttonImageString)
            } else if let buttonImage = self?.buttonImage {
                self?.button.setImage(buttonImage, for: .normal)
                button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
                button.imageView?.contentMode = .scaleAspectFit
            } else if let buttonTitle = self?.buttonTitle {
                button.setTitle(buttonTitle, for: .normal)
                button.cornerRadius = 4
                button.borderWidth = 1
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .gray
            }
        }

        button.sizeToFit()
        /// Starting point of the button is always in the top right corner.
        button.frame = CGRect(origin: CGPoint(x: view.frame.minX + 20, y: view.frame.minY + 20), size: button.bounds.size)
        view.addSubview(button)
        self.view = view
        self.button = button
        window.button = button

        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire))
        button.addGestureRecognizer(panner)
    }

    private func setButtonImage(button: UIButton, image: String) {
        guard let image = UIImage(named: image) else { return }

        button.imageEdgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(image, for: .normal)
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
            let alertAction = EnvAlertAction(title: $0.rawValue, style: .default, handler: actionHandler(sender:))
            alertAction.selectedEnv = $0
            alert.addAction(alertAction)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        /// Prevents from attempting to present the same alert when clicking on the ENV change button.
        if UIApplication.shared.keyWindow?.rootViewController?.presentedViewController == nil {
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
            }
        }
    }

    /// Action handler for the pressed alert.
    ///
    /// - Parameter sender: Reads the sender as 'EnvAlertAction', so that you can pass the T' object in the completion handler.
    /// - Caches the rawValue of the object in UserDefaults if the user wants to use it.
    /// - Returns: Passes 'T' object to completionhandler.
    func actionHandler(sender: UIAlertAction) {
        guard let envAlertAction = sender as? EnvAlertAction,
            let selectedEnv = envAlertAction.selectedEnv else { return }
        UserDefaults.standard.set(selectedEnv.rawValue, forKey: ACTIVE_ENV_KEY)

        let alert = UIAlertController(title: "Environment changed successfully.", message: "Please restart the app to access \(selectedEnv.rawValue)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        completionHandler(selectedEnv)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}
