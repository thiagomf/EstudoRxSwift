//
//  ApiController.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 12/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SwiftyJSON
import CoreLocation

class ApiController {

    enum ApiError: Error {

        case cityNotFound
        case serverFailure
        case invalidKey
    }

    static var shared = ApiController()
    let apiKey = BehaviorSubject(value: "")
    let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!
    
    func currentWeatherDumb(city: String) -> Observable<Weather> {
        
        return Observable
                .just(Weather(cityName: city,
                              temperature: 20,
                              humidity: 20,
                              icon: iconNameToChar(icon: "01d"),
                              lat: 2.0,
                              lon: 2.0))
        
    }
    
     func currentWeather(city: String) -> Observable<Weather> {
       return buildRequest(pathComponent: "weather", params: [("q", city)]).map() { json in
         return Weather(
           cityName: json["name"].string ?? "Unknown",
           temperature: json["main"]["temp"].int ?? -1000,
           humidity: json["main"]["humidity"].int  ?? 0,
           icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e"),
           lat: json["coord"]["lat"].double ?? 0,
           lon: json["coord"]["lon"].double ?? 0
         )
       }
     }
    
    func currentWeather(lat: Double, lon: Double) -> Observable<Weather> {
        
        return buildRequest(pathComponent: "weather", params: [("lat", "\(lat)"), ("lon",                                                                           "\(lon)")]).map() { json in
            return Weather(
                cityName: json["name"].string ?? "Unknown",
                temperature: json["main"]["temp"].int ?? -1000,
                humidity: json["main"]["humidity"].int  ?? 0,
                icon: iconNameToChar(icon: json["weather"][0]["icon"].string ?? "e"),
                lat: json["coord"]["lat"].double ?? 0,
                lon: json["coord"]["lon"].double ?? 0
            )
            
        }
        
    }
    
    /**
     * Private method to build a request with RxCocoa
     */
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<JSON> {

      let url = baseURL.appendingPathComponent(pathComponent)
      var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "appid", value: try? self.apiKey.value())
      let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
      let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

      if method == "GET" {
        var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
        queryItems.append(keyQueryItem)
        queryItems.append(unitsQueryItem)
        urlComponents.queryItems = queryItems
      } else {
        urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.httpBody = jsonData
      }

      request.url = urlComponents.url!
      request.httpMethod = method

      request.setValue("application/json", forHTTPHeaderField: "Content-Type")

      let session = URLSession.shared

        return session.rx.response(request: request).map() { response, data in
            switch response.statusCode {
            case 200 ..< 300:
                return try JSON(data: data)
            case 401:
                throw ApiError.invalidKey
            case 400 ..< 500:
                throw ApiError.cityNotFound
            default:
                throw ApiError.serverFailure
            }
        }
    }
}
