//
//  ImageGalleryController.swift
//  pup
//
//  Created by Miguel Tamayo on 3/19/21.
//

import UIKit
import RealmSwift
import PureLayout
import Alamofire
import Gallery

class ImageGalleryController: UIViewController {
    
    let standardOffset: CGFloat = 8
    
    let scrollView: UIScrollView = UIScrollView(forAutoLayout: ())
    let scrollContentView: UIView = UIView(forAutoLayout: ())
    
    var gallery = GalleryController()
    let selectedImageLabel: UILabel = UILabel(forAutoLayout: ())
    let unselectedImage: UIImage = UIImage(systemName: "nosign")!
    let selectedImageView: AdjustableImageView = AdjustableImageView(image: UIImage(systemName: "nosign")!)
    let changeImageButton: UIButton = UIButton(forAutoLayout: ())
    let uploadButton: UIButton = UIButton(forAutoLayout: ())
    
    let activityIndicatorView: UIView = UIView(forAutoLayout: ())
    let spinnerView: UIActivityIndicatorView = UIActivityIndicatorView(forAutoLayout: ())
    let activityLabel: UILabel = UILabel(forAutoLayout: ())
    
    var heightConstraint: NSLayoutConstraint!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        present(gallery, animated: true, completion: nil)
        activityIndicatorView.alpha = 0
        activityLabel.alpha = 1
        updateSelectedImageView(image: unselectedImage)
    }
    
    // MARK: - View Setups
    
    func setupViews() {
        setupGallery()
        setupScrollView()
        setupSelectedImageView()
        setupButtons()
        setupActivityIndicatorView()
        scrollContentView.autoPinEdge(.bottom, to: .bottom, of: uploadButton)
    }
    
    func setupGallery() {
        gallery = GalleryController()
        gallery.delegate = self
        gallery.cart.add(delegate: self)
        Config.tabsToShow = [.imageTab]
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.backgroundColor = .white
        scrollView.bounces = false
        scrollView.autoPinEdgesToSuperviewSafeArea(with: .init(top: standardOffset, left: standardOffset, bottom: 0, right: standardOffset))
        
        scrollView.addSubview(scrollContentView)
        scrollContentView.backgroundColor = .white
        scrollContentView.autoPinEdgesToSuperviewEdges(with: .init(top: standardOffset, left: standardOffset, bottom: standardOffset, right: standardOffset))
        scrollContentView.autoMatch(.width, to: .width, of: scrollView, withOffset: (-2 * standardOffset))
    }
    
    func setupSelectedImageView() {
        selectedImageLabel.text = "Selected Image"
        selectedImageLabel.contentMode = .center
        selectedImageLabel.textAlignment = .center
        selectedImageLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        selectedImageLabel.numberOfLines = 0
        scrollContentView.addSubview(selectedImageLabel)
        selectedImageLabel.autoPinEdgesToSuperviewEdges(with: .init(top: standardOffset, left: standardOffset, bottom: 0, right: standardOffset), excludingEdge: .bottom)
        
        selectedImageView.layer.borderWidth = 1
        selectedImageView.layer.borderColor = UIColor.black.cgColor
        selectedImageView.layer.cornerRadius = standardOffset
        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.backgroundColor = .white
        selectedImageView.tintColor = .red
        selectedImageView.clipsToBounds = true
        scrollContentView.addSubview(selectedImageView)
        selectedImageView.autoPinEdge(.top, to: .bottom, of: selectedImageLabel, withOffset: standardOffset)
        selectedImageView.autoPinEdge(.left, to: .left, of: scrollContentView, withOffset: standardOffset)
        selectedImageView.autoPinEdge(.right, to: .right, of: scrollContentView, withOffset: -standardOffset)
    }
    
    func setupButtons() {
        changeImageButton.layer.borderColor = UIColor.black.cgColor
        changeImageButton.layer.borderWidth = 1
        changeImageButton.layer.cornerRadius = standardOffset
        changeImageButton.setTitleColor(.black, for: .normal)
        changeImageButton.setTitle("Change Image", for: .normal)
        changeImageButton.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        changeImageButton.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpInside)
        changeImageButton.addTarget(self, action: #selector(handleChangeImageButtonPressed), for: .touchUpInside)
        changeImageButton.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpOutside)
        changeImageButton.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        
        scrollContentView.addSubview(changeImageButton)
        changeImageButton.autoPinEdge(.top, to: .bottom, of: selectedImageView, withOffset: standardOffset)
        changeImageButton.autoPinEdge(.left, to: .left, of: scrollContentView, withOffset: standardOffset)
        changeImageButton.autoPinEdge(.right, to: .right, of: scrollContentView, withOffset: -standardOffset)
        changeImageButton.autoSetDimension(.height, toSize: 44)
        
        
        uploadButton.layer.borderColor = UIColor.black.cgColor
        uploadButton.layer.borderWidth = 1
        uploadButton.layer.cornerRadius = standardOffset
        uploadButton.setTitleColor(.black, for: .normal)
        uploadButton.setTitle("Upload Image", for: .normal)
        uploadButton.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        uploadButton.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(handleUploadButtonPressed), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpOutside)
        uploadButton.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        
        scrollContentView.addSubview(uploadButton)
        uploadButton.autoPinEdge(.top, to: .bottom, of: changeImageButton, withOffset: standardOffset)
        uploadButton.autoPinEdge(.left, to: .left, of: scrollContentView, withOffset: standardOffset)
        uploadButton.autoPinEdge(.right, to: .right, of: scrollContentView, withOffset: -standardOffset)
        uploadButton.autoSetDimension(.height, toSize: 44)
    }
    
    func setupActivityIndicatorView() {
        view.addSubview(activityIndicatorView)
        view.bringSubviewToFront(activityIndicatorView)
        
        activityIndicatorView.autoPinEdgesToSuperviewSafeArea()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        activityIndicatorView.addSubview(blurredEffectView)
        blurredEffectView.autoPinEdgesToSuperviewEdges()
        
        let activityView: UIView = UIView(forAutoLayout: ())
        activityView.backgroundColor = .white
        activityView.layer.cornerRadius = standardOffset
        activityIndicatorView.addSubview(activityView)
        activityView.autoAlignAxis(toSuperviewAxis: .vertical)
        activityView.autoAlignAxis(toSuperviewAxis: .horizontal)
        activityView.autoMatch(.width, to: .width, of: activityIndicatorView, withOffset: -2 * standardOffset)
        activityView.autoSetDimension(.height, toSize: 200)
        
        activityView.addSubview(spinnerView)
        spinnerView.autoSetDimensions(to: .init(width: 64, height: 64))
        spinnerView.style = .large
        spinnerView.autoCenterInSuperview()
        spinnerView.color = .black
        spinnerView.startAnimating()
        
        activityLabel.text = "Uploading..."
        activityLabel.contentMode = .center
        activityLabel.textAlignment = .center
        activityView.addSubview(activityLabel)
        activityLabel.autoPinEdge(.top, to: .bottom, of: spinnerView)
        activityLabel.autoPinEdge(.left, to: .left, of: activityView)
        activityLabel.autoPinEdge(.right, to: .right, of: activityView)
        
        activityIndicatorView.alpha = 0
    }
    
    // MARK: - Controller Logic Functions
    
    func updateSelectedImageView(image: UIImage) {
        selectedImageView.image = image
    }
    
    func dismissAndResetGallery() {
        gallery.dismiss(animated: true, completion: nil)
        setupGallery()
    }
    
}

// MARK: - Gallery Cart Delegate Functions
extension ImageGalleryController: CartDelegate {
    func cart(_ cart: Cart, didRemove image: Image) {}
    func cartDidReload(_ cart: Cart) {}
    func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
        print("added image")
        
        image.resolve { (img) in
            if let img = img {
                self.updateSelectedImageView(image: img)
            }
        }
        
        dismissAndResetGallery()
    }
}

// MARK: - Gallery Delegate Functions
extension ImageGalleryController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {}
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {}
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        print("selected \(images.count) images!")
        
        if let selectedImageReference = images.first {
            selectedImageReference.resolve { (image) in
                if let image = image {
                    self.updateSelectedImageView(image: image)
                }
            }
        }
        
        dismissAndResetGallery()
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        dismissAndResetGallery()
    }
}


// MARK: - Controller Buttons Functions
extension ImageGalleryController {
    
    @objc func buttonTouchedDown(_ sender: UIButton) {
        sender.backgroundColor = .lightGray
    }
    
    @objc func buttonTouchedUp(_ sender: UIButton) {
        sender.backgroundColor = .white
    }
    
    @objc func handleChangeImageButtonPressed() {
        present(gallery, animated: true, completion: nil)
    }
    
    @objc func handleUploadButtonPressed() {
        
        if let selectedImage = selectedImageView.image, selectedImage != unselectedImage {
            
            self.activityLabel.text = "Loading..."
            UIView.animate(withDuration: 1.5, delay: 0, options: [UIView.AnimationOptions.autoreverse, UIView.AnimationOptions.repeat], animations: {
                self.activityLabel.alpha = 0
            }, completion: nil)
            
            UIView.animate(withDuration: 0.5) {
                self.activityIndicatorView.alpha = 1
            }
            
            API.predict(image: selectedImage) { (completed, json) in
                
                if let json = json, completed {
                    //write response to database
                    let prediction = Prediction()
                    prediction.date = Date().description
                    prediction.prediction = json["prediction"].stringValue
                    
                    try! realmDB.write {
                        realmDB.add(prediction)
                    }
                    
                    self.activityLabel.text = "Upload complete!"
                } else {
                    self.activityLabel.text = "Upload Failed!"
                }
                
                
                self.activityLabel.alpha = 1
                UIView.animate(withDuration: 0.5, delay: 1) {
                    self.activityIndicatorView.alpha = 0
                }
            }
        }
        
    }
}

class AdjustableImageView: UIImageView {

    /// `NSLayoutConstraint` constraining `heightAnchor` relative to the `widthAnchor`
    /// with the same `multiplier` as the inverse of the `image` aspect ratio, where aspect
    /// ratio is defined width/height.
    private var aspectRatioConstraint: NSLayoutConstraint?

    /// Override `image` setting constraint if necessary on set
    override var image: UIImage? {
        didSet {
            updateAspectRatioConstraint()
        }
    }

    // MARK: - Init

    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    /// Shared initializer code
    private func setup() {
        // Set default `contentMode`
        contentMode = .scaleAspectFill

        // Update constraints
        updateAspectRatioConstraint()
    }

    // MARK: - Resize

    /// De-active `aspectRatioConstraint` and re-active if conditions are met
    private func updateAspectRatioConstraint() {
        // De-active old constraint
        aspectRatioConstraint?.isActive = false

        // Check that we have an image
        guard let image = image else { return }

        // `image` dimensions
        let imageWidth = image.size.width
        let imageHeight = image.size.height

        // `image` aspectRatio
        guard imageWidth > 0 else { return }
        let aspectRatio = imageHeight / imageWidth
        guard aspectRatio > 0 else { return }

        // Create a new constraint
        aspectRatioConstraint = heightAnchor.constraint(
            equalTo: widthAnchor,
            multiplier: aspectRatio
        )

        // Activate new constraint
        aspectRatioConstraint?.isActive = true
    }
}
