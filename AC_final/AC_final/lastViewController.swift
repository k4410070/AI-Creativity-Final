//
//  lastViewController.swift
//  AC_final
//
//  Created by 김나현 on 2023/12/17.
//

import UIKit
import Photos

class lastViewController: UIViewController {

    @IBOutlet weak var img0: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    var images: [UIImage] = []
    var currentImageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestPhotoLibraryAccess()
        loadImages()
                setupSwipeGestures()
                updateImageDisplay()
    }
    func loadImages() {
            // 예시 이미지 이름들, 실제 이미지 파일명으로 대체
            let imageNames = ["4", "5","7"]
            images = imageNames.compactMap { UIImage(named: $0) }
        }
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status == .authorized {
                self.loadRecentPhotos()
            } else {
                // 권한이 거부되었을 때 처리
            }
        }
    }
    func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        img0.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        img0.addGestureRecognizer(swipeRight)

        img0.isUserInteractionEnabled = true // UIImageView에 제스처 인식을 활성화합니다.
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            currentImageIndex = (currentImageIndex + 1) % images.count
        } else if gesture.direction == .right {
            currentImageIndex = (currentImageIndex - 1 + images.count) % images.count
        }
        updateImageDisplay()
    }

    func updateImageDisplay() {
        img0.image = images[currentImageIndex]
    }
    func loadRecentPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 4

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        for i in 0..<fetchResult.count {
            let asset = fetchResult.object(at: i)
            let manager = PHImageManager.default()
            let targetSize = CGSize(width: 200, height: 200)
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch i {
                    case 0:
                        self.img4.image = image
                    case 1:
                        self.img3.image = image
                    case 2:
                        self.img2.image = image
                    case 3:
                        self.img1.image = image
                    default:
                        break
                    }
                }
            }
        }
    }

}
