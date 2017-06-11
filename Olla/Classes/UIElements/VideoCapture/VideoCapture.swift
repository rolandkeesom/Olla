//
//  VideoCapture.swift
//
//  Created by Shuichi Tsutsumi on 4/3/16.
//  Copyright © 2016 Shuichi Tsutsumi. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

struct VideoSpec {
    var fps: Int32?
    var size: CGSize?
}

typealias ImageBufferHandler = ((_ imageBuffer: CVPixelBuffer, _ timestamp: CMTime, _ outputBuffer: CVPixelBuffer?) -> ())

class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {

    private let captureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice!
    private var videoConnection: AVCaptureConnection!
    private var audioConnection: AVCaptureConnection!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    var imageBufferHandler: ImageBufferHandler?
    var currentImage:UIImage?
    
    init(cameraType: CameraType, preferredSpec: VideoSpec?, previewContainer: CALayer?)
    {
        super.init()
        
        videoDevice = cameraType.captureDevice()
        
        // setup video format
        do {
            captureSession.sessionPreset = AVCaptureSession.Preset.inputPriority
            if let preferredSpec = preferredSpec {
                // update the format with a preferred fps
                videoDevice.updateFormatWithPreferredVideoSpec(preferredSpec: preferredSpec)
            }
        }
        
        // setup video device input
        do {
            let videoDeviceInput: AVCaptureDeviceInput
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            }
            catch {
                fatalError("Could not create AVCaptureDeviceInput instance with error: \(error).")
            }
            guard captureSession.canAddInput(videoDeviceInput) else {
                fatalError()
            }
            captureSession.addInput(videoDeviceInput)
        }
        
        // setup audio device input
        do {
            guard let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else {
                fatalError()
            }
            let audioDeviceInput: AVCaptureDeviceInput
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            }
            catch {
                fatalError("Could not create AVCaptureDeviceInput instance with error: \(error).")
            }
            guard captureSession.canAddInput(audioDeviceInput) else {
                fatalError()
            }
            captureSession.addInput(audioDeviceInput)
        }

        // setup preview
        if let previewContainer = previewContainer {
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = previewContainer.bounds
            previewLayer.contentsGravity = kCAGravityResizeAspectFill
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewContainer.insertSublayer(previewLayer, at: 0)
            self.previewLayer = previewLayer
        }
        
        // setup video output
        do {
            let videoDataOutput = AVCaptureVideoDataOutput()
            
//            if let specSize = preferredSpec?.size {
//
//                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: NSNumber(value: kCVPixelFormatType_32BGRA),
//                                                 kCVPixelBufferWidthKey as AnyHashable: NSNumber(value: Float(specSize.width)),
//                                                 kCVPixelBufferHeightKey as AnyHashable: NSNumber(value: Float(specSize.height))]
//            }
            
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)]
            
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            
            let queue = DispatchQueue(label: "com.shu223.videosamplequeue")
            videoDataOutput.setSampleBufferDelegate(self, queue: queue)
            guard captureSession.canAddOutput(videoDataOutput) else {
                fatalError()
            }
            captureSession.addOutput(videoDataOutput)

            videoConnection = videoDataOutput.connection(with: AVMediaType.video)
        }
        
        // setup audio output
        do {
            let audioDataOutput = AVCaptureAudioDataOutput()
            let queue = DispatchQueue(label: "com.shu223.audiosamplequeue")
            audioDataOutput.setSampleBufferDelegate(self, queue: queue)
            guard captureSession.canAddOutput(audioDataOutput) else {
                fatalError()
            }
            captureSession.addOutput(audioDataOutput)

            audioConnection = audioDataOutput.connection(with: AVMediaType.audio)
        }

        // setup asset writer
        do {
        }
        /*

        // Asset Writer
        self.assetWriterManager = [[TTMAssetWriterManager alloc] initWithVideoDataOutput:videoDataOutput
                                                                         audioDataOutput:audioDataOutput
                                                                           preferredSize:preferredSize
                                                                                mirrored:(cameraType == CameraTypeFront)];
         */
    }
    
    func startCapture() {
        print("\(self.classForCoder)/" + #function)
        if captureSession.isRunning {
            print("already running")
            return
        }
        captureSession.startRunning()
    }
    
    func stopCapture() {
        print("\(self.classForCoder)/" + #function)
        if !captureSession.isRunning {
            print("already stopped")
            return
        }
        captureSession.stopRunning()
    }
    
    func resizePreview() {
        if let previewLayer = previewLayer {
            guard let superlayer = previewLayer.superlayer else {return}
            previewLayer.frame = superlayer.bounds
        }
    }
    
    // =========================================================================
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("\(self.classForCoder)/" + #function)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // FIXME: temp
        if connection.videoOrientation != .portrait {
            connection.videoOrientation = .portrait
            return
        }
        
        //TODO: Try to use only 1 method to get an image
        DispatchQueue.main.sync {
            if let image = sampleBuffer.generateBufferImage() {
                currentImage = image
            }
        }
        
        
        
        if let imageBufferHandler = imageBufferHandler, let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) , connection == videoConnection
        {
            
            
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            imageBufferHandler(imageBuffer, timestamp, nil)
        }
    }
}
