import Foundation
import CoreLocation

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=28d10f0a28913659c319f5898d2b5fb9&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let cityURL = "\(weatherURL)&q=\(cityName)"
        performRequest(with: cityURL)
    }
    
    func fetchWeather(latitude lat: CLLocationDegrees, longitute lon: CLLocationDegrees) {
        let cityURL = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: cityURL)
    }
    
    func performRequest(with urlString: String) {
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return //exit the function
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let tempearture = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: tempearture)
            
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
            
    }
    
}
