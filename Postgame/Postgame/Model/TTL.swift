//
//  TTL.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/2/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import RxSwift

final class TTL {
    private let disposeBag = DisposeBag()
    
    private var timer: Disposable?{
        didSet {
            timer?.disposed(by: disposeBag)
        }
    }
    
    // send complete signal once timer is up
    private let completePublisher = PublishSubject<Any?>()
    lazy var completeDriver = completePublisher.asDriver(onErrorJustReturn: nil)
    
    // timer is only in effect if state is initial or lengthened
    private(set) var state: TTLState = .initial
    enum TTLState { case initial, lengthened, unlimited }
    
    init() {
        timer = setTimer(5)
        completePublisher.disposed(by: disposeBag)
    }
    
    // increment TTL
    func increment() {
        switch state {
        case .initial:
            timer!.dispose()
            timer = setTimer(10)
            state = .lengthened
        case .lengthened:
            timer!.dispose()
            state  = .unlimited
        case .unlimited:
            break
        }
    }
    
    // create and subscribe to timer. send complete signal when timer reaches 0.
    private func setTimer(_ count: Int) -> Disposable {
        return createTimer(count).subscribe(onNext: { (number) in
            if number == 0 {
                self.completePublisher.onCompleted()
            }
        })
    }
    
}

fileprivate func createTimer(_ count: Int) -> Observable<Int> {
    return Observable<Int>
        .timer(0, period: 1, scheduler: MainScheduler.instance)
        .take(count + 1)
        .map { count - $0 }
}
