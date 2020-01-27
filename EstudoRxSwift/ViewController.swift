//
//  ViewController.swift
//  EstudoRxSwift
//
//  Created by Thiago M Faria on 26/01/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var stringLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func clickIr(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController2") as! ViewController2
        
        newViewController.selectedPhotos.subscribe(onNext: { [weak self] name in
            self?.stringLb.text = "LB ==> \(name)"
            print("Deu next")
        },
        onDisposed: {
            print("Deu dispose")
        }).disposed(by: newViewController.dispose)
        
        self.present(newViewController, animated: true, completion: nil)
    }
    
}

