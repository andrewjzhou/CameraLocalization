//
//  CreationView.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 4/18/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreationView: UIView {
    fileprivate let disposeBag = DisposeBag()
    
    // UI Buttons
    private let drawButton = UIButton()
    private let textButton = UIButton()
    private let photoLibraryButton = UIButton()
    private let cancelButton = UIButton()
    private let finishButton = UIButton()
    
    // Subviews
    let slateView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        
        // Setup layout of main UIButtons and slateView
        setupSlateView()
        setupDrawButton()
        setupTextButton()
        setupPhotoLibraryButton()
        setupFinishButton()
        setupCancelButton()
        
        // Setup layout and functions of drawing components
        setupDrawingLayoutAndRx()
        
        // Control main UIButtons (excluding drawing components) - React to drawButton tap gesture
        drawButton.rx.tap
            .subscribe(onNext: { (_) in
                if self.drawButton.isSelected {
                    UIView.animate(withDuration: 0.3, animations: {
                        // Move drawButton back to original position
                        self.drawButton.transform = .identity
                        
                        // Hide all other UIButtons (excluding drawing components)
                        self.textButton.alpha = 1
                        self.photoLibraryButton.alpha = 1
                        self.finishButton.alpha = 1
                        self.cancelButton.alpha = 1
                    })
                    
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        // Move drawButton to offset at -0.2*screenWidth w.r.t current trailing anchor
                        self.drawButton.transform = CGAffineTransform(translationX: screenWidth * 0.17, y: 0)
                        
                        // Show all other UIButtons (excluding drawing components)
                        self.textButton.alpha = 0
                        self.photoLibraryButton.alpha = 0
                        self.finishButton.alpha = 0
                        self.cancelButton.alpha = 0
                    })
                }
                
                // Toggle isSelected state
                self.drawButton.isSelected = !self.drawButton.isSelected
            })
            .disposed(by: disposeBag)
    }
    
    override func didMoveToSuperview() {
        // Setup layout of CreationView inside superview
        guard let parent = superview else {
            fatalError("CreationView: No Superview Found")
        }
        translatesAutoresizingMaskIntoConstraints = false
        setWidthConstraint(parent.frame.width)
        setHeightConstraint(parent.frame.height)
        setCenterXConstraint(equalTo: parent.centerXAnchor, offset: 0)
        setCenterYConstraint(equalTo: parent.centerYAnchor, offset: 0)
        
        // Animate main UI elements upon entrance
        UIView.animate(withDuration: 0.3) {
            self.slateView.transform = .identity
            self.drawButton.transform = .identity
            self.textButton.transform = .identity
            self.photoLibraryButton.transform = .identity
            self.finishButton.transform = .identity
            self.cancelButton.transform = .identity
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK:- Setup main UI elements layout (excluding drawing-, text-, and photoLibrary-specific elements)
extension CreationView {
    /**
     Setup slateView where creation happens close to center of view.
     */
    private func setupSlateView() {
        addSubview(slateView)
        slateView.translatesAutoresizingMaskIntoConstraints = false
        slateView.backgroundColor = .white
        slateView.setWidthConstraint(screenWidth * 0.9)
        slateView.setHeightConstraint(screenHeight * 0.6)
        slateView.setCenterXConstraint(equalTo: centerXAnchor, offset: 0)
        slateView.setCenterYConstraint(equalTo: centerYAnchor, offset: -0.06 * screenHeight)
        slateView.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
    }
    
    /**
     Setup drawButton positioned under slateView to right.
     */
    private func setupDrawButton() {
        addSubview(drawButton)
        drawButton.setImage(UIImage(named: "ic_create_white"), for: .normal)
        setButtonBasics(drawButton)
        drawButton.setTrailingConstraint(equalTo: slateView.trailingAnchor, offset: -0.2 * screenWidth)
        drawButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.05 * screenHeight)
        drawButton.transform = CGAffineTransform(translationX: 0, y: screenHeight)
    }
    
    /**
     Setup textButton positioned under slateView to left.
     */
    private func setupTextButton() {
        addSubview(textButton)
        textButton.setImage(UIImage(named: "ic_title_white"), for: .normal)
        setButtonBasics(textButton)
        textButton.setLeadingConstraint(equalTo: slateView.leadingAnchor, offset: 0.2 * screenWidth)
        textButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.05 * screenHeight)
        textButton.transform = CGAffineTransform(translationX: 0, y: screenHeight)
    }
    
    /**
     Setup photoLibraryButton positioned under slateView.
     */
    private func setupPhotoLibraryButton() {
        addSubview(photoLibraryButton)
        photoLibraryButton.setImage(UIImage(named: "ic_photo_white"), for: .normal)
        setButtonBasics(photoLibraryButton)
        photoLibraryButton.setCenterXConstraint(equalTo: slateView.centerXAnchor, offset: 0)
        photoLibraryButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.05 * screenHeight)
        photoLibraryButton.transform = CGAffineTransform(translationX: 0, y: screenHeight)
    }
    
    /**
     Setup finishButton positioned above slateView to right.
     */
    private func setupFinishButton() {
        addSubview(finishButton)
        finishButton.setImage(UIImage(named: "ic_done"), for: .normal)
        setButtonBasics(finishButton)
        finishButton.setTrailingConstraint(equalTo: slateView.trailingAnchor, offset: -0.015 * screenWidth)
        finishButton.setBottomConstraint(equalTo: slateView.topAnchor, offset: -0.02 * screenHeight)
        finishButton.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
    }
    
    /**
     Setup cancelButton positioned above slateView to left.
     */
    private func setupCancelButton() {
        addSubview(cancelButton)
        cancelButton.setImage(UIImage(named: "ic_close"), for: .normal)
        setButtonBasics(cancelButton)
        cancelButton.setLeadingConstraint(equalTo: slateView.leadingAnchor, offset: 0.015 * screenWidth)
        cancelButton.setBottomConstraint(equalTo: slateView.topAnchor, offset: -0.02 * screenHeight)
        cancelButton.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
    }
    
}


// MARK:- Drawing-specific UI elements + functions
extension CreationView {
    /**
     Setup drawView, undoButton, and colorslilder. Connect them.
     */
    private func setupDrawingLayoutAndRx() {
        // Setup drawView, which auto-sets own constraints
        let drawView = DrawView()
        slateView.addSubview(drawView)
        drawView.isActive = false
        
        // Setup colorSlider, then hide
        let drawColorSlider = ColorSlider()
        addSubview(drawColorSlider)
        drawColorSlider.translatesAutoresizingMaskIntoConstraints = false
        drawColorSlider.orientation = .horizontal
        drawColorSlider.previewEnabled = true
        drawColorSlider.setWidthConstraint(screenWidth * 0.45)
        drawColorSlider.setHeightConstraint(screenHeight * 0.03)
        drawColorSlider.setCenterXConstraint(equalTo: centerXAnchor, offset: 0)
        drawColorSlider.setTopConstraint(equalTo: slateView.bottomAnchor, offset: screenHeight * 0.07)
        drawColorSlider.alpha = 0
        
        // Set drawView color using drawColorSlider - React to drawColorSlider's colorObservable
        drawColorSlider.colorObservable
            .asDriver(onErrorJustReturn: .red)
            .drive(onNext: { (color) in
                drawView.color = color.cgColor
            })
            .disposed(by: disposeBag)
        
        
        // Setup undoButton, then hide
        let undoButton = UIButton()
        addSubview(undoButton)
        setButtonBasics(undoButton)
        undoButton.setImage(UIImage(named: "ic_undo"), for: .normal)
        undoButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: screenHeight * 0.05)
        undoButton.setLeadingConstraint(equalTo: slateView.leadingAnchor, offset: screenWidth * 0.03)
        undoButton.alpha = 0
        
        // Undo drawing - React to undoButton tap gesture
        undoButton.rx.tap
            .subscribe(onNext: { (_) in
                drawView.undo()
            })
            .disposed(by: disposeBag)
        
        
        // Activate/Hide drawing components - React to DrawButton
        drawButton.rx.tap
            .subscribe(onNext: { (_) in
                if self.drawButton.isSelected {
                    // Hide drawing components
                    drawView.isActive = false
                    UIView.animate(withDuration: 0.15, animations: {
                        drawColorSlider.alpha = 0
                    })
                    undoButton.alpha = 0
                } else {
                    // Show drawing components
                    drawView.isActive = true
                    self.slateView.bringSubview(toFront: drawView)
                    UIView.animate(withDuration: 0.15, animations: {
                        drawColorSlider.alpha = 1
                    })
                    undoButton.alpha = 1
                }
            })
            .disposed(by: disposeBag)
    }
}


// Constants
fileprivate let buttonLength : CGFloat = 54.0
fileprivate let buttonAlpha : CGFloat = 0.5
fileprivate let screenHeight = UIScreen.main.bounds.height
fileprivate let screenWidth = UIScreen.main.bounds.width


/**
 Tune button basics for buttons on main screen.
*/
fileprivate func setButtonBasics(_ button: UIButton) {
    button.translatesAutoresizingMaskIntoConstraints = false
    button.clipsToBounds = true
    button.layer.cornerRadius = 0.5 * buttonLength
    button.setBackgroundImage(.from(color: UIColor.white.withAlphaComponent(buttonAlpha)), for: .normal)
    button.setBackgroundImage(.from(color: UIColor.gray.withAlphaComponent(buttonAlpha)), for: .selected)
    button.setWidthConstraint(buttonLength)
    button.setHeightConstraint(buttonLength)
}
