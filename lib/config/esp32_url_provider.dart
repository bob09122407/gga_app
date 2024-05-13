// esp32_url_provider.dart
import 'package:flutter/material.dart';

class ESP32UrlProvider extends ChangeNotifier {
  late String _esp32Url;

  ESP32UrlProvider({required String initialUrl}) {
    _esp32Url = initialUrl;
  }

  String get esp32Url => _esp32Url;

  set esp32Url(String newUrl) {
    _esp32Url = newUrl;
    print('New ESP32 URL: $newUrl'); // Add this line to print the new URL
    notifyListeners();
  }
}

