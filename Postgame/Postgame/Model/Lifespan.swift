//
//  Lifespan.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/13/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import RxSwift

class Lifespan: NSObject {
    
    private var currTimer: Disposable?
    private(set) var lifeRemained: Int
    private let completePublisher = PublishSubject<Int>()
    var completeObservable: Observable<Int> {
        return completePublisher.asObservable()
    }
    
    let increment = 5
    let disposeBag = DisposeBag()
    
    override init() {
        lifeRemained = increment
        currTimer = nil
      
        super.init()
        
        currTimer = getTimer(increment)
        
    }
    
    func addLife() {
        currTimer!.dispose()
        lifeRemained += increment
        currTimer = getTimer(lifeRemained)
    }
    
    fileprivate func getTimer(_ count: Int) -> Disposable {
        return timer(count).subscribe(onNext: { (number) in
            self.lifeRemained = number
            if self.lifeRemained == 0 {
                self.completePublisher.onCompleted()
            }
        })
    }
}

fileprivate func timer(_ count: Int) -> Observable<Int> {
    return Observable<Int>
        .timer(0, period: 1, scheduler: MainScheduler.instance)
        .take(count + 1)
        .map { count - $0 }
        .share()
}



