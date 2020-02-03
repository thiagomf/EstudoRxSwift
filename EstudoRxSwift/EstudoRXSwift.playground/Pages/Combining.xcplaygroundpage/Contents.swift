import UIKit
import RxSwift

example(of: "startWith") {
    
    let observe = Observable.of(2,3,4,5)
    
    observe.startWith(1)
        .subscribe(onNext: {
        print($0)
    })
    
}

example(of: "Concat") {
    
    let observe1 = Observable.of("Thiago", "Silva")
    
    let observe2 = Observable.of("José")
    
    let observe = Observable.concat([observe1, observe2])
        .subscribe(onNext: {
            print($0)
        })
    
}

example(of: "Concat 2") {
    
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    
    let observable = germanCities.concat(spanishCities)
    
    observable.subscribe(onNext: {
        print($0)
    })
}

example(of: "") {
    
}

example(of: "Just") {
    
    let number = Observable.of(2,3,4)
    
    let observable = Observable
                        .just(1)
                        .concat(number)
    
    observable.subscribe(onNext: {
        print($0)
    })
    
}

example(of: "merge") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObservable(), right.asObservable())
    
    let observe = source.merge()
    
    let disposable = observe.subscribe(onNext: {
        print($0)
    })
    
    // 4
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    
    repeat {
        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left: " + leftValues.removeFirst())
            }
        } else
            if !rightValues.isEmpty {
                right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    
    disposable.dispose()
}

example(of: "combineLast") {
    
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable.combineLatest(left, right, resultSelector: {
        lastleft, lastRight in
        "\(lastleft) \(lastRight)"
    })
    
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    
    left.onNext("Hello")
    right.onNext("world")
    right.onNext("RxSwift")
    left.onNext("Have nice day")
    disposable.dispose()
}

example(of: "combine user choice and value") {

    let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
    
    let observable = Observable.combineLatest(choice, dates) {
        (format, when) -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "zip") {
    
    enum Weather {
        case cloudy
        case sunny
    }
    
    let left: Observable<Weather> = Observable.of(.sunny, .sunny, .cloudy, .sunny)
    let right: Observable<String> = Observable.of("São Paulo", "Rio de Janeiro", "Belo Horizonte", "Curitiba")
    
    let observable = Observable.zip(left, right) { weather, city in
        return "It's \(weather) in \(city)"
    }
    observable.subscribe(onNext: {
        print($0)
    })
}

example(of: "withLatestFrom") {
    // 1
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    // 2
    let observable = button.withLatestFrom(textField)
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    // 3
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext()
    button.onNext()
}
