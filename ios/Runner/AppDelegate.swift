import Flutter
import UIKit
import GoogleMaps
GMSServices.provideAPIKey("AIzaSyBh9yyNCW4uD2nnHm7keY3v7-yH0ZHVaJY")

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBh9yyNCW4uD2nnHm7keY3v7-yH0ZHVaJY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
