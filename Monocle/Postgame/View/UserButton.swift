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
            .drive(onNext: { [unowned self] (statusArr) in
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
                    self.colorPublisher.onNext(.green)
                    self.setBackgroundImage(self.nodeNormalBI, for: .normal)
                    self.setBackgroundImage(self.nodeSelectedBI, for: .selected)
                    self.setImage(self.smileImage, for: .normal)
                }
                else if rectObservered {
                    self.colorPublisher.onNext(.flatGreen)
                    self.setBackgroundImage(self.rectNormalBI, for: .normal)
                    self.setBackgroundImage(self.rectSelectedBI, for: .selected)
                    self.setImage(self.smileImage, for: .normal)
                }
                else if planeObservered {
                    self.colorPublisher.onNext(.flatForestGreen)
                    self.setBackgroundImage(self.planeNormalBI, for: .normal)
                    self.setBackgroundImage(self.planeSelectedBI, for: .selected)
                    self.setImage(self.smileImage, for: .normal)
                }
                else if highFPObservered {
                    self.colorPublisher.onNext(.flatYellow)
                    self.setBackgroundImage(self.highFPNormalBI, for: .normal)
                    self.setBackgroundImage(self.highFPSelectedBI, for: .selected)
                    self.setImage(self.neutralImage, for: .normal)
                }
                else {
                    self.colorPublisher.onNext(.flatRed)
                    self.setBackgroundImage(self.lowFPNormalBI, for: .normal)
                    self.setBackgroundImage(self.lowFPSelectedBI, for: .selected)
                    self.setImage(self.frownImage, for: .normal)
                }
            
            }).disposed(by: disposeBag)
    }
    
    func publishPerceptionStatus(_ status: ScenePerceptionStatus) {
        perceptionStatusPublisher.onNext(status)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Color background images
    let nodeNormalBI = UIImage.from(color: UIColor.green.withAlphaComponent(buttonAlpha))
    let nodeSelectedBI = UIImage.from(color: UIColor.green.withAlphaComponent(0.75))
    let rectNormalBI = UIImage.from(color: UIColor.flatGreen.withAlphaComponent(buttonAlpha))
    let rectSelectedBI = UIImage.from(color: UIColor.flatGreenDark.withAlphaComponent(buttonAlpha))
    let planeNormalBI = UIImage.from(color: UIColor.flatForestGreen.withAlphaComponent(buttonAlpha))
    let planeSelectedBI = UIImage.from(color: UIColor.flatForestGreenDark.withAlphaComponent(buttonAlpha))
    let highFPNormalBI = UIImage.from(color: UIColor.flatYellow.withAlphaComponent(buttonAlpha))
    let highFPSelectedBI = UIImage.from(color: UIColor.flatYellowDark.withAlphaComponent(buttonAlpha))
    let lowFPNormalBI = UIImage.from(color: UIColor.flatRed.withAlphaComponent(buttonAlpha))
    let lowFPSelectedBI = UIImage.from(color: UIColor.flatRedDark.withAlphaComponent(buttonAlpha))
    
    // Expression background images
    let frownImage = UIImage(named: "Frown")!
    let neutralImage = UIImage(named: "Neutral")!
    let smileImage = UIImage(named: "Smile")!
    
    
}


fileprivate let buttonAlpha: CGFloat = 0.8


