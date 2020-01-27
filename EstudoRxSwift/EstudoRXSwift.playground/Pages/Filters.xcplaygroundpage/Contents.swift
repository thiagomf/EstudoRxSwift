import UIKit
import RxSwift

example(of: "ignoreElements") {
    
    let strikes = PublishSubject<String>()
    
    let dispose = DisposeBag()
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onNext("X")
    
    strikes
        .ignoreElements()
        .subscribe { _ in
            print("You're out")
    }
    .disposed(by: dispose)
    
    strikes.onCompleted()
}

example(of: "elementAt") {
    
    let strikes = PublishSubject<String>()
    
    let dispose = DisposeBag()
    
    strikes
        .elementAt(1)
        .subscribe(onNext: { _ in
            print("You're out")
        }
    ).disposed(by: dispose)
    
    strikes.onNext("X")
    strikes.onNext("Y")
    strikes.onNext("Z")
}

example(of: "filter") {
    
    let strikes = PublishSubject<Int>()
    
    let dispose = DisposeBag()
    
    strikes
        .filter { integer in
            integer % 2 == 0
    }
    .subscribe(onNext: {
        print($0)
    })
        .disposed(by: dispose)
    
    strikes.onNext(2)
    strikes.onNext(3)
    strikes.onNext(4)
    strikes.onNext(5)
}

example(of: "skip") {
    
    let strikes = PublishSubject<String>()
    
    let dispose = DisposeBag()

    strikes
    .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: dispose)

    strikes.onNext("Thiago-0")
    strikes.onNext("Thiago-1")
    strikes.onNext("Thiago-2")
    strikes.onNext("Thiago-3")
    strikes.onNext("Thiago-4")
    
}

example(of: "skipWhile") {
    
    let dispose = DisposeBag()
    
    Observable.of(2,3,4,5,6,7,8)
        .skipWhile { integer in
            integer % 2 == 0
    }
    .subscribe(onNext: {
        print($0)
    })
        .disposed(by: dispose)
}

example(of: "skipUntil") {
    
    let dispose = DisposeBag()
    
    let subject = PublishSubject<String>()
    
    let trigger = PublishSubject<String>()
    
    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: dispose)
    
    subject.onNext("A")
    subject.onNext("B")
    subject.onNext("C")
    
    trigger.onNext("X")
    
    subject.onNext("D")
    subject.onNext("E")
    subject.onNext("F")
}

example(of: "take") {
    
    let dispose = DisposeBag()
    
    Observable.of(1,2,3,4,5)
    .take(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: dispose)
    
}

example(of: "takeWhileWithIndex") {
    
    let dispose = DisposeBag()
    
    Observable.of(2,2,6,4,5,4)
        .takeWhileWithIndex{ value, index in
            value % 2 == 0 && index < 5
    }.subscribe (onNext: {
        print($0)
    })
        .disposed(by: dispose)
}

example(of: "dictinctUntilChanged") {
    
    let dispose = DisposeBag()
    
    Observable.of("A","A","B","B","A")
    .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: dispose)
}


