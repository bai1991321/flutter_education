import UIKit
import Flutter
import ReplayKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,RPPreviewViewControllerDelegate {
    
    var screenRecorder: RPScreenRecorder?
    var previewVC: RPPreviewViewController?
    
//    var screenRecorder = ScreenRecorder()
    var recordCompleted:((Error?) ->Void)?
    //  var books: [[String : String]] = []
//    var window: UIWindow?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    screenRecorder = RPScreenRecorder.shared()
    initiate()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
// func onClickRecordButton(_ sender: AnyObject) {
//
//        let button = sender as? UIButton
//
//        guard button?.isSelected == false else {
//
//            stopRecordingWithSender(sender: button)
//            return
//        }
//
//        startRecordingWithSender(sender: button)
//    }
    
    
//    func startRecording()
//    {
////        self.viewOverlay.show()
//        let flutterView =
//            window?.rootViewController as! FlutterViewController;
//
//        let randomNumber = arc4random_uniform(9999);
//
//
//        screenRecorder.startRecording(withFileName: "video") { (error) in
////            recordingHandler(error)
////            self.recordCompleted = onCompletion
//
//            print("startRecordingIOS")
//            DispatchQueue.main.async {
//                guard error == nil else {
//                    print("Sorry!! Your recording couldn't be started. Please try again.")
//                    //self?.showErrorAlertWithMesage(message: "Sorry!! Your recording couldn't be started. Please try again.")
//                    return
//                }
//            }
//
//            let channel = FlutterBasicMessageChannel(
//                name: "video_scribing",
//                binaryMessenger: flutterView,
//                codec: FlutterStringCodec.sharedInstance())
//            // Send message to Dart and receive reply.
//            channel.sendMessage("Started") {(reply: Any?) -> Void in
//                //                    os_log("%@", type: .info, reply as! String)
//                print(reply)
//            }
//        }
//    }
    
//    func stopRecording()
//    {
//        let flutterView =
//            window?.rootViewController as! FlutterViewController;
//
//        screenRecorder.stopRecording { (error) in
////            self.viewOverlay.hide()
//            self.recordCompleted?(error)
//            guard error == nil else {
//
//                //                    self?.showErrorAlertWithMesage(message: "Sorry!! Your recording couldn't be stopped. Please try again.")
//
//                return
//            }
//
//            let channel = FlutterBasicMessageChannel(
//                name: "video_scribing",
//                binaryMessenger: flutterView,
//                codec: FlutterStringCodec.sharedInstance())
//            // Send message to Dart and receive reply.
//            channel.sendMessage("Stopped") {(reply: Any?) -> Void in
//                //                    os_log("%@", type: .info, reply as! String)
//                print(reply)
//            }
//
//        }
//    }
    
    func initiate() {
        let flutterView =
            window?.rootViewController as! FlutterViewController;
        
        let channel = FlutterMethodChannel(
            name: "video_scribing", binaryMessenger: flutterView)
        

        // Receive method invocations from Dart and return results.
        channel.setMethodCallHandler {
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            print("nativecallfromdart \(call.method)")
            switch (call.method) {
            case "startRecording":
                self.startRecording()
                
            case "stopRecording":
                self.stopRecording()

            case "bar": result("Hello, \(call.arguments as! String)")
            case "baz": result(FlutterError(
                code: "400", message: "This is bad", details: nil))
            default: result(FlutterMethodNotImplemented)
                
                
            }
        }
    }
    private func startRecording() {

        screenRecorder?.isMicrophoneEnabled = true
        let flutterView =
            window?.rootViewController as! FlutterViewController;

        if #available(iOS 10.0, *) {
            
           
            screenRecorder?.startRecording(handler: {(error) in
                print("startRecordingIOS")
                DispatchQueue.main.async {
                    guard error == nil else {
                        print("Sorry!! Your recording couldn't be started. Please try again.")
                        //self?.showErrorAlertWithMesage(message: "Sorry!! Your recording couldn't be started. Please try again.")
                        return
                    }
                }
                
                
                let channel = FlutterBasicMessageChannel(
                    name: "video_scribing",
                    binaryMessenger: flutterView,
                    codec: FlutterStringCodec.sharedInstance())
                // Send message to Dart and receive reply.
                channel.sendMessage("Started") {(reply: Any?) -> Void in
                    //                    os_log("%@", type: .info, reply as! String)
                    print(reply)
                }


            })
        } else {
            // Fallback on earlier versions
        }

    }


    private func stopRecording() {
      
        screenRecorder?.stopRecording(handler: {(previewViewController, error) in
            print("iosStopRecording")
//            DispatchQueue.main.async {

                guard error == nil else {

//                    self?.showErrorAlertWithMesage(message: "Sorry!! Your recording couldn't be stopped. Please try again.")

                    return
                }
            
                previewViewController?.previewControllerDelegate = self
            

                self.previewVC = previewViewController
                if let previewVC = self.previewVC {
                    self.window.rootViewController?.present(previewVC, animated: true, completion: nil)
                    self.window?.isHidden = false
                }
//            }
        })
    }

    private func showErrorAlertWithMesage(message: String) {

        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Camera Capture"), message:NSLocalizedString("This app doesn't have permission to use the camera. Please change the privacy settings", comment: "Camera Capture"), preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(okAction)
        self.window.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        
        
        previewController.dismiss(animated: true) {

            self.window?.isHidden = false
            let flutterView =
                self.window?.rootViewController as! FlutterViewController;
            
            if activityTypes.count > 0 {
                let channel = FlutterBasicMessageChannel(
                    name: "video_scribing",
                    binaryMessenger: flutterView,
                    codec: FlutterStringCodec.sharedInstance())
                // Send message to Dart and receive reply.
                channel.sendMessage("Stopped") {(reply: Any?) -> Void in
                    //                    os_log("%@", type: .info, reply as! String)
                    print(reply)
                }
            }else{
                let channel = FlutterBasicMessageChannel(
                    name: "video_scribing",
                    binaryMessenger: flutterView,
                    codec: FlutterStringCodec.sharedInstance())
                // Send message to Dart and receive reply.
                channel.sendMessage("Cancelled") {(reply: Any?) -> Void in
                    //                    os_log("%@", type: .info, reply as! String)
                    print(reply)
                }
            }


//            let channel = FlutterBasicMessageChannel(
//                name: "video_scribing",
//                binaryMessenger: flutterView,
//                codec: FlutterStringCodec.sharedInstance())
//            // Send message to Dart and receive reply.
//            channel.sendMessage("Stopped") {(reply: Any?) -> Void in
//                //                    os_log("%@", type: .info, reply as! String)
//                print(reply)
//            }


        }
    }

    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        print(previewController)
    }
    
    
    
}



