//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "8042b54a8b4c72a1af451a749d95f00b"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weathreDataModel = WeatherDataModel()
  

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, parameters: parameters).responseJSON {
            response in
            
            if response.result.isSuccess {
               
                let weatherJSON: JSON = JSON(response.result.value!)
             
                self.parseWeatherJson(json: weatherJSON)
                
                
                
            }
            else {
                
                print ("Error \(response.error.debugDescription)")
                self.cityLabel.text = "Connection issue"
                
            }
            
            
            
            
            
        }
  
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func parseWeatherJson(json: JSON) {
        
        if let temperature = json["main"]["temp"].double {
            
            weathreDataModel.temperature = Int(temperature - 273.15)
            weathreDataModel.condition = json["weather"][0]["id"].intValue
            weathreDataModel.cityName = json["name"].stringValue
            weathreDataModel.weathreIconName = weathreDataModel.updateWeatherIcon(condition: weathreDataModel.condition)
  
            updateUIWithData()
            
        }
        else {
            
            print("Error")
            cityLabel.text = "Error fetching data"
            
            
        }
        
        
        
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithData() {
        cityLabel.text = weathreDataModel.cityName
        temperatureLabel.text = "\(weathreDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weathreDataModel.weathreIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        
        let lon = String(location.coordinate.longitude)
        let lat = String(location.coordinate.latitude)
        
        let params : [String: String] = ["lat" : lat, "lon" : lon, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Unknown city"
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredNewCityName(city: String) {
        
        let params: [String : String] = ["q": city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
     
    }
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


