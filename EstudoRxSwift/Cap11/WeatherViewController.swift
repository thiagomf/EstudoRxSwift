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
import CoreLocation
import MapKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var cityTxt: UITextField!
    
    @IBOutlet weak var tempLb: UILabel!
    
    @IBOutlet weak var humiLb: UILabel!
    
    @IBOutlet weak var load: UIActivityIndicatorView!
    
    @IBOutlet weak var geoLocation: UIButton!
    
    @IBOutlet weak var mapKitBtn: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
     let bag = DisposeBag()
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchInput = cityTxt.rx.controlEvent(.editingDidEndOnExit)
            .map { self.cityTxt.text ?? "" }
            .filter { $0.count > 0 }
        
        mapView.rx.setDelegate(self)
            .disposed(by: bag)
        
        mapKitBtn.rx.tap
            .subscribe(onNext: {
                self.mapView.isHidden.toggle()
            }
        ).disposed(by: bag)
        
//        let search = searchInput.flatMapLatest { cityTxt in
//
//            return ApiController.shared.currentWeather(city: cityTxt)
//        }
//        .observeOn(MainScheduler.instance)
//        .asDriver(onErrorJustReturn: Weather.dummy)
        
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
        
        let geoInput = geoLocation.rx.tap.asObservable()
            .do(onNext: {
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
            })
        
        let searchText = searchInput.flatMap { text in
            
            return ApiController.shared.currentWeather(city: text)
                    .catchErrorJustReturn(.dummy)
        }
        
        let lastLocation = locationManager.rx.didUpdateLocations
            .map { locations in locations[0] }
            .filter { locations in
                return locations.horizontalAccuracy < kCLLocationAccuracyHundredMeters
            }
        
        let geoLocation = geoInput.flatMap {
            return lastLocation.take(1)
        }
        
        let geoSearch = geoLocation.flatMap { location in
            
            return ApiController.shared.currentWeather(lat: location.coordinate.latitude,
                                                       lon: location.coordinate.longitude)
                                                        .catchErrorJustReturn(Weather.dummy)
            
        }
        
        let search = Observable.merge(geoSearch, searchText)
                        .asDriver(onErrorJustReturn: .dummy)
        
        let running = Observable.merge(
                        searchInput.map { _ in true},
                        geoInput.map { _ in true},
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

extension WeatherViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->
        MKOverlayRenderer {
            
            guard let overlay = overlay as? Weather.Overlay else {
                return MKOverlayRenderer()
            }
            
            let overlayView = Weather.OverlayView(overlay: overlay,
                                                    overlayIcon: overlay.icon)
            return overlayView
    }
}
