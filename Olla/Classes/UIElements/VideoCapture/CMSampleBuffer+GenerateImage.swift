//
//  CMSampleBuffer+GenerateImage.swift
//  TripleGames
//
//  Created by Roland Keesom on 12/02/17.
//  Copyright © 2017 Triple. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension CMSampleBuffer {
    
    func generateBufferImage() -> UIImage? {
        if let imageBuffer = CMSampleBufferGetImageBuffer(self) {
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let address = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
            
            let context = CGContext(data: address, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            
            if let imageRef = context!.makeImage() {
                CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
                let resultImage: UIImage = UIImage(cgImage: imageRef)
                
                return resultImage
            }
        }
        return nil
    }
}
