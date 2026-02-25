class WeatherModel {
  final String city;
  final double temp;
  final String description;
  final int humidity;
  final double wind;
  final double feelsLike;
  final int pressure;
  final String icon;

  WeatherModel({
    required this.city,
    required this.temp,
    required this.description,
    required this.humidity,
    required this.wind,
    required this.feelsLike,
    required this.pressure,
    required this.icon,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'],
      temp: json['main']['temp'],
      description: json['weather'][0]['main'],
      humidity: json['main']['humidity'],
      wind: json['wind']['speed'],
      feelsLike: json['main']['feels_like'],
      pressure: json['main']['pressure'],
      icon: json['weather'][0]['icon'],
    );
  }
}