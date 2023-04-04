//
//  f.swift
//  Weather
//
//  Created by Mac on 03/04/23.
//

import Foundation
import UIKit
import MBProgressHUD

var appDelegate = AppDelegate()

let content_type = "application/json; charset=utf-8"
var serviceController = ServiceController()

class ServiceController: NSObject {
    
    func getRequest(strURL:String,success:@escaping(_ _result:AnyObject)->Void,failure:@escaping(_ error:String) -> Void) {
        let fileUrl = NSURL(string: strURL)
        
        let request = NSMutableURLRequest(url: fileUrl! as URL)
        
        request.addValue(content_type, forHTTPHeaderField: "Content-Type")
        
        request.addValue(content_type, forHTTPHeaderField: "Accept")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with:request as URLRequest){(data,response,error) in
            
            DispatchQueue.main.async(){
                print(response as Any)
                if response != nil {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("statusCode:\(statusCode)")
                    if statusCode == 401 {
                        print("failuer 1")
                        failure("unAuthorized")
                    }
                    if statusCode == 500 {
                        print("failuer 1")
                        failure("unAuthorized")
                    }
                    if statusCode == 404 {
                        print("failuer 1")
                        
                        failure("Enter Valid Credentials")
                    }
                    else if error != nil
                    {
                        print("failuer 1")
                    }
                    else
                    {
                        print(statusCode)
                        do{
                            print("success 1")
                            let parsedData = try JSONSerialization.jsonObject(with:data!,options:.mutableContainers) as![String:Any]
                            //                            print(parsedData)
                            success(parsedData as AnyObject)
                        }
                        
                        catch{
                            print("error=\(error)")
                            return
                        }
                    }
                }
                else{
                    print(error?.localizedDescription as Any)
                }
            }
        }
        task.resume()
    }
    
    
    
    func showLoadingHUD(to_view: UIView) {
        MBProgressHUD.showAdded(to: to_view, animated: true)
    }
    
    func hideLoadingHUD(for_view: UIView) {
        MBProgressHUD.hide(for: for_view, animated: true)
    }
    
    
    
}
