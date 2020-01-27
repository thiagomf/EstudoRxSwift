//
//  ViewController2.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 27/01/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import UIKit
import RxSwift

class ViewController2: UIViewController {

    fileprivate let selectedPhotosSubject = PublishSubject<String>()
    
    var selectedPhotos: Observable<String> {
        return selectedPhotosSubject.asObservable()
    }
    
    let dispose = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        selectedPhotosSubject.onCompleted()
    }
    
    @IBAction func teste1(_ sender: Any) {
        
        self.selectedPhotosSubject.onNext("teste01")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func teste2(_ sender: Any) {
        
        self.selectedPhotosSubject.onNext("teste02")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func teste3(_ sender: Any) {
        
        self.selectedPhotosSubject.onNext("teste03")
        self.dismiss(animated: true, completion: nil)
    }
}
