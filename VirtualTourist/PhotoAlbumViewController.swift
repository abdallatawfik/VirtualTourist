//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/4/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    // MARK: - Properties
    
    var selectedPin = Pin()
    fileprivate var selectedPinPhotos:[Photo] {
        get {
            return Model.sharedInstance().getPhotosFor(pin: selectedPin)
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    
    // MARK: - IBActions
    
    @IBAction func newCollectionRequested(_ sender: UIBarButtonItem) {
        // Delete the old collection and request new one then return
        Model.sharedInstance().getNewCollectionFor(pin: selectedPin) { (newCollectionFound) in
            DispatchQueue.main.async {
                self.updateUI(photosCollectionFound: newCollectionFound)
            }
        }
        
        collectionView.reloadData()
        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = false
    }
    
    
    // MARK: - UI Configurations and Updates
    
    func configureUI() {
        navigationController?.navigationBar.topItem?.title = PhotoAlbumViewController.BackButtonTitle
        configureMapView()
        
        Model.sharedInstance().checkPhotosFor(pin: selectedPin) { (photosCollectionFound) in
            DispatchQueue.main.async {
                self.updateUI(photosCollectionFound: photosCollectionFound)
            }
        }
    }
    
    func configureMapView() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    func updateUI(photosCollectionFound:Bool) {
        noImagesLabel.isHidden = photosCollectionFound
        newCollectionButton.isEnabled = true
        
        if photosCollectionFound {
            collectionView.reloadData()
        }
    }
}

// MARK: - PhotoAlbumViewController (CollectionView) delegate, datasource and flowlayout

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPinPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewConstants.CellReuseIdentifier, for: indexPath) as! AlbumCollectionViewCell
        
        // Setup cell with a placeholder image and a loading indicator
        cell.setupCell(withImage: UIImage(named: CollectionViewConstants.CellPlaceholderImageName)!, loading: true)
        
        // Get model of the cell
        let photo = selectedPinPhotos[indexPath.row]
        
        Model.sharedInstance().getImagefor(photo: photo) { (image) in
            DispatchQueue.main.async {
                if cell == collectionView.cellForItem(at: indexPath) {
                    // Setup cell with its image and hide the loading indicator
                    cell.setupCell(withImage: image, loading: false)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell {
            
            cell.setSelected(selected: true)
            
            let alert = UIAlertController(title: "", message: Alerts.RemoveImageMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: Alerts.ConfirmRemovingImage, style: .destructive) { (action) in
                Model.sharedInstance().deletePhoto(photo: self.selectedPinPhotos[indexPath.row])
                cell.setSelected(selected: false)
                self.collectionView.deleteItems(at: [indexPath])
            })
            alert.addAction(UIAlertAction(title: Alerts.CancelRemovingImage, style: .cancel) { (action) in
                cell.setSelected(selected: false)
            })
            present(alert, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Cell spacing must match storyboard values
        let cellSpacing = CGFloat(5.0)
        let numberOfCellsPerRow = CGFloat(3)
        let cellWidth = (view.bounds.width - cellSpacing * 2) / numberOfCellsPerRow
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
