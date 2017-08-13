//
//  CameraViewController.swift
//  GoogleBarcodeDetector
//
//  Created by Shuvo on 8/11/17.
//  Copyright © 2017 SHUVO. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import GoogleMobileVision


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    var barCodeDetector = GMVDetector()
    var qrCodeFrameView:UIView?
    var options:[AnyHashable:Any] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            self.captureSession.commitConfiguration()
            
            // Initialize a AVCaptureVideoDataOutput object with addition video settings and set it as the output device to the capture session.
            let captureVideodataOutput = AVCaptureVideoDataOutput()
            let rgbOutputSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
            captureVideodataOutput.videoSettings = rgbOutputSettings
            captureVideodataOutput.alwaysDiscardsLateVideoFrames = true
            
            let serialQueue = DispatchQueue(label: "queuename")
            captureVideodataOutput.setSampleBufferDelegate(self, queue: serialQueue)
            captureSession.addOutput(captureVideodataOutput) 
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer) 
            
            // Initialize BarcodeFormat types
            self.options = [GMVDetectorBarcodeFormats : (GMVDetectorBarcodeFormat.EAN13.rawValue | GMVDetectorBarcodeFormat.qrCode.rawValue | GMVDetectorBarcodeFormat.aztec.rawValue | GMVDetectorBarcodeFormat.codaBar.rawValue | GMVDetectorBarcodeFormat.code128.rawValue | GMVDetectorBarcodeFormat.code39.rawValue | GMVDetectorBarcodeFormat.codaBar.rawValue | GMVDetectorBarcodeFormat.code93.rawValue)]
            
            // Initialize GMVDetector
            self.barCodeDetector = GMVDetector.init(ofType: GMVDetectorTypeBarcode, options: options)

            // Move the message label and top bar to the front
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topBar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            captureSession.startRunning()
        }
        
        catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        // Capture frame by frame as an Image from a video to extract barcode
        var image = UIImage()
        image = GMVUtility.sampleBufferTo32RGBA(sampleBuffer)
        let devicePosition: AVCaptureDevice.Position = .back
        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        let orientation = GMVUtility.imageOrientation(from: deviceOrientation, with: devicePosition, defaultDeviceOrientation: UIDeviceOrientation.portrait)
        
        // Extracting GMVBarcodeFeature from a particular image
        self.options = [GMVDetectorImageOrientation as AnyHashable : (orientation.rawValue)]
        let barcodes: [GMVBarcodeFeature] = self.barCodeDetector.features(in: image, options: options ) as! [GMVBarcodeFeature]
        
        // Print information of the barcode
        if (barcodes.count > 0) {
                DispatchQueue.main.sync(execute: {() -> Void in
                    for barcode in barcodes {
                        qrCodeFrameView?.frame = barcode.bounds
                        messageLabel.text = barcode.rawValue
                    }
                })
            }
            
        else {
            qrCodeFrameView?.frame = CGRect.zero
        }

    }
    
}

