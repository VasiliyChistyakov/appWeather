//
//  ViewController.swift
//  Sunny
//
//  Created by Ivan Akulov on 24/02/2020.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    
    var networkWeatherManager = NetworkWeatherManager()
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    @IBAction func searchPressed(_ sender: UIButton) {
        self.presentSearchAlertController(withTitle: "Enter city name", message: nil, style: .alert) { [ unowned self] city in
            self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: city))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkWeatherManager.onCompletion = { [ weak self] currentWeather in
            
            guard let self = self else { return }
            self.updateIntrefaceWith(wather: currentWeather)
        }
        if CLLocationManager.locationServicesEnabled(){
            locationManager.requestLocation()
        }
    }
    
    
    func updateIntrefaceWith(wather: CurrentWeather){
        DispatchQueue.main.async {
            self.cityLabel.text = wather.cityName
            self.temperatureLabel.text = wather.temperatureString
            self.feelsLikeTemperatureLabel.text = wather.feelsLikeTemperatureString
            self.weatherIconImageView.image = UIImage(systemName: wather.systemIconNameString)
        }
       
    }
}

// MARK: - CLLocationManagerDelegate


extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
         
        networkWeatherManager.fetchCurrentWeather(forRequestType:.coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
