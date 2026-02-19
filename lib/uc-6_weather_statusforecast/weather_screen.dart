import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  final apiKey = "YOUR_API_KEY";

  WeatherModel? weather;
  bool loading = false;

  final TextEditingController controller = TextEditingController();
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    getCurrentLocationWeather();
  }

  Future<void> fetchWeather(String cityName) async {
    if (cityName.isEmpty) return;

    setState(() => loading = true);

    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric"
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newWeather = WeatherModel.fromJson(data);

        setState(() {
          weather = newWeather;
          loading = false;
        });

        if (!history.contains(newWeather.city)) {
          history.insert(0, newWeather.city);
          if (history.length > 5) {
            history = history.take(5).toList();
          }
          await _saveHistory();
        }

      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> getCurrentLocationWeather() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    String cityName = placemarks.first.locality ?? "";
    fetchWeather(cityName);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', history);
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('history');
    if (saved != null) {
      setState(() => history = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B5BD5), Color(0xFF1E1E3F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: controller,
                  onSubmitted: fetchWeather,
                  decoration: InputDecoration(
                    hintText: "Search city",
                    filled: true,
                    fillColor: Colors.white12,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              if (history.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => fetchWeather(history[index]),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              history[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : weather == null
                    ? const Center(
                  child: Text(
                    "No data",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : _weatherCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weatherCard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weather!.city,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            Image.network(
                "https://openweathermap.org/img/wn/${weather!.icon}@4x.png"
            ),
            Text(
              "${weather!.temp.round()}°",
              style: const TextStyle(fontSize: 60, color: Colors.white),
            ),
            Text(
              weather!.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _infoRow("Humidity", "${weather!.humidity}%"),
            _infoRow("Wind", "${weather!.wind} m/s"),
            _infoRow("Feels Like", "${weather!.feelsLike.round()}°"),
            _infoRow("Pressure", "${weather!.pressure} hPa"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}