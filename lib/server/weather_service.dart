//การเรีนกใช้apiภายนอก
import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherReport {
  final double temperature;
  final double precipitation;
  final String city;

  const WeatherReport({
    required this.temperature,
    required this.precipitation,
    required this.city,
  });

  String get statusText {
    if (temperature >= 30) {
      return 'Hot and active';
    }
    if (temperature >= 25) {
      return 'Perfect for training';
    }
    return 'Cool and comfortable';
  }
}

class WeatherService {
  final String city;

  WeatherService({this.city = 'Bangkok'});

  Future<WeatherReport> fetchWeather() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=13.7563&longitude=100.5018&current=temperature_2m,precipitation&timezone=auto',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;

    return WeatherReport(
      temperature: (current['temperature_2m'] as num).toDouble(),
      precipitation: (current['precipitation'] as num).toDouble(),
      city: city,
    );
  }
}
