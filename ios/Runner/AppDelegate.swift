// import UIKit
// import Flutter
//
// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let icloudChannel = FlutterMethodChannel(name: "com.onedayapp/icloud_storage", binaryMessenger: controller.binaryMessenger)

    icloudChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "readFromICloud":
        if let args = call.arguments as? [String: Any], let fileName = args["fileName"] as? String {
          self?.readFromICloud(fileName: fileName, result: result)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      case "isICloudAvailable":
        self?.isICloudAvailable(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func readFromICloud(fileName: String, result: @escaping FlutterResult) {
    let query = NSMetadataQuery()
    query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
    query.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, fileName)

    NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: query, queue: nil) { (notification) in
      query.disableUpdates()
      NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: query)

      if let item = query.results.first as? NSMetadataItem, let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL {
        do {
          let fileCoordinator = NSFileCoordinator()
          var error: NSError?
          var fileContent: String?

          fileCoordinator.coordinate(readingItemAt: url, options: [], error: &error) { (newURL) in
            do {
              fileContent = try String(contentsOf: newURL, encoding: .utf8)
            } catch let readError {
              result(FlutterError(code: "READ_ERROR", message: readError.localizedDescription, details: nil))
            }
          }

          if let content = fileContent {
            result(content)
          } else if let error = error {
            result(FlutterError(code: "COORDINATION_ERROR", message: error.localizedDescription, details: nil))
          }

        } catch let error {
          result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
        }
      } else {
        result(FlutterError(code: "NOT_FOUND", message: "File not found", details: nil))
      }
    }

    query.start()
  }

  private func isICloudAvailable(result: @escaping FlutterResult) {
      if let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
        result(true)
      } else {
        result(false)
      }
    }
}
