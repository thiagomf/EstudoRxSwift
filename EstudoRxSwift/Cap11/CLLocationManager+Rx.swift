//
//  CLLocationManager+Rx.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 17/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift

extension CLLocationManager: HasDelegate {
    
  public typealias Delegate = CLLocationManagerDelegate
    
}

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
                                        DelegateProxyType,
                                        CLLocationManagerDelegate {
    
    public weak private(set) var locationManager: CLLocationManager?
    
    public init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }
   
}

extension Reactive where Base: CLLocationManager {
    
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in
                return parameters[1] as! [CLLocation]
        }
        
    }
    
}
