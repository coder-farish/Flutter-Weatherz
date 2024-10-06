class WeatherData {
  String cityName;
  String region;
  String country;
  num temperature;
  num feelsLike;
  num humidity;
  num windSpeed;
  String windDirection;
  String condition;
  bool isDay;

  WeatherData({
    required this.cityName,
    required this.region,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.condition,
    required this.isDay,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['location']['name'],
      region: json['location']['region'],
      country: json['location']['country'],
      temperature: json['current']['temp_c'],
      feelsLike: json['current']['feelslike_c'],
      humidity: json['current']['humidity'],
      windSpeed: json['current']['wind_kph'],
      windDirection: json['current']['wind_dir'],
      condition: json['current']['condition']['text'],
      isDay: json['current']['is_day'] == 1,
    );
  }
}
