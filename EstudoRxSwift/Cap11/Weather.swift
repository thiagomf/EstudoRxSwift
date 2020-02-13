//
//  Weather.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 12/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

struct Weather {
    
    let cityName: String
    let temperature: Int
    let humidity: Int
    let icon: String
    let lat: Double
    let lon: Double
    
    static let empty = Weather(
        cityName: "Unknown",
        temperature: -1000,
        humidity: 0,
        icon: iconNameToChar(icon: "e"),
        lat: 0,
        lon: 0
    )
    
    static let dummy = Weather(
        cityName: "RxCity",
        temperature: 20,
        humidity: 90,
        icon: iconNameToChar(icon: "01d"),
        lat: 0,
        lon: 0
    )
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    public class Overlay: NSObject, MKOverlay {
        var coordinate: CLLocationCoordinate2D
        var boundingMapRect: MKMapRect
        let icon: String
        
        init(icon: String, coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect) {
            self.coordinate = coordinate
            self.boundingMapRect = boundingMapRect
            self.icon = icon
        }
    }
    
    public class OverlayView: MKOverlayRenderer {
        var overlayIcon: String
        
        init(overlay:MKOverlay, overlayIcon:String) {
            self.overlayIcon = overlayIcon
            super.init(overlay: overlay)
        }
        
        public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
            let imageReference = imageFromText(text: overlayIcon as NSString, font: UIFont(name: "Flaticon", size: 32.0)!).cgImage
            let theMapRect = overlay.boundingMapRect
            let theRect = rect(for: theMapRect)
            
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0.0, y: -theRect.size.height)
            context.draw(imageReference!, in: theRect)
        }
    }
}

/**
 * Maps an icon information from the API to a local char
 * Source: http://openweathermap.org/weather-conditions
 */
public func iconNameToChar(icon: String) -> String {
  switch icon {
  case "01d":
    return "\u{f11b}"
  case "01n":
    return "\u{f110}"
  case "02d":
    return "\u{f112}"
  case "02n":
    return "\u{f104}"
  case "03d", "03n":
    return "\u{f111}"
  case "04d", "04n":
    return "\u{f111}"
  case "09d", "09n":
    return "\u{f116}"
  case "10d", "10n":
    return "\u{f113}"
  case "11d", "11n":
    return "\u{f10d}"
  case "13d", "13n":
    return "\u{f119}"
  case "50d", "50n":
    return "\u{f10e}"
  default:
    return "E"
  }
}

fileprivate func imageFromText(text: NSString, font: UIFont) -> UIImage {

  let size = text.size(withAttributes: [NSAttributedString.Key.font: font])
  UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

  text.draw(at: CGPoint(x: 0, y:0), withAttributes: [NSAttributedString.Key.font: font])

  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()

  return image ?? UIImage()
}
