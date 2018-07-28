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
    
    private(set) lazy var colorDriver = colorPublisher.asDriver(onErrorJustReturn: .flatRed)
    private let colorPublisher = PublishSubject<UIColor>()
    
    
    
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
                if nodeObservered {
//                    self?.backgroundColor = UIColor.green
                    self?.setBackgroundImage(.from(color: UIColor.green.withAlphaComponent(buttonAlpha)), for: .normal)
                    self?.setBackgroundImage(.from(color: UIColor.green.withAlphaComponent(0.75)), for: .selected)
                }
                else if rectObservered {
//                    self?.backgroundColor = UIColor.flatGreen
                    self?.setBackgroundImage(.from(color: UIColor.flatGreen.withAlphaComponent(buttonAlpha)), for: .normal)
                    self?.setBackgroundImage(.from(color: UIColor.flatGreenDark.withAlphaComponent(buttonAlpha)), for: .selected)
                }
                else if planeObservered {
//                    self?.backgroundColor = UIColor.flatForestGreen
                    self?.setBackgroundImage(.from(color: UIColor.flatForestGreen.withAlphaComponent(buttonAlpha)), for: .normal)
                    self?.setBackgroundImage(.from(color: UIColor.flatForestGreenDark.withAlphaComponent(buttonAlpha)), for: .selected)
                     self?.setImage(UIImage(named: "Smile")!, for: .normal)
                }
                else if highFPObservered {
//                    self?.backgroundColor = UIColor.flatYellow
                    self?.setBackgroundImage(.from(color: UIColor.flatYellow.withAlphaComponent(buttonAlpha)), for: .normal)
                    self?.setBackgroundImage(.from(color: UIColor.flatYellowDark.withAlphaComponent(buttonAlpha)), for: .selected)
                    self?.setImage(UIImage(named: "Neutral")!, for: .normal)
                }
                else {
//                    self?.backgroundColor = UIColor.flatRed
                    self?.setBackgroundImage(.from(color: UIColor.flatRed.withAlphaComponent(buttonAlpha)), for: .normal)
                    self?.setBackgroundImage(.from(color: UIColor.flatRedDark.withAlphaComponent(0.75)), for: .selected)
                    self?.setImage(UIImage(named: "Frown")!, for: .normal)
                }
                
                self?.colorPublisher.onNext(self?.backgroundColor ?? .flatRed)
            }).disposed(by: disposeBag)
    }
    
    func publishPerceptionStatus(_ status: ScenePerceptionStatus) {
        perceptionStatusPublisher.onNext(status)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let buttonAlpha: CGFloat = 0.5
