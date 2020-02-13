//
//  WeatherViewController.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 10/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var cityTxt: UITextField!
    
    @IBOutlet weak var tempLb: UILabel!
    
    @IBOutlet weak var humiLb: UILabel!
    
     let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let search = cityTxt.rx.controlEvent(.editingDidEndOnExit)
            .map { self.cityTxt.text ?? "" }
            .flatMapLatest { cityTxt in
                
                return ApiController.shared.currentWeather(city: cityTxt)
        }
        .observeOn(MainScheduler.instance)
        .asDriver(onErrorJustReturn: Weather.empty)
//        .subscribe(onNext: { value in
//            self.cityTxt.text = value.cityName
//            self.tempLb.text = "\(value.temperature)° C"
//            self.humiLb.text = "\(value.humidity) %"
//        }).disposed(by: bag)
        
        search.map { "\($0.temperature) ° C" }
            .drive(tempLb.rx.text)
            .disposed(by: bag)
        
        search.map { $0.cityName }
            .drive(cityTxt.rx.text)
            .disposed(by: bag)
        
        search.map { "\($0.humidity) %" }
            .drive(humiLb.rx.text)
            .disposed(by: bag)
    }
}
