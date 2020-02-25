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
    
    @IBOutlet weak var keyButton: UIButton!
    
    private var cache = [String: Weather]()
    
    let bag = DisposeBag()
    
    private let locationManager = CLLocationManager()
    
    var keyTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let maxAttempts = 4
        
        let retryHandler: (Observable<Error>) -> Observable<Int> = { e in
            return e.enumerated().flatMap { attempt, error -> Observable<Int> in
                
                if attempt >= maxAttempts - 1 { return Observable.error(error)
                } else
                    if let casted = error as? ApiController.ApiError, casted == .invalidKey {
                        return ApiController.shared.apiKey
                            .filter { !$0.isEmpty }
                            .map { _ in 1 }
                }
                print("== retrying after \(attempt + 1) seconds ==")
                return Observable<Int>.timer(Double(attempt + 1),
                                             scheduler: MainScheduler.instance) .take(1)
            }
        }
        
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
                .do(onNext: { data in
                    self.cache[text] = data
                }, onError: { e in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.showError(error: e)
                    }
                })
            .retryWhen(retryHandler)
//                .retry(3)
//                .retryWhen { e in
//                    return e.enumerated().flatMap { attempt, error -> Observable<Int> in
//                        if attempt >= maxAttempts - 1 {
//                            return Observable.error(error)
//                        }
//                        print("== retrying after \(attempt + 1) seconds ==")
//
//                        return Observable<Int>.timer(Double(attempt + 1),
//                                                     scheduler: MainScheduler.instance)
//                                                    .take(1)
//                    }
//                }
                .catchError { error in
                    guard let cached = self.cache[text] else {
                        return Observable.just(.empty)
                    }
                    return Observable.just(cached)
                }
            }
        
        let mapInput = mapView.rx.regionDidChangedAnimated
            .skip(1)
            .map { [unowned self] _ in
                self.mapView.centerCoordinate
            }
        
        let mapSearch = mapInput.flatMap { location in
            return ApiController.shared.currentWeather(lat: location.latitude,
                                                       lon: location.longitude)
                .catchErrorJustReturn(Weather.dummy)
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
        
        let search = Observable.merge(geoSearch, searchText, mapSearch)
                        .asDriver(onErrorJustReturn: .dummy)
                        
        let running = Observable.merge(
                        searchInput.map { _ in true },
                        geoInput.map { _ in true },
                        mapInput.map { _ in true },
                        search.map { _ in false}.asObservable())
                    .startWith(true)
                    .asDriver(onErrorJustReturn: false)
        
//        search.map { [$0. ] }
//            .drive(mapView.rx.overlays)
//            .disposed(by: bag)
        
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
      
        keyButton.rx.tap.subscribe(onNext: {
            self.requestKey()
        }).disposed(by: bag)
    }
    
    private func showError(error e: Error) {
        
        var alert = UIAlertController(title: "server ERROR", message: "An error occurred", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        
        guard let e = e as? ApiController.ApiError else {
            
            self.present(alert, animated: true)
            return
        }
        
        switch e {
            case .cityNotFound:
                alert = UIAlertController(title: "server ERROR", message: "City not found", preferredStyle: .alert)
            case .serverFailure:
                alert = UIAlertController(title: "ERROR", message: "Server Error", preferredStyle: .alert)
            case .invalidKey:
                alert = UIAlertController(title: "Key", message: "The key is invalid", preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func requestKey() {

       func configurationTextField(textField: UITextField!) {
         self.keyTextField = textField
       }

       let alert = UIAlertController(title: "Api Key",
                                     message: "Add the api key:",
                                     preferredStyle: UIAlertController.Style.alert)

       alert.addTextField(configurationHandler: configurationTextField)

        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler:{ (UIAlertAction) in
         ApiController.shared.apiKey.onNext(self.keyTextField?.text ?? "")
       }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive))

       self.present(alert, animated: true)
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
