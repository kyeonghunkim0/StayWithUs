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
import GoogleMobileAds
import SnapKit
import Mantis

class MainViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet var imgViews: [UIImageView]!
    @IBOutlet weak var photoView: UIStackView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var darkBtn: UIButton!
    
    private var selectedImageView: UIImageView?
    private var bannerView: GADBannerView!
    private var imageArray: [UIImage] = []
    private var cnt: Int = 0
    private var isTapped: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = .label
        setupBannerView() // 배너 출력
        // 라벨 출력
        if logoLabel.adjustsFontSizeToFitWidth == false{
            logoLabel.adjustsFontSizeToFitWidth = true
        }
        addTapGesture()
    }
    // Gesture 추가
    private func addTapGesture(){
        imgViews.forEach{
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    // ImageView Tap
    @objc func didTapImageView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.selectedImageView  = tapGestureRecognizer.view as? UIImageView
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 1
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = true
        
        self.presentImagePicker(imagePicker,
                                select: {(asset) in},
                                deselect: {(asset) in},
                                cancel: {asset in},
                                finish: { [weak self] asset in
            guard let self = self else {return}
            if let image = self.convertPHAssetToUIImage(assets: asset.first!){
                DispatchQueue.main.async {
                    let cropViewController = Mantis.cropViewController(image: image)
                    cropViewController.delegate = self
                    self.present(cropViewController, animated: true)
                }
            }
        })
    }
    
    @IBAction func didTapDownloadButton(_ sender: UIButton) {
        downloadPhoto(view: photoView!)
        self.view.makeToast("저장 완료!")
    }
    
    private func downloadPhoto(view: UIView){
        UIGraphicsBeginImageContextWithOptions(photoView.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    @IBAction func didTapInformationButton(_ sender: UIButton) {
        let message: String = """
        - 사진 영역을 선택하여 사진을 추가하고, 사진을 편집할 수 있어요.
        - 왼쪽 상단 버튼으로 배경색을 변경하고 사진을 저장할 수 있어요.
        """
        let alertViewController = UIAlertController(title: "정보", message: message, preferredStyle: .alert)
        alertViewController.view.tintColor = .label
        let okAction = UIAlertAction(title: "확인", style: .default)
        alertViewController.addAction(okAction)
        self.present(alertViewController, animated: true)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        
        if let URL = URL(string: "https://www.instagram.com/create/story"){
            if UIApplication.shared.canOpenURL(URL){
                
                let render = UIGraphicsImageRenderer(size: photoView.bounds.size)
                
                let renderImg = render.image{ _ in photoView.drawHierarchy(in: photoView.bounds, afterScreenUpdates: true)}
                
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

    @IBAction func didTapChangeBackgroundButton(_ sender: UIButton) {
        // 흰색배경
        if(self.isTapped){
            photoView.backgroundColor = .systemBackground
            logoLabel.textColor = .label
            view.backgroundColor = .systemGray
            
            for i in imgViews{
                i.layer.borderWidth = 1.0
                i.layer.borderColor = UIColor.label.cgColor
            }
            self.isTapped = false
        }
        // 검은배경
        else{
            photoView.backgroundColor = .label
            logoLabel.textColor = .systemBackground
            view.backgroundColor = .systemBackground
            
            self.isTapped = true
        }
    }
}
//MARK: - Google Admob
extension MainViewController: GADBannerViewDelegate{
    func setupBannerView() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-8472581583871808/3157882850"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        view.addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    // MARK: - Delegate
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner error : \(error.localizedDescription)")
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
    
    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    }
}
//MARK: - Photo
extension MainViewController{
    // PHAsset -> UIImage
    func convertPHAssetToUIImage(assets: PHAsset) -> UIImage? {
        let manger = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manger.requestImage(for: assets, targetSize: CGSize(width: assets.pixelWidth, height: assets.pixelHeight), contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in image = result!
        })
        return image
    }
}
//MARK: - Crop
extension MainViewController: CropViewControllerDelegate{
    // Crop Done
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        self.dismiss(animated: true){
            self.selectedImageView?.image = cropped
        }
    }
    // Crop Cancel
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        self.dismiss(animated: true){
            self.selectedImageView?.image = original
        }
    }
}
