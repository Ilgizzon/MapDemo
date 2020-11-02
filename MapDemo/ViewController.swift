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

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetView = MapBottomSheet(frame: view.bounds)
        view.addSubview(sheetView ?? UIView())
    }



    
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation){
        print("Annotation deselect: \(annotation)")
        sheetView?.hide()
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation){
        guard let mapAnnotation = annotation as? MapAnnotation, let id = mapAnnotation.id else {
            return
        }
        let car = viewModel?.getCurrentCar(id: id)
        sheetView?.setData(car: car ?? CarModel())
        setupDirections(car: car ?? CarModel())
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



    func setupDirections(car: CarModel) {


        let wp1 = Waypoint(coordinate: mapView.userLocation?.coordinate ?? CLLocationCoordinate2D(), name: "You")
        let wp2 = Waypoint(coordinate: CLLocationCoordinate2D(latitude: car.latitude, longitude: car.longitude), name: car.name)
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
                        if let annotations = self.mapView.annotations {
                            for annotation in annotations {
                                if ((annotation as? MGLPolyline) != nil) {
                                    self.mapView.removeAnnotation(annotation)
                                }
                            }
                        }

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
    func loadImage(data: Data) {
        let image = UIImage(data: data)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.sheetView?.updateImage(carImage: image)
        }
    }
    
    func loadCars(cars: [CarModel]) {
        DispatchQueue.main.async  { [weak self] in
            guard let self = self else {
                return
            }
            for car in cars {
                let annotation = MapAnnotation()
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: car.latitude, longitude: car.longitude)
                let image = car.color == "blue" ? UIImage(named: "blue")?.rotate(radians: Float(car.angle)) : UIImage(named: "black")?.rotate(radians: Float(car.angle))
                annotation.carImage = image
                annotation.id = "\(car.id)"
                self.mapView.addAnnotation(annotation)
            }
        }


    }
}
