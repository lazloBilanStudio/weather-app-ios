import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
}

struct WeatherManager {
    let serverUrl: String = "https://api.openweathermap.org/data/2.5/weather?appid=YOUR_API_KEY&units=metric"
    let apiKey: String = ""
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(city: String?, longitude: CLLocationDegrees?, latitude: CLLocationDegrees?) {
        var url: String = ""
        
        if let cityName = city {
            url = "\(serverUrl)&q=\(cityName)"
        }
        
        if let longitudeInput = longitude {
            url = "\(serverUrl)&lon=\(longitudeInput)"
        }
        
        if let latitudeInput = latitude {
            url = "\(serverUrl)&lat=\(latitudeInput)"
        }
        
        performRequest(urlStr: url)
    }
    
    func performRequest(urlStr: String) {
        if let url = URL(string: urlStr) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, urlRes, error in
                if let err = error {
                    print(err)
                }
                
                if let res = data {
                    if let dataVC = self.parseData(data: res) {
                        self.delegate?.didUpdateWeather(self, weather: dataVC)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseData(data: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(DataJSON.self, from: data)
            let id = response.weather[0].id
            let name = response.name
            let temp = response.main.temp
            
            return WeatherModel(conditionId: id, cityName: name, temperature: temp)
        } catch {
            print(error)
            
            return nil
        }
    }
}
