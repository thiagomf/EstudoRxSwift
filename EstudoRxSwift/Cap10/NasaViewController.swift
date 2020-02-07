//
//  NasaViewController.swift
//  EstudoRxSwift
//
//  Created by Thiago M Faria on 06/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NasaViewController: UITableViewController {
    
    let categories = BehaviorRelay<[EOCategory]>(value: [])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView?.reloadData()
                }
            })
                .disposed(by: disposeBag)
                
                startDownload()
        }
    
    func startDownload() {
        
        let eoCategories = EONET.categories
        
        let downloadedEvents = eoCategories.flatMap { categories in
            return Observable.from(categories.map { category in
                EONET.events(forLast: 360, category: category)
            })
        }.merge()
        
        
        let updatedCategories = eoCategories.flatMap { categories in
            downloadedEvents.scan(categories) { updated, events in
                return updated.map { category in
                    
                    let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category)
                    
                    if !eventsForCategory.isEmpty {
                        var cat = category
                        cat.events = cat.events + eventsForCategory
                        return cat
                    }
                    return category
                }
            }
        }
        
        eoCategories
            .concat(updatedCategories)
            .bind(to: categories)
            .disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = categories.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "\(category.name) (\(category.events.count))"
        cell.detailTextLabel?.text = ""
        cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories.value[indexPath.row]
        if !category.events.isEmpty {
            let eventsController = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
            eventsController.title = category.name
            eventsController.events.accept(category.events)
            navigationController!.pushViewController(eventsController, animated:
                true) }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

}
