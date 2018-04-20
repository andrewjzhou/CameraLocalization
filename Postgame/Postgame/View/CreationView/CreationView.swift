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
    
    // viewDidLoad UI Buttons (buttons that appear immediately when view loads)
    private let drawButton = UIButton()
    private let textButton = UIButton()
    private let photoPickerButton = UIButton()
    private let cancelButton = UIButton()
    private let finishButton = UIButton()
    
    // Subviews
    private let slateView = UIImageView()
    private var textView: ResizableView?
    
    
    // Observable to publish and communicate with ViewController
    public lazy var exitSubject = PublishSubject<UIImage?>()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup layout of viewDidLoad UIButtons and slateView
        setupSlateView()
        setupDrawButton()
        setupTextButton()
        setupPhotoPickerButton()
        setupFinishButton()
        setupCancelButton()
    
        // Setup layout and rx of drawing-, photoPicker-, and text-specific components
        setupDrawingLayoutAndRx()
        setupPhotoPickerLayoutAndRx()
        setupTextLayoutAndRx()
        
        /**
         Control ViewDidLoad UIButtons (excluding drawing components) - React to drawButton tap gesture
        */
        drawButton.rx.tap
            .share()
            .subscribe(onNext: { (_) in
                if self.drawButton.isSelected {
                    UIView.animate(withDuration: 0.3, animations: {
                        // Move drawButton back to original position
                        self.drawButton.transform = .identity
                        
                        // Hide all other UIButtons (excluding drawing components)
                        self.textButton.alpha = 1
                        self.photoPickerButton.alpha = 1
                        self.finishButton.alpha = 1
                        self.cancelButton.alpha = 1
                    })
                    
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        // Move drawButton to offset at -0.2*screenWidth w.r.t current trailing anchor
                        self.drawButton.transform = CGAffineTransform(translationX: screenWidth * 0.17, y: 0)
                        
                        // Show all other UIButtons (excluding drawing components)
                        self.textButton.alpha = 0
                        self.photoPickerButton.alpha = 0
                        self.finishButton.alpha = 0
                        self.cancelButton.alpha = 0
                    })
                }
                
                // Toggle isSelected state
                self.drawButton.isSelected = !self.drawButton.isSelected
            })
            .disposed(by: disposeBag)
        
        
        /**
         Capture image on slateView and publish - React to finishButton tap gesture
         */
        finishButton.rx.tap
            .map {return self.captureSlateImage()}
            .bind(to: exitSubject)
            .disposed(by: disposeBag)
        

        /**
         Exit creationView and publish nil image - React to cancelButton tap gesture
         */
        cancelButton.rx.tap
            .map {return nil}
            .bind(to: exitSubject)
            .disposed(by: disposeBag)
    }


    override func didMoveToSuperview() {
        // Setup layout of CreationView inside superview
        guard let parent = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        setWidthConstraint(parent.frame.width)
        setHeightConstraint(parent.frame.height)
        setCenterXConstraint(equalTo: parent.centerXAnchor, offset: 0)
        setCenterYConstraint(equalTo: parent.centerYAnchor, offset: 0)

        // Animate main UI elements upon entrance
        self.animateEntrance()
    
    }
    
    override func removeFromSuperview() {
        animateExit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            super.removeFromSuperview()
        }
    }
    
    /**
     Animate entrance of UI elements in creationView.
     */
    func animateEntrance() {
        self.alpha = 1
        UIView.animate(withDuration: 0.3) {
            self.slateView.transform = .identity
            self.drawButton.transform = .identity
            self.textButton.transform = .identity
            self.photoPickerButton.transform = .identity
            self.finishButton.transform = .identity
            self.cancelButton.transform = .identity
        }
    }
    
    /**
     Animate exit of UI elements in creationView.
     */
    func animateExit() {
        UIView.animate(withDuration: 0.3, animations: { // animate exit
            self.drawButton.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            self.textButton.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            self.photoPickerButton.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            self.finishButton.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            self.cancelButton.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            self.slateView.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
        }) { (true) in
            self.alpha = 0
        }
    }
    
    
    /**
     Capture user-created image inside slateView.
     */
    private func captureSlateImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.slateView.bounds.size, false, UIScreen.main.scale)
        self.slateView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK:- Setup viewDidLoad UI layout (excluding drawing-, text-, and photoLibrary-specific elements)
extension CreationView {
    /**
     Setup slateView where creation happens close to center of view.
     */
    private func setupSlateView() {
        addSubview(slateView)
        slateView.isUserInteractionEnabled = true
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
    private func setupPhotoPickerButton() {
        addSubview(photoPickerButton)
        photoPickerButton.setImage(UIImage(named: "ic_photo_white"), for: .normal)
        setButtonBasics(photoPickerButton)
        photoPickerButton.setCenterXConstraint(equalTo: slateView.centerXAnchor, offset: 0)
        photoPickerButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.05 * screenHeight)
        photoPickerButton.transform = CGAffineTransform(translationX: 0, y: screenHeight)
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


// MARK:- Drawing-specific UI + Rx
extension CreationView {
    /**
     Setup drawView, undoButton, and colorslilder. Connect them.
     */
    private func setupDrawingLayoutAndRx() {
        
        let drawView = DrawView()
        slateView.addSubview(drawView)
        drawView.translatesAutoresizingMaskIntoConstraints = false
        drawView.setTopConstraint(equalTo: slateView.topAnchor, offset: 0)
        drawView.setBottomConstraint(equalTo: slateView.bottomAnchor, offset: 0)
        drawView.setLeadingConstraint(equalTo: slateView.leadingAnchor, offset: 0)
        drawView.setTrailingConstraint(equalTo: slateView.trailingAnchor, offset: 0)
        drawView.isActive = false // Make drawView initially unactive
        
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
        drawColorSlider.colorSubject
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
        
        /**
         Undo drawing - React to undoButton tap gesture
         */
        undoButton.rx.tap
            .subscribe(onNext: { (_) in
                drawView.undo()
            })
            .disposed(by: disposeBag)
        
        
        /**
         Activate/Hide drawing components - React to DrawButton
         */
        drawButton.rx.tap
            .share()
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

// MARK:- PhotoPicker-specific UI + Rx
extension CreationView {
    /**
     Setup photoPickerView layout and Rx.
     */
    private func setupPhotoPickerLayoutAndRx(){
        // setup photoPicker layout
        let photoPickerView = PhotoPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0.3 * screenHeight),
                                              buttonSize: buttonLength)
        addSubview(photoPickerView)
        photoPickerView.translatesAutoresizingMaskIntoConstraints = false
        photoPickerView.setCenterXConstraint(equalTo: centerXAnchor, offset: 0)
        let identityBottomConstraint = photoPickerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        let translationBottomConstraint = photoPickerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: screenHeight)
        translationBottomConstraint.isActive = true
        
        /**
         Set slateView background image - React to photoPickerView imageSubject
         */
        photoPickerView.imageSubject
            .subscribe(onNext: { (image) in
                self.slateView.image = image
            })
            .disposed(by: disposeBag)
        
        
        /**
         Hide PhotoPicker - React to downButton inside photoPickerView tap gesture
         */
        photoPickerView.downButton.rx.tap
            .subscribe(onNext: { (_) in
                identityBottomConstraint.isActive = false
                translationBottomConstraint.isActive = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                    self.drawButton.alpha = 1
                    self.photoPickerButton.alpha = 1
                    self.textButton.alpha = 1
                })
            })
            .disposed(by: disposeBag)
        
        
        /**
         Show PhotoPicker - React to photoPickerButton tap gesture
         */
        photoPickerButton.rx.tap
            .subscribe(onNext: { (_) in
                translationBottomConstraint.isActive = false
                identityBottomConstraint.isActive = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.layoutIfNeeded()
                    self.drawButton.alpha = 0
                    self.photoPickerButton.alpha = 0
                    self.textButton.alpha = 0
                })
            })
            .disposed(by: disposeBag)
    }
    
}


// MARK:- Text-specific Rx
extension CreationView {
    private func setupTextLayoutAndRx() {
        // Setup textColorSlider
        let textColorSlider = ColorSlider()
        addSubview(textColorSlider)
        textColorSlider.translatesAutoresizingMaskIntoConstraints = false
        textColorSlider.orientation = .horizontal
        textColorSlider.previewEnabled = true
        textColorSlider.setWidthConstraint(screenWidth * 0.45)
        textColorSlider.setHeightConstraint(screenHeight * 0.03)
        textColorSlider.setCenterXConstraint(equalTo: centerXAnchor, offset: 0)
        textColorSlider.setBottomConstraint(equalTo: slateView.topAnchor, offset: screenHeight * -0.04)
        textColorSlider.alpha = 0
        
        /**
         Show textView - React to textButton tap gesture
         */
        textButton.rx.tap
            .subscribe(onNext: { (_) in
                if self.textView == nil {
                    // Add textView, if it does not already exist
                    self.textView = ResizableView()
                    self.textView!.frame = CGRect.init(x: 0.3 * self.slateView.bounds.width,
                                                 y: 0.4 * self.slateView.bounds.height,
                                                 width: 0.4 * self.slateView.bounds.width,
                                                 height: 0.2 * self.slateView.bounds.height)
                    self.textView!.autocorrectionType = .no
                    self.slateView.addSubview(self.textView!)
                    
                    /**
                     Show textColorSlider and handles. Hide finishButton and cancelButton when editing begins - React to textView didBeginEditing
                     */
                    self.textView!.rx.didBeginEditing
                        .subscribe(onNext: { (_) in
                            self.textView!.showHandles = true
                            UIView.animate(withDuration: 0.1, animations: {
                                self.textView!.showHandles = true
                                self.bringSubview(toFront: self.textView!)
                                textColorSlider.alpha = 1
                                self.finishButton.alpha = 0
                                self.cancelButton.alpha = 0
                            })
                        })
                        .disposed(by: self.disposeBag)
                    
                    /**
                     Hide textColorSlider and handles. Show finishButton and cancelButton when editing begins - React to textView didEndEditing
                     */
                    self.textView!.rx.didEndEditing
                        .subscribe(onNext: { (_) in
                            UIView.animate(withDuration: 0.1, animations: {
                                textColorSlider.alpha = 0
                                self.finishButton.alpha = 1
                                self.cancelButton.alpha = 1
                            })
                        })
                        .disposed(by: self.disposeBag)
                    
                    /**
                     Select textView texColor using textColorSlider. - React to textColorSlider colorObservable
                     */
                    textColorSlider.colorSubject
                        .subscribe(onNext: { (color) in
                            self.textView!.textColor = color
                        })
                        .disposed(by: self.disposeBag)
                    
                    self.textView!.becomeFirstResponder()
                    
                } else {
                    // Select current TextView, if it already exists
                    self.textView!.becomeFirstResponder()
                    self.bringSubview(toFront: self.textView!)
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
