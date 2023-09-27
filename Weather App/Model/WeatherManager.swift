import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weather: WeatherModel)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=1af2879314d2d22bb6ffae6cb272bb6c&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func getWeather(cityName: String) {
        let urlString = weatherURL + "&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func getWeatherWithCoords(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = weatherURL + "&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        // 1. Create a URL
        if let url = URL(string: urlString) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(weather)
                    }
                    
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let cityName = decodedData.name
            
            let weather = WeatherModel(conditionID: id, cityName: cityName, temperature: temp)
            return weather
            
            
        } catch {
            print(error)
            return nil
        }
        
    }
    
    
}
