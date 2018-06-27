//
//  Lifespan.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/13/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import RxSwift

final class Lifespan: NSObject {
    let disposeBag = DisposeBag()
    
    private var currTimer: Disposable?
    
    private(set) var lifeRemained: Int
    
    private let completePublisher = PublishSubject<Int>()
    
    var isLong: Bool {
        get {
            return lifeRemained > 10
        }
    }
    
    // Sends completion signal when lifespan expires
    var completeObservable: Observable<Int> {
        return completePublisher.asObservable()
    }
    
    
    override init() {
        // Every node gets an initial (short) amount of lifespan
        lifeRemained = increment
        
        currTimer = nil
      
        super.init()
        
        currTimer = getTimer(increment)
        
    }
    
    func addLife() {
        currTimer!.dispose()
        
        lifeRemained += increment
        
        if lifeRemained > 15 {
            lifeRemained = 1000
        }
        
        currTimer = getTimer(lifeRemained)
        
        print("LifeSpan: life remainig = \(lifeRemained)")
    }
    
    private func getTimer(_ count: Int) -> Disposable {
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

fileprivate let increment = 5

