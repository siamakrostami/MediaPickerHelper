//
//  ViewController.swift
//  MediaPickerHelper
//
//  Created by Siamak Rostami on 8/8/21.
//

import UIKit

class PickerViewController: UIViewController {
    
    @IBOutlet weak var fileView: UIView!{
        didSet{
            self.fileView.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var pickerButton: UIButton!{
        didSet{
            self.pickerButton.layer.cornerRadius = 16
        }
    }
    
    fileprivate var pickerViewModel : MediaPickerHelper!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func showPickerView(_ sender: Any) {
        self.pickerViewModel.ShowPickerActionSheet()
    }
    

}

extension PickerViewController{
    
    fileprivate func initializeData(){
        self.pickerViewModel = MediaPickerHelper(mediaTypes: [.Camera,.Library,.Files], viewController: self)
        self.pickerViewModel.mediaPickerDelegate = self
        self.pickerViewModel.filePickerDelegate = self
        self.fileView.isHidden = true
    }
    
    fileprivate func showFileView(url : URL){
        DispatchQueue.main.async {
            self.fileView.isHidden = false
            self.fileName.text = url.lastPathComponent
        }
    }
 
}

extension PickerViewController : MediaPickerProtocols , FilePickerProtocols{
    func mediaUrl(media: URL?, type: MediaPickerExtensions?) {
        guard let fileUrl = media else{return}
        self.showFileView(url: fileUrl)
    }
    
    func fileUrl(file: URL?, type: MediaPickerExtensions?) {
        guard let fileUrl = file else{return}
        self.showFileView(url: fileUrl)
    }
    
    
}

