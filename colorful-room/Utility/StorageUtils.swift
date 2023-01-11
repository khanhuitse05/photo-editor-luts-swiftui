//
//  StorageUtils.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation
import Combine
import SwiftUI

class StorageUtils{
    
    // save image to gallery
    func saveToGallery(image: UIImage?){
        if let value = image{
            ImageSaver().writeToPhotoAlbum(image: value)
        }
    }
    
    // save Image to disk
    func saveToDisk(fileName:String, image: UIImage){
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    // load image from disk
    func loadFromDisk(fileName: String)-> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        }
        return nil
    }
}
