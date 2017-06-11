//
//  CameraVC.swift
//  Olla
//
//  Created by Roland Keesom on 11/06/2017.
//  Copyright © 2017 Keesom. All rights reserved.
//

import UIKit
import Vision
import CoreML
import MetalKit

final class CameraVC: UIViewController {
    private var videoCapture: VideoCapture?
    private var device = MTLCreateSystemDefaultDevice()
    private var ciContext : CIContext!
    
    private var previewView = UIView()
    
    private var textOutlineContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let device = device {
            ciContext = CIContext.init(mtlDevice: device)
        }
        
        view.addSubview(previewView)
        
        view.addSubview(textOutlineContainerView)
        
//        let spec = VideoSpec(fps: 3, size: CGSize(width: 224, height: 224))
        let spec = VideoSpec(fps: 3, size: CGSize(width: view.bounds.width, height: view.bounds.height))
        videoCapture = VideoCapture(cameraType: .back,
                                    preferredSpec: spec,
                                    previewContainer: previewView.layer)
        videoCapture?.imageBufferHandler = {[unowned self] (imageBuffer, timestamp, outputBuffer) in
            
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            guard let cgImage = self.ciContext.createCGImage(ciImage, from: ciImage.extent) else {return}
            
            let textDetectionRequest = VNDetectTextRectanglesRequest()
            textDetectionRequest.reportCharacterBoxes = true
            
            
            let myRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try myRequestHandler.perform([textDetectionRequest])
            } catch {
                
            }
            
            print(textDetectionRequest)
            
            DispatchQueue.main.async {
                for subview in self.textOutlineContainerView.subviews {
                    subview.removeFromSuperview()
                }
            }
            
            var count = 0
            
            for observation in textDetectionRequest.results as! [VNTextObservation] {
                if count <= 30 {
                    DispatchQueue.main.async {
                        self.addRedLineForRowOfCharacters(observation: observation, cgImage: cgImage)
                    }
                    count = count + 1
                } else {
                    //print("READY")
                }
                
            }
            
        }
    }
    
    func addRedLineForRowOfCharacters(observation: VNTextObservation, cgImage:CGImage){
        //print(observation.boundingBox)
        print("observation.cha: \(observation.characterBoxes)")
        
        for characterBox in observation.characterBoxes! {
            let minX = characterBox.boundingBox.minX
            //        print(minX)
            let minY = (1-characterBox.boundingBox.minY)
            //        print(minY)
            let boundWidth = characterBox.boundingBox.width
            //        print(boundWidth)
            let boundHeight = characterBox.boundingBox.height
            //        print(boundHeight)
            //        print("----")
            
            let imageWidth = CGFloat(cgImage.width)
            let imageHeight = CGFloat(cgImage.height)
            
            let screenWidth = self.view.bounds.width
            let screenHeight = self.view.bounds.height
            
            let widthRatio = screenWidth/imageWidth
            let heightRatio = screenHeight/imageHeight
            
            let observationView = UIView()
            observationView.frame = CGRect(
                x: ((minX * imageWidth)*widthRatio),
                y: ((minY * imageHeight)*heightRatio)-15,
                width: ((boundWidth * imageWidth)*widthRatio),
                height: (boundHeight*imageHeight)*heightRatio)
            
            observationView.backgroundColor = .clear
            observationView.layer.borderColor = UIColor.red.cgColor
            observationView.layer.borderWidth = 1
            observationView.alpha = 0.5
            
            // get the text
            print(observation.characterBoxes)
            
            
            self.textOutlineContainerView.addSubview(observationView)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let videoCapture = videoCapture else {return}
        videoCapture.startCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewView.frame = view.bounds
        textOutlineContainerView.frame = view.bounds
        
        guard let videoCapture = videoCapture else {return}
        videoCapture.resizePreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let videoCapture = videoCapture else {return}
        videoCapture.stopCapture()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
