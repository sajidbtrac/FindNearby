//
//  ViewController.swift
//  FindNearby
//
//  Created by Sajid Shanta on 28/5/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    let queryTypes = ["hospital", "police", "atm"]
    var queryType: String = "hospital"
    let maxDistance: Double = 2000
    
    let locationManager = CLLocationManager()
    var lat: Double = 0.00
    var long: Double = 0.00
    
    let myAPIKey = ApiDetails().apiKey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typePicker.dataSource = self
        typePicker.delegate = self
        
        searchApiPlaceFromGoogle()
        
    }
    
    @IBOutlet var typePicker: UIPickerView!
    @IBOutlet weak var mainMapView: MKMapView!
    
    func searchApiPlaceFromGoogle() {
        // reset map
        let allAnnotations = self.mainMapView.annotations
        self.mainMapView.removeAnnotations(allAnnotations)
        
        // get permissions of location services
        locationManager.requestWhenInUseAuthorization()
        
        // get current location
        var currentLocation: CLLocation!
        currentLocation = locationManager.location
        
        // set map region around users current location
        mainMapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: maxDistance, longitudinalMeters: maxDistance), animated: true)
        mainMapView.tintColor = .blue
        
        self.lat = currentLocation.coordinate.latitude
        self.long = currentLocation.coordinate.longitude
        
        // print location on console
//        print(self.lat)
//        print(self.long)
        
        // api test
        //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=23.791083194820935,90.40347483722643&radius=1500&type=police&key=AIzaSyCXHLW1c8bOzeVR3PtURKV-OLOO796lpTo
        
        let stringGoogleApi = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.lat),\(self.long)&radius=1500&type=\(self.queryType)&type=\(self.queryType)&key=\(self.myAPIKey)"
        let url = NSURL(string: stringGoogleApi)
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: { (data, response, error) -> Void in
            if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                if let placeArray = jsonObject.value(forKey: "results") as? NSArray {
                    for place in placeArray {
                        if let placeDict = place as? NSDictionary {
                            if let name = placeDict.value(forKey: "name"),
                               let geometry = placeDict.value(forKey: "geometry"),
                               let loc = (geometry as AnyObject).value(forKey: "location"),
                               let lat = (loc as AnyObject).value(forKey: "lat"),
                               let lng = (loc as AnyObject).value(forKey: "lng") {
                                
                                //self.nameArray.append(name as! String)
                                let annotation = MKPointAnnotation()
                                annotation.title = name as? String ?? ""
                                annotation.coordinate = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lng as! CLLocationDegrees)
                                
                                // add the location annotation to map
                                self.mainMapView.addAnnotation(annotation)
                            }
                        }
                    }
                }
            }
        }).resume()
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return queryTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(queryTypes[row])
        self.queryType = self.queryTypes[row]
        searchApiPlaceFromGoogle()
    }
}

extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return queryTypes[row]
    }
}
