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
    lazy var textView: ResizableView = {
        let rv = ResizableView(frame: CGRect(x:0,
                                             y: 0,
                                             width: 0.5 * screenWidth,
                                             height: 0.2 * screenHeight))
        rv.autocorrectionType = .no
        rv.center = CGPoint(x: view.center.x - 0.05 * screenWidth,
                            y: view.center.y - 0.2 * screenHeight)
        rv.isUserInteractionEnabled = false
        rv.textAlignment = .center
        return rv
    }()
    
    
    // Observable to publish and communicate with ViewController
    public lazy var exitSubject = PublishSubject<UIImage?>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurBackground()
        
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
                        
                        // Show all other UIButtons (excluding drawing components)
                        self.textButton.alpha = 1
                        self.photoPickerButton.alpha = 1
                        self.finishButton.alpha = 1
                        self.cancelButton.alpha = 1
                    })
                    
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        // Move drawButton to offset at -0.2*screenWidth w.r.t current trailing anchor
                        self.drawButton.transform = CGAffineTransform(translationX: screenWidth * 0.12, y: 0)
                    })
                    
                    UIView.animate(withDuration: 0.15, animations: {
                        // Hide all other UIButtons (excluding drawing components)
                        self.textButton.alpha = 0
                        self.photoPickerButton.alpha = 0
                        self.finishButton.alpha = 0
                        self.cancelButton.alpha = 0
                    })
                }
                
                // Toggle isSelected state
                self.drawButton.isSelected = !self.drawButton.isSelected
                
                if self.photoPickerButton.isSelected {
                    self.photoPickerButton.sendActions(for: .touchUpInside)
                }
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
    
    func blurBackground() {
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView =  UIVisualEffectView(effect: blurEffect)
        
        // add vibrancy
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        effectView.contentView.addSubview(vibrancyView)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.setTopConstraint(equalTo: effectView.topAnchor, offset: 0)
        vibrancyView.setBottomConstraint(equalTo: effectView.bottomAnchor, offset: 0)
        vibrancyView.setLeadingConstraint(equalTo: effectView.leadingAnchor, offset: 0)
        vibrancyView.setTrailingConstraint(equalTo: effectView.trailingAnchor, offset: 0)
        
        // add blur
        view.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.setTopConstraint(equalTo: view.topAnchor, offset: 0)
        effectView.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        effectView.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        effectView.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
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
        slateView.setCenterYConstraint(equalTo: view.centerYAnchor, offset: -0.04 * screenHeight)
        slateView.layer.cornerRadius = 10
        slateView.clipsToBounds = true
    }
    
    
    /**
     Setup drawButton positioned under slateView to right.
     */
    private func setupDrawButton() {
        view.addSubview(drawButton)
        drawButton.setImage(UIImage(named: "ic_create_white"), for: .normal)
        setButtonBasics(drawButton)
        drawButton.setLeadingConstraint(equalTo: slateView.centerXAnchor, offset: 0.15 * screenWidth)
        drawButton.setCenterYConstraint(equalTo: slateView.topAnchor, offset: -0.055 * screenHeight)
    }
    
    /**
     Setup textButton positioned under slateView to left.
     */
    private func setupTextButton() {
        view.addSubview(textButton)
        textButton.setImage(UIImage(named: "ic_title_white"), for: .normal)
        setButtonBasics(textButton)
        textButton.setCenterYConstraint(equalTo: slateView.topAnchor, offset: -0.055 * screenHeight)
        textButton.setTrailingConstraint(equalTo: slateView.centerXAnchor, offset: -0.15 * screenWidth)
    }
    
    /**
     Setup photoLibraryButton positioned under slateView.
     */
    private func setupPhotoPickerButton() {
        view.addSubview(photoPickerButton)
        photoPickerButton.setImage(UIImage(named: "ic_photo_white"), for: .normal)
        setButtonBasics(photoPickerButton)
        photoPickerButton.setCenterXConstraint(equalTo: slateView.centerXAnchor, offset: 0)
        photoPickerButton.setCenterYConstraint(equalTo: slateView.topAnchor, offset: -0.055 * screenHeight)
    }
    
    /**
     Setup finishButton positioned above slateView to right.
     */
    private func setupFinishButton() {
        view.addSubview(finishButton)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.setImage(UIImage(named: "baseline_done_white_24pt"), for: .normal)
        finishButton.setBackgroundImage(.from(color: UIColor.flatSkyBlue.withAlphaComponent(0.2)), for: .normal)
        finishButton.setBackgroundImage(.from(color: UIColor.flatSkyBlueDark.withAlphaComponent(0.2)), for: .selected)
        finishButton.setLeadingConstraint(equalTo: view.centerXAnchor, offset: 2)
        finishButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.065 * screenHeight)
        finishButton.setHeightConstraint(0.088 * screenHeight)
        finishButton.setWidthConstraint(0.465 * screenWidth)
        finishButton.tintColor = UIColor.flatWhite.withAlphaComponent(0.65)
        finishButton.layer.cornerRadius = 10
    }
    
    /**
     Setup cancelButton positioned above slateView to left.
     */
    private func setupCancelButton() {
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(named: "baseline_close_white_24pt"), for: .normal)
        cancelButton.setBackgroundImage(.from(color: UIColor.flatRed.withAlphaComponent(0.2)), for: .normal)
        cancelButton.setBackgroundImage(.from(color: UIColor.flatRedDark.withAlphaComponent(0.2)), for: .selected)
        cancelButton.setTrailingConstraint(equalTo: view.centerXAnchor, offset: -2)
        cancelButton.setTopConstraint(equalTo: slateView.bottomAnchor, offset: 0.065 * screenHeight)
        cancelButton.setHeightConstraint(0.088 * screenHeight)
        cancelButton.setWidthConstraint(0.465 * screenWidth)
        cancelButton.tintColor = UIColor.flatWhite.withAlphaComponent(0.65)
        cancelButton.layer.cornerRadius = 10
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
        let photoPickerView = PhotoLibraryView()
        
        view.addSubview(photoPickerView)
        photoPickerView.translatesAutoresizingMaskIntoConstraints = false
        photoPickerView.setBottomConstraint(equalTo: view.bottomAnchor, offset: 0)
        photoPickerView.setLeadingConstraint(equalTo: view.leadingAnchor, offset: 0)
        photoPickerView.setTrailingConstraint(equalTo: view.trailingAnchor, offset: 0)
        photoPickerView.setHeightConstraint(0.21 * screenHeight)
        
        let translation = CGAffineTransform(translationX: 0, y: screenHeight)
        photoPickerView.transform = translation
        
        /**
         Set slateView background image - React to photoPickerView imageSubject
         */
        photoPickerView.imageSubject
            .subscribe(onNext: { [slateView] (image) in
                slateView.image = image
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
                            let alertController = UIAlertController(title: "Photos Permission Required",
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
                if self?.photoPickerButton.isSelected == true {
                    UIView.animate(withDuration: 0.3, animations: {
                        photoPickerView.transform = translation
                    })
                     self?.photoPickerButton.isSelected = false
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        photoPickerView.transform = .identity
                    })
                     self?.photoPickerButton.isSelected = true
                }
            })
            .disposed(by: disposeBag)
    }
    
}

// MARK:- Text-specific Rx
extension CreationViewController {
    private func setupTextLayoutAndRx() {
        let textColorSlider = ColorSlider()


        slateView.addSubview(textView)
        textView.showHandles = false
        
        textView.rx.didBeginEditing
            .bind{
                UIView.animate(withDuration: 0.3, animations: {
                    // Move drawButton to offset at -0.2*screenWidth w.r.t current trailing anchor
                    self.textButton.transform = CGAffineTransform(translationX: screenWidth * -0.12, y: 0)
                    textColorSlider.alpha = 1
                    
                })
                
                UIView.animate(withDuration: 0.15, animations: {
                    // Hide all other UIButtons (excluding drawing components)
                    self.drawButton.alpha = 0
                    self.photoPickerButton.alpha = 0
                    self.finishButton.alpha = 0
                    self.cancelButton.alpha = 0
                    self.textView.showHandles = true
                })
                
                self.textButton.isSelected = true
            }.disposed(by: disposeBag)
  
        textView.rx.didEndEditing
            .bind{
                UIView.animate(withDuration: 0.25, animations: {
                    // Move drawButton to offset at -0.2*screenWidth w.r.t current trailing anchor
                    self.textButton.transform = .identity
                    textColorSlider.alpha = 0
                    self.finishButton.alpha = 1
                    self.cancelButton.alpha = 1
                    self.drawButton.alpha = 1
                    self.photoPickerButton.alpha = 1
                    self.textView.showHandles = false
                })
                self.textButton.isSelected = false
            }.disposed(by: disposeBag)
        

        // Setup textColorSlider
        view.addSubview(textColorSlider)
        textColorSlider.translatesAutoresizingMaskIntoConstraints = false
        textColorSlider.orientation = .horizontal
        textColorSlider.previewEnabled = true
        textColorSlider.setWidthConstraint(screenWidth * 0.45)
        textColorSlider.setHeightConstraint(screenHeight * 0.03)
        textColorSlider.setCenterXConstraint(equalTo: view.centerXAnchor, offset: 0)
        textColorSlider.setCenterYConstraint(equalTo: textButton.centerYAnchor, offset: 0)
        textColorSlider.alpha = 0
        
        textColorSlider.colorSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (color) in
                self.textView.textColor = color
            })
            .disposed(by: self.disposeBag)
        
        /**
         Show textView - React to textButton tap gesture
         */
        textButton.rx.tap
            .bind{
                self.textView.isUserInteractionEnabled = true
                
                if self.textButton.isSelected {
                    self.textView.endEditing(true)
                } else {
                    self.textView.becomeFirstResponder()
                }
                
                if self.photoPickerButton.isSelected {
                    self.photoPickerButton.sendActions(for: .touchUpInside)
                }
            }
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
        drawColorSlider.setCenterYConstraint(equalTo: drawButton.centerYAnchor, offset: 0)
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
        undoButton.setImage(UIImage(named: "baseline_undo_white_24pt"), for: .normal)
        undoButton.setCenterYConstraint(equalTo: drawButton.centerYAnchor, offset: 0)
        undoButton.setTrailingConstraint(equalTo: view.centerXAnchor, offset: screenWidth * -0.27)
        undoButton.tintColor = .white
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
            .subscribe(onNext: { [weak self] (_) in
                if self?.drawButton.isSelected == true {
                    // Hide drawing components
                    drawView.isActive = false
                    UIView.animate(withDuration: 0.15, animations: {
                        drawColorSlider.alpha = 0
                    })
                    undoButton.alpha = 0
                    
                    self?.slateView.sendSubview(toBack: drawView)
                    
                } else {
                    // Show drawing components
                    drawView.isActive = true
                    self?.slateView.bringSubview(toFront: drawView)
                    UIView.animate(withDuration: 0.15, animations: {
                        drawColorSlider.alpha = 1
                    })
                    undoButton.alpha = 1
                }
            })
            .disposed(by: disposeBag)
    }
}

