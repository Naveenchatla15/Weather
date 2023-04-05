//
//  Utility.swift
//  Weather
//
//  Created by Mac on 03/04/23.
//

import Foundation
import UIKit
import CoreLocation



let access_Tocken = "16b067cc090aab63eed51f9dd10c7df0"
let weatherimagAPI = "https://openweathermap.org/img/wn/01d@2x.png"

extension UIViewController
{
    func SimpleAlert(Alertmessage:String)
    {
        let Alert = UIAlertController.init(title: "Alert", message: Alertmessage , preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "OK", style: .default)
        Alert.addAction(ok)
        self.present(Alert, animated: true, completion: nil)
    }
    
    func showToast(message:String)
    {
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.height - 125, width: self.view.frame.width - 50, height: 35))
        toastLabel.backgroundColor = UIColor(named: "app_color")
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 13.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 18
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseOut, animations:
                {
            toastLabel.alpha = 0.0
                    
            }) { (isCompleted) in
                toastLabel.removeFromSuperview()
            }
        }
    }
}



extension Date {

    static func getCurrentDate(timeZone : TimeZone) -> String {

//        let dateFormatter = DateFormatter()

//        dateFormatter.dateFormat = "MMM d, h:mm a"
     
    // As per requirement
//     Date().string(format: "EEEE, MMM d, yyyy") // Saturday, Oct 21, 2017
//     Date().string(format: "MM/dd/yyyy")        // 10/21/2017
//     Date().string(format: "MM-dd-yyyy HH:mm")  // 10-21-2017 03:31
//
//        return dateFormatter.string(from: Date())
     
        let currentDate = Date()
        let format = DateFormatter()
        format.timeZone = timeZone
        format.dateFormat = "MMM d, h:mm a"
        let dateString = format.string(from: currentDate)
//     
     return dateString

    }  
    
}


@available(iOS 14.0, *)
extension CLLocationManager {
    
    func checkLocationPermission() {
        
        if self.authorizationStatus != .authorizedWhenInUse && self.authorizationStatus != .authorizedAlways && self.authorizationStatus != .denied{
            
            self.requestAlwaysAuthorization()
            
        }
        else
        {
            print("kjhjkhkjhkj")
            self.requestAlwaysAuthorization()
        }
        
    }
    
}
