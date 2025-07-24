import Flutter
import UIKit
import AudioToolbox
import CoreHaptics

public class SwiftVibratePlugin: NSObject, FlutterPlugin {
    
    private var isDevice: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    @available(iOS 13.0, *)
    private static var engine: CHHapticEngine?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vibrate", binaryMessenger: registrar.messenger())
        let instance = SwiftVibratePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    @available(iOS 13.0, *)
    private func cancelVibration() {
        SwiftVibratePlugin.engine?.stop(completionHandler: { error in
                if let error = error {
                    print("Error stopping haptic engine: \(error)")
                } else {
                    print("Haptic engine stopped successfully.")
                }
            })
        }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "canVibrate":
            result(isDevice)
            
        case "vibrate":
            if isDevice {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            result(nil)
            
        case "impact":
            performImpactFeedback(style: .medium)
            result(nil)
            
        case "selection":
            performSelectionFeedback()
            result(nil)
            
        case "success":
            performNotificationFeedback(type: .success)
            result(nil)
            
        case "warning":
            performNotificationFeedback(type: .warning)
            result(nil)
            
        case "error":
            performNotificationFeedback(type: .error)
            result(nil)
            
        case "heavy":
            performImpactFeedback(style: .heavy)
            result(nil)
            
        case "medium":
            performImpactFeedback(style: .medium)
            result(nil)
            
        case "light":
            performImpactFeedback(style: .light)
            result(nil)

        case "cancel":
            if #available(iOS 13.0, *) {
                cancelVibration()
            } else {
                result(nil)
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Private Methods
    
    private func performImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isDevice else { return }
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        } else {
            // Fallback for iOS < 10.0
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    private func performSelectionFeedback() {
        guard isDevice else { return }
        
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        } else {
            // Fallback for iOS < 10.0
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    private func performNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isDevice else { return }
        
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        } else {
            // Fallback for iOS < 10.0
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}