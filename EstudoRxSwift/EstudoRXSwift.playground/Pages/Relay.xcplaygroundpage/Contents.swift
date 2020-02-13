import UIKit
import RxSwift
import RxCocoa

//example(of: "Relay") {
//    
//    let elementPerSecond = 1
//    let maxElements = 5
//    let replayedElements = 1
//    let replayDelay: TimeInterval = 3
//
//   let sourceObservable = Observable<Int>.create { observer in
//        var value = 1
//        let timer = DispatchSource.timer(interval: 1.0 /
//                                        Double(elementPerSecond), queue: .main) {
//
//                if value <= maxElements {
//                    observer.onNext(value)
//                    value = value + 1
//                }
//        }
//
//        return Disposables.create {
//            timer.suspend()
//        }
//
//    }.replay(replayedElements)
//}
    