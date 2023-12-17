//
//  CameraViewController.swift
//  AC_final
//
//  Created by 김나현 on 2023/12/17.
//

import UIKit
import AVFoundation
import Photos
import ImageIO

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var timer: Timer?
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoCount = 0 // 사진 촬영 횟수 추적
    var countdownTimer: Timer?
    var countdownSeconds = 5
    var currentGifIndex = 0
    let gifNames = ["4", "44", "444", "4444"] // 사용할 GIF 파일 이름
    var gifImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupPreviewLayer()
//        startTimer()
//        addGifOverlay()
        startGifAnimation()
    }
    func startGifAnimation() {
        let gifName = gifNames[currentGifIndex % gifNames.count]
        guard let gifImage = UIImage.gif(name: gifName) else { return }

        gifImageView = UIImageView(image: gifImage)
        // GIF 이미지 뷰의 크기 설정
        let gifSize = CGSize(width: 450, height: 450)
        gifImageView.frame = CGRect(x: (view.bounds.width - gifSize.width) / 2 + 10,
                                    y: (view.bounds.height - gifSize.height) / 2 + 30,
                                    width: gifSize.width,
                                    height: gifSize.height)
        gifImageView.contentMode = .scaleAspectFit
        view.addSubview(gifImageView)
        view.bringSubviewToFront(gifImageView)

        // GIF 애니메이션이 한 번 재생되고 나면 타이머 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {// GIF 이미지 뷰 제거
            self.startCountdownTimer()
        }
    }
    func startCountdownTimer() {
           // 카운트다운 레이블 설정
           let countdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
           countdownLabel.center = view.center
           countdownLabel.textAlignment = .center
           countdownLabel.font = UIFont.systemFont(ofSize: 50)
           view.addSubview(countdownLabel)

           countdownSeconds = 5
           countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
               countdownLabel.text = "\(self.countdownSeconds)"
               if self.countdownSeconds == 0 {
                   timer.invalidate()
                   countdownLabel.removeFromSuperview()
                   self.capturePhoto()
               } else {
                   self.countdownSeconds -= 1
               }
           }
       }
    func addGifOverlay() {
        let gifImage = UIImage.gif(name: "11111")
        let gifImageView = UIImageView(image: gifImage)
//        // GIF 이미지 뷰의 크기 설정
//        let gifSize = CGSize(width: 300, height: 300)
//        gifImageView.frame = CGRect(x: (view.bounds.width - gifSize.width) / 2 + 150,
//                                    y: (view.bounds.height - gifSize.height) / 2 + 50,
//                                    width: gifSize.width,
//                                    height: gifSize.height)
//
//        gifImageView.contentMode = .scaleAspectFit

        view.addSubview(gifImageView)
        view.bringSubviewToFront(gifImageView)
    }
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        photoOutput = AVCapturePhotoOutput()

        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let videoInput = try? AVCaptureDeviceInput(device: frontCamera) else { return }
        if captureSession.canAddInput(videoInput) && captureSession.canAddOutput(photoOutput) {
            captureSession.addInput(videoInput)
            captureSession.addOutput(photoOutput)
            captureSession.startRunning()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(capturePhoto), userInfo: nil, repeats: true)
    }

    @objc func capturePhoto() {
//        if photoCount == 4{
//            timer?.invalidate()
//            showAlert()
//        }
        if photoCount < 4 {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
            photoCount += 1
        }
    }

    func showAlert() {
        let alert = UIAlertController(title: "완료", message: "사진 촬영이 완료되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    func setupPreviewLayer() {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            let previewAspectRatio: CGFloat = 4.0 / 3.0
            let previewWidth = view.bounds.width
            let previewHeight = previewWidth / previewAspectRatio
            previewLayer.frame = CGRect(x: 0, y: (view.bounds.height - previewHeight) / 2, width: previewWidth, height: previewHeight)
            view.layer.insertSublayer(previewLayer, at: 0)
        }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData),
                  let flippedImage = flipImageLeftRight(image) else { return }

            let correctedImage = correctImageOrientation(image: flippedImage)
            let croppedImage = cropImageToAspectRatio(image: correctedImage, aspectRatio: 4/3)

            if let croppedImageData = croppedImage.jpegData(compressionQuality: 1.0) {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.forAsset().addResource(with: .photo, data: croppedImageData, options: nil)
                }, completionHandler: nil)
            }
        if photoCount < 4 {
                    self.gifImageView.removeFromSuperview()
                    currentGifIndex += 1
                    startGifAnimation()
                }
            if photoCount == 4{
                showAlert()
            
            }
        }
    func flipImageLeftRight(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: image.size.width, y: 0)
        context.scaleBy(x: -1, y: 1)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage
    }

        // 이미지 방향을 올바르게 조정하는 함수
        func correctImageOrientation(image: UIImage) -> UIImage {
            if image.imageOrientation == .up {
                return image
            }

            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return normalizedImage
        }

        // 이미지를 주어진 비율로 자르는 함수
        func cropImageToAspectRatio(image: UIImage, aspectRatio: CGFloat) -> UIImage {
            let cgImage = image.cgImage!
            let originalWidth = CGFloat(cgImage.width)
            let originalHeight = CGFloat(cgImage.height)
            var cropRect: CGRect
            if originalWidth / originalHeight > aspectRatio {
                let newWidth = originalHeight * aspectRatio
                cropRect = CGRect(x: (originalWidth - newWidth) / 2, y: 0, width: newWidth, height: originalHeight)
            } else {
                let newHeight = originalWidth / aspectRatio
                cropRect = CGRect(x: 0, y: (originalHeight - newHeight) / 2, width: originalWidth, height: newHeight)
            }
            let croppedCgImage = cgImage.cropping(to: cropRect)!
            return UIImage(cgImage: croppedCgImage)
        }
    deinit {
        timer?.invalidate()
    }
}

extension UIImage {
    static func gif(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        
        var images = [UIImage]()
        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }
        return UIImage.animatedImage(with: images, duration: Double(count) / 20.0)
    }
}
