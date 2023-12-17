//
//  ViewController.swift
//  AC_final
//
//  Created by 김나현 on 2023/12/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var startBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startBtn(_ sender: UIButton) {
        //촬영 모드
        guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "secondViewControllerID") as? CameraViewController else { return }
        //출력모드
        //guard let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "333") as? lastViewController else { return }
        // 화면 전환 애니메이션 설정
        secondViewController.modalTransitionStyle = .coverVertical
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        secondViewController.modalPresentationStyle = .fullScreen
                self.present(secondViewController, animated: true, completion: nil)
    }
    
}

