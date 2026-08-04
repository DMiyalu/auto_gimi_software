import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "zolana/printers",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "pairedBluetoothDevices" {
          result(FlutterError(
            code: "bluetooth_printer_unavailable",
            message: "iOS ne permet pas de lister automatiquement les imprimantes Bluetooth classiques. Associez une imprimante compatible AirPrint, BLE ou MFi.",
            details: nil
          ))
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
