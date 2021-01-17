//
//  FileUploadStore.swift
//  iTrayne_Trainer
//
//  Created by Chris on 3/30/20.
//  Copyright © 2020 Chris. All rights reserved.
//

import Foundation
import Firebase

class FileUploadStore : HTTPErrorHandler, ObservableObject {
    
    let storage:Storage = Storage.storage()
    
    func uploadImg(imageUpload:ImageUploadFile, success:((_ fileURL:String?) -> Void)? = nil, failed:((Error)->Void)? = nil ) {

        let storageRef = self.storage.reference()
        let data = imageUpload.image.jpegData(compressionQuality: 0.1)
        
        if let data = data {
            let riversRef = storageRef.child("\(imageUpload.folderName)/\(imageUpload.imageName).jpg")
            let _ = riversRef.putData(data, metadata: nil) { (metadata, error) in
                if let error = error {
                    self.displayErrorAlert(error)
                }
                guard let metadata = metadata else { return }
                let _ = metadata.size
                riversRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        if let error = error {
                            self.displayErrorAlert(error)
                            if let failed = failed {
                                failed(error)
                            }
                        }
                        
                        return
                    }
                    if let success = success {
                        success(downloadURL.absoluteString)
                    }
                }
            }
        }
    }
    
}
