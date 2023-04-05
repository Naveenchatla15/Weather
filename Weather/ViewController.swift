//
//  ViewController.swift
//  Weather
//
//  Created by Mac on 03/04/23.
//

import UIKit
import CoreLocation
import MapKit
import Kingfisher

@available(iOS 14.0, *)
class ViewController: UIViewController, CLLocationManagerDelegate {
    let weatherimagAPI = "https://openweathermap.org/img/wn/01d@2x.png"
    var locationManager = CLLocationManager()
    var cityName = ""
    var StateName = ""
    var countryName = ""
    var location =  CLLocation()
    @IBOutlet weak var cityNameTF : UITextField!
    @IBOutlet weak var weatherImgVW : UIImageView!
    @IBOutlet weak var tempLbl : UILabel!
    
    @IBOutlet weak var weatherFeelsLbl: UILabel!
    
    var firstTime = true
    
    @IBOutlet weak var visibilityLbl: UILabel!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var feelsLikeLbl: UILabel!
    @IBOutlet weak var humidyLbl: UILabel!
    var latitude:CLLocationDegrees = 0.0
    var longitude:CLLocationDegrees = 0.0
    
    @IBOutlet weak var cityMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print(Date.getCurrentDate(timeZone: .current))
        self.dateLbl.text = Date.getCurrentDate(timeZone: .current)
        firstTime = true
    }
    
    func weatherImfAPI(param: URL)
    {
        self.weatherImgVW.kf.setImage(with: param)
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedAlways , .authorizedWhenInUse:
            break
        case .notDetermined , .denied , .restricted:
            print("Not accecable")
            break
        default:
            break
        }
        
        switch manager.accuracyAuthorization {
        case .fullAccuracy:
            break
        case .reducedAccuracy:
            break
        default:
            break
        }
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            // The user denied authorization
            print("denied")
        } else if (status == CLAuthorizationStatus.authorizedAlways) {
            // The user accepted authorization
            print("authorizedAlways")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        let location1:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        print("latitude -> ", location.coordinate.latitude)
        print("longitude -> ", location.coordinate.longitude)
        print("longicentertude -> ", center)
        print("region -> ", region)
        
        cityMapView.setRegion(region, animated: true)
        let myAn1 = MyAnnotation(title: "", coordinate: location1, subtitle: "")
        cityMapView.addAnnotation(myAn1)
        if firstTime == true
        {
            getAddressFromLatLon(long: longitude, lat: latitude)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    ) {
        print(error.localizedDescription)
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        if cityNameTF.text != ""
        {
            getRequest(params: ["q": cityNameTF.text!, "appid" : access_Tocken])
        }
        else
        {
            showToast(message: "Please enter City")
        }
        
    }
    
    @IBAction func locationBtnAction(_ sender: Any) {
        
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    if let BUNDLE_IDENTIFIER = Bundle.main.bundleIdentifier,
                       let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(BUNDLE_IDENTIFIER)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
 
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    self.locationManager.startUpdatingLocation()
                    self.getAddressFromLatLon(long: self.longitude, lat: self.latitude)
                @unknown default:
                    break
                }
            } else {
                print("Location services are not enabled")
            }
        }
        
        
    }
    
    func getAddressFromLatLon(long : Double, lat: Double) {
        firstTime = false
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = long
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    { [self](placemarks, error) in
            if (error != nil)
            {
                print(error?.localizedDescription as Any)
            }
            if placemarks != nil
            {
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country ?? "")
                    print(pm.locality ?? "")
                    print(pm.subLocality ?? "")
                    print(pm.thoroughfare ?? "")
                    print(pm.postalCode ?? "")
                    print(pm.subThoroughfare ?? "")
                    print(pm.timeZone ?? "")
                    self.cityNameLbl.text = pm.locality!  + ", " + pm.isoCountryCode!
                    self.dateLbl.text = Date.getCurrentDate(timeZone: pm.timeZone!)
                    self.getRequest(params: ["q": pm.locality!, "appid" : access_Tocken])
                    if let first = pm.country!.components(separatedBy: " ").last {
                        print(first)
                    }
                }
            }
        })
    }
    
    //MARK:- API CALL
    func getRequest(params: [String:String]) {
        
        let urlComp = NSURLComponents(string: "https://api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}")!
        var items = [URLQueryItem]()
        
        for (key,value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }
        items = items.filter{!$0.name.isEmpty}
        if !items.isEmpty {
            urlComp.queryItems = items
        }
        var urlRequest = URLRequest(url: urlComp.url!)
        print(urlComp.url!)
        urlRequest.httpMethod = "GET"
        //        let config = URLSessionConfiguration.default
        //        let session = URLSession(configuration: config)
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            print("statusCode:\(statusCode)")
            if statusCode == 404 {
                print("failuer 1")
                //                self.showToast(message: "Invalid")
                return
            }
            else if ( error == nil && data != nil ){
                do {
                    self.locationManager.startUpdatingLocation()
                    
                    if let JSONString = String(data: data!, encoding: String.Encoding.utf8) {
                        print("json -> ", JSONString)
                        
                        let jsonData = JSONString.data(using: .utf8)!
                        let decoder = JSONDecoder()
                        let myStruct = try! decoder.decode(WeatherResponseModel.self, from: jsonData)
                        
                        print(myStruct.coord!.lat! as Any)
                        print(myStruct.coord!.lon! as Any)
                        print(myStruct.weather![0].main! as Any)
                        
                        let location2:CLLocationCoordinate2D = CLLocationCoordinate2DMake(myStruct.coord!.lat!, myStruct.coord!.lon!)
                        
                        let region2 = MKCoordinateRegion(center: location2, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                        self.cityMapView.setRegion(region2, animated: true)
                        let myAn2 = MyAnnotation(title: "", coordinate: location2, subtitle: "")
                        self.cityMapView.addAnnotation(myAn2)
                        
                        let countryCode = myStruct.sys?.country
                        DispatchQueue.main.async(execute: {
                            //                            self.dateLbl.text = self.getTimeWithLocale(with: myStruct.name!)
                            self.cityNameTF.text = ""
                            self.cityNameLbl.text = myStruct.name! + ", " + (countryCode ?? "")
                            self.feelsLikeLbl.text = myStruct.weather![0].main! + ", " + myStruct.weather![0].description!
                            self.humidyLbl.text = "Humidity " + String(describing: myStruct.main!.humidity!) + "%"
                            self.visibilityLbl.text = "Visibility " + String(describing: ((myStruct.visibility!) / 1000))  + "km"
                            
                            let icon = myStruct.weather![0].icon!
                            
                            let weatherimagAPI = URL(string: "https://openweathermap.org/img/wn/"  + "\(icon)" + "@2x.png")
                            print(weatherimagAPI as Any)
                            
                            self.weatherImfAPI(param: weatherimagAPI!)
                            
                            let tempeMax = (myStruct.main?.temp_max!)! - 273.15
                            let tempeMin = (myStruct.main?.temp_min!)! - 273.15
                            let feelsLike = (myStruct.main?.feels_like!)! - 273.15
                            
                            print(tempeMax)
                            print(tempeMin)
                            let temp = (myStruct.main?.temp!)! - 273.15
                            self.tempLbl.text = "\(Int(temp))"  + "°C"
                            self.weatherFeelsLbl.text = "feels Like " + "\(Int(feelsLike))"  + "°C"
                            
                            
                        })
                    }
                    
                } catch {
                    self.locationManager.startUpdatingLocation()
                }
            }
            else if error != nil
            {
                self.locationManager.startUpdatingLocation()
            }
        }).resume()
    }
    
    
    func getTimeWithLocale(with timeZone: String) -> String {
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateStyle = .none
        //        dateFormatter.timeStyle = .short
        //        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        //        dateFormatter.locale = .current
        //
        //        let time = dateFormatter.string(from: Date()).lowercased().replacingOccurrences(of: " ", with: "")
        //
        //        return time
        
        let currentDate = Date()
        let format = DateFormatter()
        format.timeZone = TimeZone(identifier: timeZone)
        format.dateFormat = "MMM d, h:mm a"
        let dateString = format.string(from: currentDate)
        
        return dateString
        
    }
}

