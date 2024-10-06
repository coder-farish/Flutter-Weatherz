import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_data.dart';

class WeatherService {
  final String baseUrl;
  final String apiKey;

  WeatherService(this.baseUrl, this.apiKey);

  Future<WeatherData?> fetchWeatherByCity(String cityName) async {
    final url = Uri.parse('$baseUrl?key=$apiKey&q=$cityName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }

  Future<WeatherData?> fetchWeatherByLocation(
      double latitude, double longitude) async {
    final url = Uri.parse('$baseUrl?key=$apiKey&q=$latitude,$longitude');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }
}
