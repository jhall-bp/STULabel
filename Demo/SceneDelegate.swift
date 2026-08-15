// Copyright 2026 Stephan Tolksdorf

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions)
  {
    guard let windowScene = scene as? UIWindowScene else { return }

    let window = UIWindow(windowScene: windowScene)
    window.backgroundColor = .white
    window.rootViewController = UINavigationController(rootViewController: RootViewController())
    self.window = window
    window.makeKeyAndVisible()
  }
}
