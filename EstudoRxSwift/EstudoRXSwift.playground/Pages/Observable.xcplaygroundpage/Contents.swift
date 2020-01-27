import UIKit
import RxSwift

//MARK: - Observable / Subscription
example(of: "just, of, from") {
    
    let one = 1
    let two = 2
    let three = 3
    
    let observable: Observable<Int> = Observable<Int>.just(one)
    let observable2 = Observable.of(one, two, three)
    let observable3 = Observable.of([one,two,three])
    let observable4 = Observable.from([one, two, three])
}

example(of: "subscribe") {
    
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe { event in
        print(event)
    }
    
    observable.subscribe { event in
        if let elem = event.element {
            print(elem)
        }
    }
    
    observable.subscribe(onNext: { element in
        
        print(element)
        
    })
}

example(of: "empty") {
    
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        onNext: { element in
            print(element)
    },
        onCompleted: {
            print("completed")
    })
}

example(of: "never") {
    
    let observable = Observable<Void>.never()
    
    observable.subscribe(
        onNext: { element in
            print(element)
    },
        onCompleted: {
            print("Completed")
    })
}

example(of: "range") {
    
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable.subscribe(
        onNext: { i in
            let n = Double(i)
            let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) / 2.23606).rounded())
            print(fibonacci)
    })
}

//MARK: - Disposing / Terminating

example(of: "dispose") {
    
    let observable = Observable.of("A", "B", "C")
    
    let subscription = observable.subscribe { event in
        print(event)
    }
    
    subscription.dispose()
}

example(of: "DisposeBag") {
    
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C")
        .subscribe {
            print($0)
    }
    .disposed(by: disposeBag)
}

enum MyError: Error {
    case anError
}

example(of: "create") {
    
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        
        observer.onNext("1")
        
        observer.onError(MyError.anError)
        
        observer.onCompleted()
        
        observer.onNext("?")
        
        return Disposables.create()
    }.subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed")},
        onDisposed: { print("Disposed")}
    )
    .disposed(by: disposeBag)
}

//MARK: - Oservable Factories

example(of: "deferred") {
    
    let disposeBag = DisposeBag()
    
    var flip = false
    
    let factory: Observable<Int> = Observable.deferred {
        
        flip = !flip
        
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe( onNext: {
            print($0, terminator: "")
        })
        .disposed(by: disposeBag)
        
        print()
    }
}
