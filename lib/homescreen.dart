import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart' as k;
import 'location_service.dart';
import 'weather_service.dart';
import 'weather_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService(k.domain, k.apiKey);
  final LocationService _locationService = LocationService();
  WeatherData? _weatherData;
  bool _isLoading = false;
  bool _isLoaded = false;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  Future<void> _getCurrentLocationWeather() async {
    setState(() {
      _isLoading = true;
    });

    Position? position = await _locationService.getCurrentLocation();
    if (position != null) {
      _weatherData = await _weatherService.fetchWeatherByLocation(
          position.latitude, position.longitude);
    }

    setState(() {
      _isLoading = false;
      _isLoaded = _weatherData != null;
    });
  }

  Future<void> _getCityWeather() async {
    setState(() {
      _isLoading = true;
    });

    _weatherData =
        await _weatherService.fetchWeatherByCity(_cityController.text);
    setState(() {
      _isLoading = false;
      _isLoaded = _weatherData != null;
    });
  }

  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _getCurrentLocationWeather();
                  },
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text('Current Location Weather'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Search Weather:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Enter City Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.blueAccent),
                      onPressed: () {
                        Navigator.pop(context);
                        _getCityWeather();
                        _cityController.clear();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _weatherData?.isDay == true
                        ? [const Color(0xff89CFF0), const Color(0xff2196F3)]
                        : [Colors.grey, Colors.black],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weatherData?.cityName ?? '',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_weatherData?.region}, ${_weatherData?.country}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_weatherData?.temperature.toInt() ?? '--'}°',
                          style: const TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          _weatherData?.isDay == true
                              ? Icons.wb_sunny
                              : Icons.nights_stay,
                          color: _weatherData?.isDay == true
                              ? Colors.orange
                              : Colors.blueGrey,
                          size: 120,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Weather Details
                    _buildWeatherDetails(),
                    const SizedBox(height: 100),
                    _buildPoweredByLink(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30,
              right: 20,
              child: FloatingActionButton(
                onPressed: _showLocationModal, // Show the location modal
                backgroundColor: Colors.white.withOpacity(0.7),
                mini: true,
                child: const Icon(Icons.menu, color: Colors.black87),
                tooltip: 'Location Options',
              ),
            ),
            // Loading Indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    if (!_isLoaded) return Container();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherRow(Icons.device_thermostat_outlined,
                'Feels like: ${_weatherData!.feelsLike}°C', Colors.blue),
            const SizedBox(height: 10),
            _buildWeatherRow(Icons.water_drop,
                'Humidity: ${_weatherData!.humidity}%', Colors.blueAccent),
            const SizedBox(height: 10),
            _buildWeatherRow(Icons.cloud,
                'Condition: ${_weatherData!.condition}', Colors.grey),
            const SizedBox(height: 10),
            _buildWeatherRow(
                Icons.wind_power,
                'Wind Speed: ${_weatherData!.windSpeed} kph',
                Colors.greenAccent),
            const SizedBox(height: 10),
            _buildWeatherRow(
                Icons.navigation_outlined,
                'Wind Direction: ${_weatherData!.windDirection}',
                Colors.yellow),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPoweredByLink() {
    return GestureDetector(
      onTap: () {
        launchUrl(Uri.parse('https://www.weatherapi.com'));
      },
      child: const Text(
        'Powered By WeatherAPI',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
