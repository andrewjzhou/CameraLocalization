//
//  UserButton.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/13/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation
import RxSwift

final class UserButton: UIButton {
    private let disposeBag = DisposeBag()
    private let perceptionStatusPublisher = PublishSubject<ScenePerceptionStatus>()
    private lazy var perceptionStatusObservable = perceptionStatusPublisher.asObservable()
    enum ScenePerceptionStatus { case lowFP, highFP, plane, rect, node }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        perceptionStatusObservable
            .buffer(timeSpan: 0.2, count: 10, scheduler: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] (statusArr) in
                var highFPObservered = false, planeObservered = false,
                rectObservered = false, nodeObservered = false
                for status in statusArr {
                    switch status {
                    case .highFP: highFPObservered = true
                    case .plane: planeObservered = true
                    case .rect: rectObservered = true
                    case .node: nodeObservered = true
                    default: continue
                    }
                }
                if nodeObservered { self?.backgroundColor = UIColor.green }
                else if rectObservered { self?.backgroundColor = UIColor.flatGreen }
                else if planeObservered { self?.backgroundColor = UIColor.flatForestGreen }
                else if highFPObservered { self?.backgroundColor = UIColor.flatYellow }
                else { self?.backgroundColor = UIColor.flatRed }
            }).disposed(by: disposeBag)
    }
    
    func publishPerceptionStatus(_ status: ScenePerceptionStatus) {
        perceptionStatusPublisher.onNext(status)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
