//
//  ViewController.swift
//  Olla
//
//  Created by Jordi Bruin on 08/06/2017.
//  Copyright © 2017 Jordi Bruin. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .blue
//        iv.contentMode = .scaleToFill
        iv.image = #imageLiteral(resourceName: "brief-wit.jpg")
        return iv
    }()
    
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        
        let textDetectionRequest = VNDetectTextRectanglesRequest()
        textDetectionRequest.reportCharacterBoxes = true
        let cgImage = imageView.image?.cgImage
        
        
        
        print(cgImage)
        dump(cgImage)
        
        let myRequestHandler = VNImageRequestHandler(cgImage: cgImage!, options: [:])
        
        do {
            try myRequestHandler.perform([textDetectionRequest])
        } catch {
            
        }
        
        print(textDetectionRequest)
        
        for observation in textDetectionRequest.results as! [VNTextObservation] {
            if count <= 30 {
                addRedLineForRowOfCharacters(observation: observation)
                count = count + 1
            } else {
                //print("READY")
            }
            
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func addRedLineForRowOfCharacters(observation: VNTextObservation){
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
            let cgImage = imageView.image?.cgImage
            
            let imageWidth = CGFloat(cgImage!.width)
            let imageHeight = CGFloat(cgImage!.height)
            
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
            
            
            self.view.addSubview(observationView)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

