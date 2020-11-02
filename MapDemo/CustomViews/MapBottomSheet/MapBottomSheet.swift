//
//  MapBottomSheet.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 28.10.2020.
//

import UIKit

class MapBottomSheet: UIView {

    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var fuelPercentLabel: UILabel!
    @IBOutlet weak var plateNumberLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var containerView: UIView!
    private var progressGradient: ProgressView?
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let gradient = [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor,#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor]
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configUI()
    }
    
    private func configUI() {
        let bundle = Bundle.init(for: MapBottomSheet.self)
        if let viewsToAdd = bundle.loadNibNamed("MapBottomSheet", owner: self, options: nil), let contentView = viewsToAdd.first as? UIView {
            addSubview(contentView)
            contentView.frame = self.bounds
            self.frame = CGRect(x: self.bounds.minX, y: self.bounds.maxY, width: self.bounds.width, height: self.bounds.height)
            contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.layer.cornerRadius = bounds.width/15
            self.clipsToBounds = true
            progressGradient = ProgressView(frame: progressView.bounds, onView: progressView, colors: gradient, lineWidth: 10, startValue: 0)
            
            image.clipsToBounds = true
            image.layer.cornerRadius = image.bounds.width/2
            image.layer.borderWidth = 10
            image.layer.borderColor = #colorLiteral(red: 0.8764342944, green: 0.8764342944, blue: 0.8764342944, alpha: 1).cgColor
            
            containerView.clipsToBounds = false
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.8
            containerView.layer.shadowPath = UIBezierPath(roundedRect: image.bounds, cornerRadius: image.bounds.width/2).cgPath
            containerView.layer.shadowOffset = .zero
            containerView.layer.shadowRadius = 10
            containerView.layer.shouldRasterize = true
            containerView.layer.rasterizationScale = UIScreen.main.scale
            
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
        }
        
    }
    
    func setData(car: CarModel){
        carNameLabel.text = car.name
        plateNumberLabel.text = car.plateNumber
        fuelPercentLabel.text = "\(car.fuelPercentage)%"
        show(CGFloat(car.fuelPercentage))
    }

    private func show(_ strokePersent: CGFloat = 0){
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {return}
            self.frame = CGRect(x: self.bounds.minX, y: self.bounds.maxY/3, width: self.bounds.width, height: self.bounds.height)
        }  completion: { [weak self] _ in
            guard let self = self else {return}
            self.loadingIndicator.startAnimating()
            self.progressGradient?.animation(from: 0, to: strokePersent/100, duration: 0.6)
        }


        
    }
    
    func hide(){
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else {return}
            self.frame = CGRect(x: self.bounds.minX, y: self.bounds.maxY, width: self.bounds.width, height: self.bounds.height)
        } completion: { [weak self] _ in
            guard let self = self else {return}
            self.loadingIndicator.stopAnimating()
            self.progressGradient?.clearAnimation()
            self.clearData()
        }
    }
    func updateImage(carImage: UIImage?){
        setImage(carImage: carImage)
        
    }
    private func setImage(carImage: UIImage?){
        if !loadingIndicator.isAnimating {
            return
        }
        loadingIndicator.stopAnimating()
        image.contentMode = .scaleAspectFill
        image.image = carImage
    }
    
    private func clearData(){
        image.image = UIImage(named: "emptyCar")
        image.contentMode = .scaleAspectFit
        carNameLabel.text = ""
        plateNumberLabel.text = ""
        fuelPercentLabel.text = ""
        
    }
    
}
