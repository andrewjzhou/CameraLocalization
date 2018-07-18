//
//  CreationViewController.swift
//  Postgame
//
//  Created by Andrew Jay Zhou on 7/15/18.
//  Copyright © 2018 postgame. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

final class CreationViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    // viewDidLoad UI Buttons (buttons that appear immediately when view loads)
    let drawButton = UIButton()
    let textButton = UIButton()
    let photoPickerButton = UIButton()
    let cancelButton = UIButton()
    let finishButton = UIButton()
    
    // Subviews
    let slateView = UIImageView()
    var textView: ResizableView?
    
    
    // Observable to publish and communicate with ViewController
    public lazy var exitSubject = PublishSubject<UIImage?>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.flatBlack.withAlphaComponent(0.8)
        
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
}


extension CreationViewController {

    /**
     Setup slateView where creation happens close to center of view.
     */
    private func setupSlateView() {
        view.addSubview(slateView)
        slateView.isUserInteractionEnabled = true
        slateView.translatesAutoresizingMaskIntoConstraints = false
        slateView.backgroundColor = .flatWhite
        slateView.setWidthConstraint(screenWidth * 0.9)
        slateView.setHeightConstraint(screenHeight * 0.6)
        slateView.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        slateView.setCenterYConstraint(equalTo: view.centerYAnchor, offset: -0.06 * screenHeight)
        slateView.layer.cornerRadius = 10
    }
    
    
    /**
     Setup drawButton positioned under slateView to right.
     */
    private func setupDrawButton() {
        view.addSubview(drawButton)
        drawButton.setImage(UIImage(named: "ic_create_white"), for: .normal)
        setButtonBasics(drawButton)
        drawButton.setTrailingConstraint(equalTo: slateView.trailingAnchor, offset: -0.2 * screenWidth)
        drawButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.05 * screenHeight)
    }
    
    /**
     Setup textButton positioned under slateView to left.
     */
    private func setupTextButton() {
        view.addSubview(textButton)
        textButton.setImage(UIImage(named: "ic_title_white"), for: .normal)
        setButtonBasics(textButton)
        textButton.setLeadingConstraint(equalTo: slateView.leadingAnchor, offset: 0.2 * screenWidth)
        textButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.05 * screenHeight)
    }
    
    /**
     Setup photoLibraryButton positioned under slateView.
     */
    private func setupPhotoPickerButton() {
        view.addSubview(photoPickerButton)
        photoPickerButton.setImage(UIImage(named: "ic_photo_white"), for: .normal)
        setButtonBasics(photoPickerButton)
        photoPickerButton.setCenterXConstraint(equalTo: slateView.centerXAnchor, offset: 0)
        photoPickerButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.05 * screenHeight)
    }
    
    /**
     Setup finishButton positioned above slateView to right.
     */
    private func setupFinishButton() {
        view.addSubview(finishButton)
        finishButton.setImage(UIImage(named: "ic_done"), for: .normal)
        setButtonBasics(finishButton)
        finishButton.setTrailingConstraint(equalTo: slateView.trailingAnchor, offset: -0.015 * screenWidth)
        finishButton.setBottomConstraint(equalTo: slateView.topAnchor, offset: -0.02 * screenHeight)
    }
    
    /**
     Setup cancelButton positioned above slateView to left.
     */
    private func setupCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.setImage(UIImage(named: "ic_close"), for: .normal)
        setButtonBasics(cancelButton)
        cancelButton.setLeadingConstraint(equalTo: slateView.leadingAnchor, offset: 0.015 * screenWidth)
        cancelButton.setBottomConstraint(equalTo: slateView.topAnchor, offset: -0.02 * screenHeight)
    }
}


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

// MARK:- PhotoPicker-specific UI + Rx
extension CreationViewController {
    /**
     Setup photoPickerView layout and Rx.
     */
    private func setupPhotoPickerLayoutAndRx(){
        // setup photoPicker layout
        let photoPickerView = PhotoPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0.3 * screenHeight),
                                              buttonSize: buttonLength)
        view.addSubview(photoPickerView)
        photoPickerView.translatesAutoresizingMaskIntoConstraints = false
        photoPickerView.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        let identityBottomConstraint = photoPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        let translationBottomConstraint = photoPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: screenHeight)
        translationBottomConstraint.isActive = true
        
        /**
         Set slateView background image - React to photoPickerView imageSubject
         */
        photoPickerView.imageSubject
            .subscribe(onNext: { [slateView](image) in
                slateView.image = image
            })
            .disposed(by: disposeBag)
        
        
        /**
         Hide PhotoPicker - React to downButton inside photoPickerView tap gesture
         */
        photoPickerView.downButton.rx.tap
            .subscribe(onNext: {[weak self] (_) in
                identityBottomConstraint.isActive = false
                translationBottomConstraint.isActive = true
                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                    self?.drawButton.alpha = 1
                    self?.photoPickerButton.alpha = 1
                    self?.textButton.alpha = 1
                })
            })
            .disposed(by: disposeBag)
        
        
        /**
         Show PhotoPicker - React to photoPickerButton tap gesture
         */
        photoPickerButton.rx.tap
            .do(onNext: { (_) in
                if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        if status != PHAuthorizationStatus.authorized {
                            let alertController = UIAlertController(title: "Photos",
                                                                    message: "Require permssion to add photos from library",
                                                                    preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                            alertController.addAction(cancelAction)
                            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                    return
                                }
                                
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                        print("Settings opened: \(success)") // Prints true
                                    })
                                }
                            }
                            alertController.addAction(settingsAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    })
                }
            })
            .filter{ return PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized }
            .subscribe(onNext: { [weak self] (_) in
                translationBottomConstraint.isActive = false
                identityBottomConstraint.isActive = true
                UIView.animate(withDuration: 0.3, animations: {
                    self?.view.layoutIfNeeded()
                    self?.drawButton.alpha = 0
                    self?.photoPickerButton.alpha = 0
                    self?.textButton.alpha = 0
                })
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK:- Text-specific Rx
extension CreationViewController {
    private func setupTextLayoutAndRx() {
        // Setup textColorSlider
        let textColorSlider = ColorSlider()
        view.addSubview(textColorSlider)
        textColorSlider.translatesAutoresizingMaskIntoConstraints = false
        textColorSlider.orientation = .horizontal
        textColorSlider.previewEnabled = true
        textColorSlider.setWidthConstraint(screenWidth * 0.45)
        textColorSlider.setHeightConstraint(screenHeight * 0.03)
        textColorSlider.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
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
                                self.view.bringSubview(toFront: self.textView!)
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
                    self.view.bringSubview(toFront: self.textView!)
                }
            })
            .disposed(by: disposeBag)
        
        
    }
}

// MARK:- Drawing-specific UI + Rx
extension CreationViewController {
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
        view.addSubview(drawColorSlider)
        drawColorSlider.translatesAutoresizingMaskIntoConstraints = false
        drawColorSlider.orientation = .horizontal
        drawColorSlider.previewEnabled = true
        drawColorSlider.setWidthConstraint(screenWidth * 0.45)
        drawColorSlider.setHeightConstraint(screenHeight * 0.03)
        drawColorSlider.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
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
        view.addSubview(undoButton)
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

