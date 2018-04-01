//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/4/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController {

    // MARK: - Properties
    
    // Used to hold a reference to the annotation that is being added
    var addingAnnotation: MKPointAnnotation? = nil
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - IBActions
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        let touchPoint = sender.location(in: mapView)
        
        switch sender.state {
        case .began:
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            mapView.addAnnotation(annotation)
            addingAnnotation = annotation
        case .changed:
            addingAnnotation?.coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        case .ended:
            if let addingAnnotation = addingAnnotation {
                Model.sharedInstance().addPinFor(latitude: addingAnnotation.coordinate.latitude, longitude: addingAnnotation.coordinate.longitude)
                self.addingAnnotation = nil
            }
        case .cancelled, .failed:
            if let addingAnnotation = addingAnnotation {
                mapView.removeAnnotation(addingAnnotation)
                self.addingAnnotation = nil
            }
        default:
            break
        }
    }
    
    // MARK: - UI Configurations
    
    func configureUI() {
        loadRegion()
        loadAndAddAnnotations()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.ToPhotoAlbumViewController {
            if let dvc = segue.destination as? PhotoAlbumViewController, let annotationView = sender as? MKAnnotationView {
                mapView.deselectAnnotation(annotationView.annotation, animated: false)
                
                dvc.selectedPin = Model.sharedInstance().getPinFor(latitude: (annotationView.annotation?.coordinate.latitude)!, longitude: (annotationView.annotation?.coordinate.longitude)!)!
            }
        }
    }
}

// MARK: - TravelLocationsMapViewController (MapView) extension and delegate -

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    // MARK: - Region Management
    
    func loadRegion() {
        if let regionDictionary =  UserDefaults.standard.value(forKey: RegionKeys.Region) as? [String:Double] {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionDictionary[RegionKeys.CenterLatitude]!, longitude: regionDictionary[RegionKeys.CenterLongitude]!), span: MKCoordinateSpan(latitudeDelta: regionDictionary[RegionKeys.SpanLatitudeDelta]!, longitudeDelta: regionDictionary[RegionKeys.SpanLongitudeDelta]!))
            
            mapView.setRegion(region, animated: false)
        }
    }
    
    func saveRegion() {
        let region = mapView.region
        
        let regionDictionary = [RegionKeys.CenterLatitude:Double(region.center.latitude), RegionKeys.CenterLongitude:Double(region.center.longitude), RegionKeys.SpanLatitudeDelta:Double(region.span.latitudeDelta), RegionKeys.SpanLongitudeDelta:Double(region.span.longitudeDelta)]
        
        UserDefaults.standard.set(regionDictionary, forKey: RegionKeys.Region)
    }
    
    // MARK: - Annotations Management
    
    func loadAndAddAnnotations() {
        let savedPins = Model.sharedInstance().getSavedPins()
        
        if let savedPins = savedPins {
            var annotations = [MKPointAnnotation]()
            
            for pin in savedPins {
                let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotations.append(annotation)
            }
            
            mapView.addAnnotations(annotations)
        }
    }
    
    // MARK: - MapView Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifiers.AnnotationView) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ReuseIdentifiers.AnnotationView)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveRegion()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: SegueIdentifiers.ToPhotoAlbumViewController, sender: view)
    }
}

