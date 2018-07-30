//
//  CountView.swift
//  project
//
//  Created by Andrew Jay Zhou on 3/26/18.
//  Copyright © 2018 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import RxSwift
import AWSUserPoolsSignIn

final class CountView: UIView {
    let disposeBag = DisposeBag()
    
    let totalView = TotalView()
    let historyView = HistoryView()
    var viewCount: ViewCount?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(totalView)
        totalView.translatesAutoresizingMaskIntoConstraints = false
        totalView.setTopConstraint(equalTo: topAnchor, offset: 0)
        totalView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        totalView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        totalView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        
        addSubview(historyView)
        historyView.translatesAutoresizingMaskIntoConstraints = false
        historyView.setLeadingConstraint(equalTo: leadingAnchor, offset: 0)
        historyView.setTrailingConstraint(equalTo: trailingAnchor, offset: 0)
        historyView.setTopConstraint(equalTo: totalView.bottomAnchor, offset: 0)
        historyView.setBottomConstraint(equalTo: bottomAnchor, offset: 0)
        
        
    }
    
    func refresh() {
        // Total Views
        AppSyncService.sharedInstance.queryTotalViews().asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [unowned self] (viewCount) in
                self.totalView.setNumber(viewCount)
                self.historyView.showOnboarding = (viewCount == 0)
            }).disposed(by: disposeBag)
        
        // Top Viewed
        AppSyncService.sharedInstance.queryMostViewed().asDriver(onErrorJustReturn: [])
            .drive(onNext: { [historyView] (infoArr) in
                historyView.topInfos = infoArr
            }).disposed(by: disposeBag)
        
        // Most Recent
        AppSyncService.sharedInstance.queryMostRecent().asDriver(onErrorJustReturn: [])
            .drive(onNext: { [historyView] (infoArr) in
                historyView.recentInfos = infoArr
            }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


