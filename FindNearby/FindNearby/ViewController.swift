//
//  ViewController.swift
//  FindNearby
//
//  Created by Sajid Shanta on 28/5/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    var nameArray = [String]()
    let locationManager = CLLocationManager()
    
    var lat: Double = 0.00
    var long: Double = 0.00
    
    let myAPIKey = "AIzaSyCXHLW1c8bOzeVR3PtURKV-OLOO796lpTo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchApiPlaceFromGoogle()
    }
    
    @IBOutlet var txtView: UITextView!
    @IBAction func btnHospital(_ sender: Any) {
        self.printPlaceNames()
    }
    
    func searchApiPlaceFromGoogle() {
        // get permissions of location services
        locationManager.requestWhenInUseAuthorization()
        
        // get current location
        var currentLocation: CLLocation!
        currentLocation = locationManager.location

        self.lat = currentLocation.coordinate.latitude
        self.long = currentLocation.coordinate.longitude
        // print location on console
        print(self.lat)
        print(self.long)
        
        // using Google API url: Please register in Google nearby place API key to get the API key
        let stringGoogleApi = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(self.lat),\(self.long)&radius=1500&type=clinic&type=clinic&key=\(myAPIKey)"
        let url = NSURL(string: stringGoogleApi)
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: { (data, response, error) -> Void in
            if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                if let placeArray = jsonObject.value(forKey: "results") as? NSArray {
                    print("placeArray \(placeArray)")
                    for place in placeArray {
                        print("place \(place)")
                        if let placeDict = place as? NSDictionary {
                            print("placeDict \(placeDict)")
                            if let name = placeDict.value(forKey: "name") {
                                print("name \(name)")
                                self.nameArray.append(name as! String)
                            }
                        }
                    }
                }
            }
        }).resume()
    }
    func printPlaceNames() {
        print("kk")
        print(nameArray.joined(separator: "\n \n") + "nn")
        self.txtView.text = nameArray.joined(separator: "\n \n")
    }
}

