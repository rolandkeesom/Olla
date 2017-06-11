//
//  ViewController.swift
//  Olla
//
//  Created by Jordi Bruin on 08/06/2017.
//  Copyright © 2017 Jordi Bruin. All rights reserved.
//

import UIKit
import Vision

class TextDetectionVC: UIViewController {
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .blue
//        iv.contentMode = .scaleToFill
//        iv.image = #imageLiteral(resourceName: "brief-wit.jpg")
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
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

