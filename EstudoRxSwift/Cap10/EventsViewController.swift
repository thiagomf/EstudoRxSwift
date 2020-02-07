//
//  EventsViewController.swift
//  EstudoRxSwift
//
//  Created by Thiago Machado Faria on 07/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EventsViewController: UIViewController {

    let events = BehaviorRelay<[EOEvent]>(value: [])
    let disposeBag = DisposeBag()
    
    let days = BehaviorRelay<Int>(value: 360)
    let filtered = BehaviorRelay<[EOEvent]>(value: [])
    
    @IBOutlet weak var daysLb: UILabel!
    
    @IBOutlet weak var eventstb: UITableView!

    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventstb.register(UINib(nibName: "EventCell", bundle: nil),
                          forCellReuseIdentifier: "events")
        
        Observable.combineLatest(days.asObservable(), events.asObservable()) {
            (days, events) -> [EOEvent] in
            
            let maxInternal = TimeInterval(days * 24 * 3600)
            return events.filter { event in
                if let date = event.closeDate {
                    return abs(date.timeIntervalSinceNow) < maxInternal
                }
                return true
            }
        }
        .bind(to: filtered)
        .disposed(by: disposeBag)
        
        filtered.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.eventstb.reloadData()
            })
        .disposed(by: disposeBag)
        
        days.asObservable()
            .subscribe(onNext: { [weak self] days in
                self?.daysLb.text = "Últimos \(days) dias"
            })
        .disposed(by: disposeBag)
        
        eventstb.rowHeight = UITableView.automaticDimension
        eventstb.estimatedRowHeight = 60
    }
    
    @IBAction func slide(_ sender: Any) {
        
        days.accept(Int(slider.value))
    }
    
}

extension EventsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event = filtered.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "events", for: indexPath) as! EventCell
        
        cell.configure(event: event)
        
        return cell
    }

}

extension EventsViewController: UITableViewDelegate {
    
}
