//
//  main.swift
//  Schedulers
//
//  Created by Thiago M Faria on 25/02/20.
//  Copyright © 2020 Thiago M Faria. All rights reserved.
//

import Foundation
import RxSwift

print("Hello, World!")

print("\n\n\n===== Schedulers =====\n")

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
let bag = DisposeBag()
let animal = BehaviorSubject(value: "[dog]")


animal
  .subscribeOn(MainScheduler.instance)
  .dump()
  .observeOn(globalScheduler)
  .dumpingSubscription()
  .disposed(by: bag)

let fruit = Observable<String>.create { (observer) in
  observer.onNext("[apple]")
  sleep(2)
  observer.onNext("[pineapple]")
  sleep(2)
  observer.onNext("[strawberry]")
  return Disposables.create()
}

let animalsThread = Thread() {
  sleep(3)
  animal.onNext("[cat]")
  sleep(3)
  animal.onNext("[tiger]")
  sleep(3)
  animal.onNext("[fox]")
  sleep(3)
  animal.onNext("[leopard]")
}

animalsThread.name = "Animals Thread"
animalsThread.start()

fruit
  .subscribeOn(globalScheduler)
  .dump()
  .observeOn(MainScheduler.instance)
  .dumpingSubscription()
  .disposed(by: bag)

RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))
