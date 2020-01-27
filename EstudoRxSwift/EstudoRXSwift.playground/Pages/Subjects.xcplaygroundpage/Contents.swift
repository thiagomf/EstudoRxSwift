import UIKit
import RxSwift

//MARK: - PublishSubjects
example(of: "PublishSubject") {

    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listering?")
    
    let subscriptionOne = subject.subscribe(
        onNext: { string in
            print(string)
    })
    
    subject.on(.next("1"))
    subject.onNext("2")
    
    let subcriptionTwo = subject.subscribe { event in
        print("2)", event.element ?? event)
    }
    
    subject.onNext("3")
    
    subscriptionOne.dispose()
    
    subject.onNext("4")
    
    subject.onCompleted()
    
    subject.onNext("5")
    
    subcriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    subject.subscribe {
        print("3)", $0.element ?? $0)
    }
    .disposed(by: disposeBag)
    
    subject.onNext("?")
}

//MARK: - BehaviorSujects
enum MyError: Error {
    case anError
}

func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, event.element ?? event.error ?? event)
}

example(of: "BehaviorSubject") {
    
    let subject = BehaviorSubject(value: "Initial value")
    
    let disposeBag = DisposeBag()
    
    subject.subscribe {
        print(label: "1)", event: $0)
    }
    .addDisposableTo(disposeBag)
    
    subject.onNext("X")
    
    subject.onError(MyError.anError)
    
//    subject.onNext("Y")
    
    subject.subscribe {
        print(label: "2)", event: $0)
    }
    .disposed(by: disposeBag)

}

example(of: "ReplaySubject") {
    
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    
    let disposeBag = DisposeBag()
    
    subject.onNext("1")
    
    subject.onNext("2")
    
    subject.onNext("3")
    
    subject.subscribe {
        print(label: "1)", event: $0)
    }.addDisposableTo(disposeBag)
    
    subject.subscribe {
        print(label: "2)", event: $0)
    }.addDisposableTo(disposeBag)
    
    subject.onNext("4")
    
    subject.onError(MyError.anError)
    
//    subject.dispose()
    
    subject.subscribe {
        print(label: "3)", event: $0)
    }.addDisposableTo(disposeBag)
}


//MARK: - Variables

example(of: "Variable") {
    
    var variable = Variable<String>("Initial value")
    
    let disposeBag = DisposeBag()
    
    variable.value = "New Initial Value"
    
    variable.asObservable().subscribe {
        print(label: "1)", event: $0)
    }.addDisposableTo(disposeBag)
    
    variable.value = "Another Value"
}
