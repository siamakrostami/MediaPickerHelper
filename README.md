# MediaPickerHelper
MediaPickerHelper allows you to create a simple media picker action sheet 

## Usage 

create an instance of MediaPickerHelper with selected types:

Picker Types:

```ruby

  Camera 
  Library(camera roll)
  Files 
  Remove 
        
```

Media Types:

```ruby

Video 
Audio
Document 
Image 
Unsopported

```

Create a variable and initialize:

```ruby

fileprivate var pickerViewModel : MediaPickerHelper!

```

```ruby

    fileprivate func initializeData(){
        self.pickerViewModel = MediaPickerHelper(mediaTypes: [.Camera,.Library,.Files], viewController: self)
        self.pickerViewModel.mediaPickerDelegate = self
        self.pickerViewModel.filePickerDelegate = self
    }
    
```    

Show picker :

```ruby

    @IBAction func showPickerView(_ sender: Any) {
        self.pickerViewModel.ShowPickerActionSheet()
    }
    
``` 

Use Delegations:

```ruby

extension YourPickerViewController : MediaPickerProtocols , FilePickerProtocols{

    func mediaUrl(media: URL?, type: MediaPickerExtensions?) {
        guard let fileUrl = media else{return}
        // do something with picked media
    }
    
    func fileUrl(file: URL?, type: MediaPickerExtensions?) {
        guard let fileUrl = file else{return}
        // do something with picked file
    }
    
}

```

## Example

To run the example project, clone the repo and build it.

## License

MediaPickerHelper is available under the MIT license. See the LICENSE file for more info.
