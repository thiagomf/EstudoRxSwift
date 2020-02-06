//
//  EONET.swift
//  EstudoRxSwift
//
//  Created by Thiago M Faria on 06/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum EOError: Error {
    case invalidURL(String)
    case invalidParameter(String, Any)
    case invalidJSON(String)
}

class EONET {
    
    static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
    static let categoriesEndpoint = "/categories"
    static let eventsEndpoint = "/events"
    
    static var categories: Observable<[EOCategory]> = {
        return EONET.request(endPoint: categoriesEndpoint)
            .map {  data in
                
                let categories = data["categories"] as? [[String: Any]] ?? []
                return categories
                    .compactMap(EOCategory.init)
                    .sorted { $0.name < $1.name }
                }
                .share(replay: 1)
    }()
    
    static func request(endPoint: String, query: [String: Any] = [:]) -> Observable<[String : Any]> {
        
        do {
            guard let url = URL(string: API)?.appendingPathComponent(endPoint),
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    throw EOError.invalidURL(endPoint)
            }
            
            components.queryItems = try query.compactMap {(key, value) in
                guard let v = value as? CustomStringConvertible else {
                    throw EOError.invalidParameter(key, value)
                }
                
                return URLQueryItem(name: key, value: v.description)
            }
            
            guard let finalURL = components.url else {
                throw EOError.invalidURL(endPoint)
            }
            
            let request = URLRequest(url: finalURL)
            
            return URLSession.shared.rx.response(request: request)
                .map {_, data -> [String: Any] in
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                        let result = jsonObject as? [String: Any] else {
                            throw EOError.invalidJSON(finalURL.absoluteString)
                    }
                    return result
            }
        } catch {
            return Observable.empty()
        }
    }
    
    fileprivate static func events(forLast days: Int, closed: Bool) -> Observable<[EOEvent]> {
        
        return request(endPoint: eventsEndpoint, query: [
            "days": NSNumber(value: days),
            "status": (closed ? "closed" : "open")
        ])
            .map { json in
                guard let raw = json["events"] as? [[String: Any]] else {
                    throw EOError.invalidJSON(eventsEndpoint)
                }
                
                return raw.compactMap(EOEvent.init)
        }
    }
    
    static func events(forLast days: Int = 360) -> Observable<[EOEvent]> {
        
        let openEvents = events(forLast: days, closed: false)
        let closedEvents = events(forLast: days, closed: true)
        
        return Observable.of(openEvents, closedEvents)
            .merge()
            .reduce([]) { running, new in
                running + new
        }
    }
    
    static var ISODateReader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return formatter
    }()
    
}

