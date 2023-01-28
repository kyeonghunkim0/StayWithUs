//
//  ViewController.swift
//  StayWithUs
//
//  Created by 김경훈 on 2022/08/14.
//

import UIKit
import BSImagePicker
import Photos
import Toast_Swift
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet var imgViews: [UIImageView]!
    @IBOutlet weak var PhotoView: UIView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var darkBtn: UIButton!
    
    var cnt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 라벨 출력
        if logoLabel.adjustsFontSizeToFitWidth == false{
            logoLabel.adjustsFontSizeToFitWidth = true
        }
    }

    
    //MARK: 사진 추가
    @IBAction func addPhoto(_ sender: UIButton) {
        
   
     
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 4
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = true
        
       
     
        
        
        self.presentImagePicker(imagePicker, select: {(asset) in print("Selected \(asset)")
        }, deselect: {(asset) in print("Deselected \(asset)")
        },cancel: {(asset) in print("Cancled with selections: \(asset)")
        }, finish: {(asset) in print("Finished with selections : \(asset)")
            for i in 0..<4{
                
                if asset.count < 4{
                    self.view.makeToast("사진 4장을 선택해주세요.")
                    return
                }
                
                self.imgViews[i].image = self.AssetsToImage(assets: asset[i])
                

            }
           
        
        })
    }


    //MARK: PHAsset-> UIImage
    func AssetsToImage(assets: PHAsset) -> UIImage? {
        let manger = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manger.requestImage(for: assets, targetSize: CGSize(width: assets.pixelWidth, height: assets.pixelHeight), contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in image = result!
        })
        return image
    }
    
    
    
    @IBAction func downloadBtn(_ sender: UIButton) {
        

        downloadPhoto(view: PhotoView!)
        self.view.makeToast("저장 완료!")
    }
    
    @discardableResult
    func downloadPhoto(view: UIView) -> UIImage?{
        UIGraphicsBeginImageContextWithOptions(PhotoView.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        return image!
    }
    
    @IBAction func shareBtn(_ sender: UIButton) {
        
        if let URL = URL(string: "instagram-stories://share"){
            if UIApplication.shared.canOpenURL(URL){
                
                let render = UIGraphicsImageRenderer(size: PhotoView.bounds.size)
                
                let renderImg = render.image{ _ in PhotoView.drawHierarchy(in: PhotoView.bounds, afterScreenUpdates: true)}
                
                guard let imgData = renderImg.pngData() else {return}
                
                let pasteboardItems : [String:Any] = [
                    "com.instagram.sharedSticker.stickerImage": imgData
                ]
                
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate : Date().addingTimeInterval(300)
                ]
                
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                
                UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            }
            else{
                let alert = UIAlertController(title: "알림", message: "인스타그램이 설치되어 있지 않습니다.", preferredStyle: .alert)
                let yes = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(yes)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func darkBtn(_ sender: UIButton) {
        
        cnt += 1
        
        if(cnt%2 != 0){
            PhotoView.backgroundColor = .white
            logoLabel.textColor = .black
            view.backgroundColor = .gray
        
        }
        else{
            PhotoView.backgroundColor = .black
            logoLabel.textColor = .white
            view.backgroundColor = .white
        }
        
  
    }
}
        
        
 
    
    





