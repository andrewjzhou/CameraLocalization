//
//  RxARSessionDelegateProxy.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/11/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import RxSwift
import RxCocoa
import ARKit

//Delegate methods translation incomplete

extension ARSession: HasDelegate {
    public typealias Delegate = ARSessionDelegate
}

public class RxARSessionDelegateProxy
    : DelegateProxy<ARSession, ARSessionDelegate>
    , DelegateProxyType
, ARSessionDelegate {
    
    public init(session: ARSession) {
        super.init(parentObject: session, delegateProxy: RxARSessionDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxARSessionDelegateProxy(session: $0) }
    }
    
    internal lazy var didUpdateFrameSubject = PublishSubject<ARFrame>()
    internal lazy var didAddAnchorsSubject = PublishSubject<[ARAnchor]>()
    internal lazy var didRemoveAnchorsSubject = PublishSubject<[ARAnchor]>()
    internal lazy var didUpdateAnchorsSubject = PublishSubject<[ARAnchor]>()
    internal lazy var cameraDidChangeTrackingStateSubject = PublishSubject<ARCamera>()
    internal lazy var didFailWithErrorSubject = PublishSubject<Error>()
    internal lazy var sessionWasInterruptedSubject = PublishSubject<Int>()
    internal lazy var sessionInterruptionEndedSubject = PublishSubject<Int>()
   
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        _forwardToDelegate?.session?(session, didUpdate: frame)
        didUpdateFrameSubject.onNext(frame)
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        _forwardToDelegate?.session?(session, didAdd: anchors)
        didAddAnchorsSubject.onNext(anchors)
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        _forwardToDelegate?.session?(session, didRemove: anchors)
        didRemoveAnchorsSubject.onNext(anchors)
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        _forwardToDelegate?.session?(session, didUpdate: anchors)
        didUpdateAnchorsSubject.onNext(anchors)
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        _forwardToDelegate?.session?(session, cameraDidChangeTrackingState: camera)
        cameraDidChangeTrackingStateSubject.onNext(camera)
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        _forwardToDelegate?.session?(session, didFailWithError: error)
        didFailWithErrorSubject.onNext(error)
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        _forwardToDelegate?.sessionWasInterrupted?(session)
        sessionWasInterruptedSubject.onNext(0)
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        _forwardToDelegate?.sessionInterruptionEnded?(session)
        sessionInterruptionEndedSubject.onNext(0)
    }

    
    deinit {
        self.didUpdateFrameSubject.on(.completed)
        self.didAddAnchorsSubject.on(.completed)
        self.didRemoveAnchorsSubject.on(.completed)
        self.didUpdateAnchorsSubject.on(.completed)
        self.cameraDidChangeTrackingStateSubject.on(.completed)
        self.didFailWithErrorSubject.on(.completed)
        self.sessionWasInterruptedSubject.on(.completed)
        self.sessionInterruptionEndedSubject.on(.completed)
    }
}

