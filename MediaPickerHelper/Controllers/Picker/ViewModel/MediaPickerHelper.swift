//
//  MediaPickerHelper.swift
//  MediaPickerHelper
//
//  Created by Siamak Rostami on 8/8/21.
//

import Foundation
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

 protocol MediaPickerProtocols{
    func mediaUrl(media : URL? , type : MediaPickerExtensions?)
}

protocol FilePickerProtocols{
    func fileUrl(file : URL? , type : MediaPickerExtensions?)
}

protocol RemovePhoto {
    func removePhoto()
}

class MediaPickerHelper : NSObject{
    
    fileprivate var mediaTypes : [MediaPickerTypes]?
    fileprivate var mediaPicker : UIImagePickerController!
    fileprivate var documentPicker : UIDocumentPickerViewController!
    fileprivate var viewController : UIViewController!
    var mediaPickerDelegate : MediaPickerProtocols!
    var filePickerDelegate : FilePickerProtocols!
    var removeDelegate : RemovePhoto!
    
    init(mediaTypes : [MediaPickerTypes] , viewController : UIViewController) {
        super.init()
        self.viewController = viewController
        self.mediaTypes = mediaTypes
        self.initData()
    }
    
}

extension MediaPickerHelper {
    
    fileprivate func initData(){
        self.mediaPicker = UIImagePickerController()
        let type = ["public.item","private.item"]
        self.documentPicker = UIDocumentPickerViewController(documentTypes: type, in: .import)
        self.documentPicker.delegate = self
        self.mediaPicker.delegate = self
    }
    
    fileprivate func saveImageToLocalPath(image : UIImage) -> URL?{
        let name = UUID().uuidString
        let documentDirectory = getDocumentsDirectory().appendingPathComponent(name)
        let data = image.jpegData(compressionQuality: 1)
        do{
            try data?.write(to: documentDirectory, options: .atomic)
            return documentDirectory
        }catch{
            return nil
        }
    }
    
    fileprivate func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func ShowPickerActionSheet(){
        guard self.mediaTypes != nil else{return}
        let actionSheet = UIAlertController(title: "choose", message: "", preferredStyle: .actionSheet)
        for item in mediaTypes!{
            let action = UIAlertAction(title: item.rawValue, style: .default) { handler in
                switch item{
                case .Camera:
                    self.mediaPicker.sourceType = .camera
                    self.mediaPicker.mediaTypes = ["public.image","public.movie","private.image","private.movie"]
                    self.mediaPicker.videoQuality = .typeHigh
                    self.mediaPicker.showsCameraControls = true
                    self.mediaPicker.allowsEditing = true
                    actionSheet.dismiss(animated: true, completion: nil)
                    self.viewController.present(self.mediaPicker, animated: true, completion: nil)
                    break
                case .Library:
                    self.mediaPicker.sourceType = .photoLibrary
                    self.mediaPicker.allowsEditing = true
                    self.mediaPicker.mediaTypes = ["public.image","public.movie","private.image","private.movie"]
                    self.mediaPicker.videoQuality = .typeHigh
                    actionSheet.dismiss(animated: true, completion: nil)
                    self.viewController.present(self.mediaPicker, animated: true, completion: nil)
                    break
                case .Remove:
                    self.removeDelegate.removePhoto()
                    actionSheet.dismiss(animated: true, completion: nil)
                    break
                default:
                    self.documentPicker.allowsMultipleSelection = false
                    actionSheet.dismiss(animated: true, completion: nil)
                    self.viewController.present(self.documentPicker, animated: true, completion: nil)
                    break
                }
            }
            actionSheet.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        self.viewController.present(actionSheet, animated: true, completion: nil)
    }
    
}
extension MediaPickerHelper : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        debugPrint(info.values)
        if picker.sourceType == .camera{
            if let image = info[.editedImage] as? UIImage{
                let url = saveImageToLocalPath(image: image)
                mediaPickerDelegate.mediaUrl(media: url, type: .Image)
            }else if let image = info[.originalImage] as? UIImage{
                let url = saveImageToLocalPath(image: image)
                mediaPickerDelegate.mediaUrl(media: url, type: .Image)
            }else{
                mediaPickerDelegate.mediaUrl(media: info[.mediaURL] as? URL, type: .Video)
            }
            
        }else{
            if let _ = info[.editedImage] as? UIImage{
                mediaPickerDelegate.mediaUrl(media: info[.imageURL] as? URL, type: .Image)
            }else if let _ = info[.originalImage] as? UIImage{
                mediaPickerDelegate.mediaUrl(media: info[.imageURL] as? URL, type: .Image)
            }else{
                mediaPickerDelegate.mediaUrl(media: info[.mediaURL] as? URL, type: .Video)
            }
        }

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension MediaPickerHelper : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import, let url = urls.first else {
            self.filePickerDelegate.fileUrl(file: nil, type: nil)
            return
        }
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
        }
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentDirectory.appendingPathComponent("\(urls.first!.lastPathComponent.replacingOccurrences(of: " ", with: ""))")
        do {
            try FileManager.default.copyItem(at: urls.first!.standardizedFileURL, to: filePath)
        } catch {
            print(error)
        }
        debugPrint("mime \(filePath.mimeType())")
        if filePath.containsAudio{
            self.filePickerDelegate.fileUrl(file: filePath, type: .Audio)
        }else if filePath.containsVideo{
            self.filePickerDelegate.fileUrl(file: filePath, type: .Video)
        }else if filePath.containsDocument{
            self.filePickerDelegate.fileUrl(file: filePath, type: .Document)
        }else if filePath.containsImage{
            self.filePickerDelegate.fileUrl(file: filePath, type: .Image)
        }else{
            self.filePickerDelegate.fileUrl(file: filePath, type: .Unsopported)
        }
       
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
