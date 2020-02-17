//
//  MKMapView+Rx.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 17/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import RxCocoa
import MapKit
import UIKit
import RxSwift

extension MKMapView : HasDelegate {
    
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy <MKMapView, MKMapViewDelegate>,
DelegateProxyType, MKMapViewDelegate {
    
    weak public private(set) var mapView: MKMapView?
    
    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {
            RxMKMapViewDelegateProxy(mapView: $0)
        }
    }
}

extension Reactive where Base: MKMapView {
    
    var delegate : DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }
    
    var overlays: Binder<[MKOverlay]> {
        return Binder(self.base) { mapView, overlays in
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlays(overlays)
        }
    }
    
    var regionDidChangedAnimated: ControlEvent<Bool> {
        let source = delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { parameters in
                
                return (parameters[1] as? Bool) ?? false
            }
        
        return ControlEvent(events: source)
    }
    
    func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        return RxMKMapViewDelegateProxy.installForwardDelegate(delegate,
                                                               retainDelegate: false,
                                                               onProxyForObject: self.base)
    }
    
}

