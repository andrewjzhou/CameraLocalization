//
//  ARSession+Rx.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 6/11/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import ARKit
import RxCocoa
import RxSwift

extension Reactive where Base: ARSession {
    public var delegate: DelegateProxy<ARSession, ARSessionDelegate> {
        return RxARSessionDelegateProxy.proxy(for: base)
    }
    
    public var didUpdateFrame: Observable<ARFrame> {
        return RxARSessionDelegateProxy.proxy(for: base).didUpdateFrameSubject.asObservable()
    }
    
    public var didAddAnchors: Observable<[ARAnchor]> {
        return RxARSessionDelegateProxy.proxy(for: base).didAddAnchorsSubject.asObservable()
    }
    
    public var didRemoveAnchors: Observable<[ARAnchor]> {
        return RxARSessionDelegateProxy.proxy(for: base).didRemoveAnchorsSubject.asObservable()
    }
    
    public var didUpdateAnchors: Observable<[ARAnchor]> {
        return RxARSessionDelegateProxy.proxy(for: base).didUpdateAnchorsSubject.asObservable()
    }
    
    public var cameraDidChangeTrackingState: Observable<ARCamera> {
        return RxARSessionDelegateProxy.proxy(for: base).cameraDidChangeTrackingStateSubject.asObservable()
    }
    
    public var didFailWithError: Observable<Error> {
        return RxARSessionDelegateProxy.proxy(for: base).didFailWithErrorSubject.asObservable()
    }
    
    
    public var sessionWasInterrupted: Observable<Int> {
        return RxARSessionDelegateProxy.proxy(for: base).sessionWasInterruptedSubject.asObservable()
    }
    
    public var sessionInterruptionEnded: Observable<Int> {
        return RxARSessionDelegateProxy.proxy(for: base).sessionInterruptionEndedSubject.asObservable()
    }
    
}
