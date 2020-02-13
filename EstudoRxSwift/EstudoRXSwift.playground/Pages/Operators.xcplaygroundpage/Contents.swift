import UIKit
import RxSwift

example(of: "toArray") {
    
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C")
        .toArray()
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
}

example(of: "map") {
    
    let dispose = DisposeBag()
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    Observable<NSNumber>.of(123,4,56)
        .map {
            formatter.string(from: $0) ?? ""
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: dispose)
}

example(of: "mapWithIndex") {
    
    let dispose = DisposeBag()
    
    Observable.of(1,2,3,4,5,6,7,8,9)
    .mapWithIndex { integer , index in
        index > 1 ? integer * 2 : integer
    }
    .subscribe (onNext: {
        print($0)
    })
    .disposed(by: dispose)
}

example(of: "flatMap") {
    
    struct Student {
      var score: Variable<Int>
    }
    
    let disposeBag = DisposeBag()

    let ryan = Student(score: Variable(80))
    
    let charlotte = Student(score: Variable(90))
    
    let student = PublishSubject<Student>()
    
    student.asObservable().flatMap {
        $0.score.asObservable()
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
    
    student.onNext(ryan)
    
    ryan.score.value = 85
    
    student.onNext(charlotte)
    
    student.onNext(ryan)
}

example(of: "flapMapLatest") {
    
    struct Student {
      var score: Variable<Int>
    }
    
    let disposeBag = DisposeBag()

    let ryan = Student(score: Variable(80))
    
    let charlotte = Student(score: Variable(90))
    
    let student = PublishSubject<Student>()
    
    student.asObservable().flatMapLatest {
        $0.score.asObservable()
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
    
    student.onNext(ryan)
    
    ryan.score.value = 10
    
    student.onNext(charlotte)
    
    charlotte.score.value = 20
    
    ryan.score.value = 50
    
}
