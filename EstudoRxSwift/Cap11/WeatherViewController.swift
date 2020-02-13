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
    
    @IBOutlet weak var load: UIActivityIndicatorView!
    
     let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchInput = cityTxt.rx.controlEvent(.editingDidEndOnExit)
            .map { self.cityTxt.text ?? "" }
            .filter { $0.count > 0 }
        
        let search = searchInput.flatMapLatest { cityTxt in
                
            return ApiController.shared.currentWeather(city: cityTxt)
        }
        .observeOn(MainScheduler.instance)
        .asDriver(onErrorJustReturn: Weather.dummy)
        
        let running = Observable.merge(
                        searchInput.map { _ in true},
                        search.map { _ in false}.asObservable())
                    .startWith(true)
                    .asDriver(onErrorJustReturn: false)
        
        running
            .skip(1)
            .drive(load.rx.isAnimating)
            .disposed(by: bag)
        
        running
            .drive(tempLb.rx.isHidden)
            .disposed(by: bag)
        
        running
            .drive(humiLb.rx.isHidden)
            .disposed(by: bag)
        
//        let search = cityTxt.rx.controlEvent(.editingDidEndOnExit)
//        .map { self.cityTxt.text ?? "" }
//        .flatMapLatest { cityTxt in
//
//            return ApiController.shared.currentWeather(city: cityTxt)
//        }
//        .observeOn(MainScheduler.instance)
//        .asDriver(onErrorJustReturn: Weather.dummy)
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
