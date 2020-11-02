//
//  ViewController.swift
//  MapDemo
//
//  Created by Ilgiz Fazlyev on 23.10.2020.
//

import UIKit
import CoreLocation
import MapboxDirections
import Mapbox
import RealmSwift

class ViewController: UIViewController, MGLMapViewDelegate {
    var mapView: MGLMapView!
    var segmentedControl: UISegmentedControl!
    static let initialMapCenter = CLLocationCoordinate2D(latitude: 55.8667, longitude: 37.8342)
    static let initialZoom: Double = 15
    private var sheetView: MapBottomSheet?
    var viewModel: ViewModelProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel(with: self)
        let styleURL = URL(string: "mapbox://styles/belkacar/ckdj89h8c0rk61jlgb850lece")
        mapView = MGLMapView(frame: view.bounds, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(ViewController.initialMapCenter, animated: false)
        mapView.setZoomLevel(ViewController.initialZoom, animated: false)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        view.addSubview(mapView)
        viewModel?.getCars()
        setUpSegmentedControls()

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetView = MapBottomSheet(frame: view.bounds)
        view.addSubview(sheetView ?? UIView())
    }

    func setUpSegmentedControls() {
        let items = ["Move", "Directions"]
        segmentedControl = UISegmentedControl(items: items)
        let frame = UIScreen.main.bounds
        segmentedControl.frame = CGRect(x: frame.minX + 10, y: frame.minY + 50, width: frame.width - 20, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .white
        segmentedControl.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        self.view.addSubview(segmentedControl)
    }

    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation){
        print("Annotation deselect: \(annotation)")
        sheetView?.hide()
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation){
        print("Annotation select: \(annotation)")
        let car = CarModel()
        car.fuelPercentage = 78
        car.name = "Mercedes-Benz CLA 2019"
        car.plateNumber = "x478xx777"
        sheetView?.setData(car: car)
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        guard let mapAnnotation = annotation as? MapAnnotation else {
            return nil
        }
        
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: mapAnnotation.id ?? "" )

        if annotationImage == nil {
            guard let strongImage = mapAnnotation.carImage else {
                return nil
            }
            var image = strongImage

            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))

            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: mapAnnotation.id ?? "")
        }
        return annotationImage
    }

    @objc func segmentedValueChanged(_ sender: UISegmentedControl) {
        resetDrawingView()

        switch sender.selectedSegmentIndex {
        
        case 1:
            setupDirections()
        default:
            return
        }
    }

    func resetDrawingView() {
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        mapView.isUserInteractionEnabled = true
    }

    func setupDirections() {
        // Add a point annotation


        // Add a point annotation
        let annotation2 = MapAnnotation()
        annotation2.coordinate = CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047)
        annotation2.carImage = UIImage(named: "black")?.rotate(radians: 45)
        annotation2.id = "33"
        mapView.addAnnotation(annotation2)

        let wp1 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox")
        let wp2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House")
        let options = RouteOptions(waypoints: [wp1, wp2])
        options.includesSteps = true
        options.routeShapeResolution = .full
        options.attributeOptions = [.congestionLevel, .maximumSpeedLimit]

        Directions.shared.calculate(options) { (session, result) in
            switch result {
            case let .failure(error):
                print("Error calculating directions: \(error)")
            case let .success(response):
                if let route = response.routes?.first, let leg = route.legs.first {
                    print("Route via \(leg):")

                    let distanceFormatter = LengthFormatter()
                    let formattedDistance = distanceFormatter.string(fromMeters: route.distance)

                    let travelTimeFormatter = DateComponentsFormatter()
                    travelTimeFormatter.unitsStyle = .short
                    let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)

                    print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")

                    for step in leg.steps {
                        let direction = step.maneuverDirection?.rawValue ?? "none"
                        print("\(step.instructions) [\(step.maneuverType) \(direction)]")
                        if step.distance > 0 {
                            let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
                            print("— \(step.transportType) for \(formattedDistance) —")
                        }
                    }

                    if var routeCoordinates = route.shape?.coordinates, routeCoordinates.count > 0 {
                        // Convert the route’s coordinates into a polyline.
                        let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))

                        // Add the polyline to the map.
                        self.mapView.addAnnotation(routeLine)

                        // Fit the viewport to the polyline.
                        let camera = self.mapView.cameraThatFitsShape(routeLine, direction: 0, edgePadding: .zero)
                        self.mapView.setCamera(camera, animated: true)
                    }
                }
            }
        }
    }

}

extension ViewController: ViewControllerDelegate {
    func loadCars(cars: [CarModel]) {
        for car in cars {
            let annotation = MapAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: car.latitude, longitude: car.longitude)
            let image = car.color == "blue" ? UIImage(named: "blue")?.rotate(radians: Float(car.angle)) : UIImage(named: "black")?.rotate(radians: Float(car.angle))
            annotation.carImage = image
            annotation.id = "\(car.id)"
            mapView.addAnnotation(annotation)
        }

    }
}
