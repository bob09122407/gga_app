import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../config/esp32_url_provider.dart';

void main() {
  runApp(Nutrients());
}

class Nutrients extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NutrientControlPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NutrientControlPage extends StatefulWidget {
  @override
  _NutrientControlPageState createState() => _NutrientControlPageState();
}

class _NutrientControlPageState extends State<NutrientControlPage> {
  Set<String> activeNutrients = Set<String>();

  void _toggleNutrient(String nutrient) {
    setState(() {
      if (activeNutrients.contains(nutrient)) {
        activeNutrients.remove(nutrient);
      } else {
        activeNutrients.add(nutrient);
      }
    });
    sendDataToServer(nutrient, activeNutrients.contains(nutrient));
  }

  Future<void> sendDataToServer(String nutrient, bool state) async {
    final ESP32UrlProvider esp32UrlProvider =
    Provider.of<ESP32UrlProvider>(context, listen: false);

    final serverIP = '${esp32UrlProvider.esp32Url}';

    final Map<String, String> nutrientUrls = {
      'nitrogen': state ? '/non' : '/noff',
      'phosphorus': state ? '/pon' : '/poff',
      'potassium': state ? '/kon' : '/koff',
    };

    final nutrientUrl = 'http://$serverIP${nutrientUrls[nutrient]}';

    try {
      await http.get(Uri.parse(nutrientUrl)).timeout(Duration(seconds: 3));
      print('$nutrient ${state ? "ON" : "OFF"} sent successfully');
    } on TimeoutException catch (_) {
      print('Connection Timeout');
    } catch (error) {
      print('Failed to send data: $error');
    }
  }

  Widget _buildNutrientControl(
      String label, String nutrient, ThemeData themeData) {
    bool state = activeNutrients.contains(nutrient);
    return Column(
      children: <Widget>[
        Text(
          label,
          style: themeData.textTheme.bodySmall?.copyWith(fontSize: 20.0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Switch(
              value: state,
              onChanged: (value) {
                _toggleNutrient(nutrient);
                sendDataToServer(nutrient, value);
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Nutrition System',
                  style: themeData.textTheme.bodyMedium?.copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildNutrientControl('Nitrogen', 'nitrogen', themeData),
            _buildNutrientControl('Phosphorus', 'phosphorus', themeData),
            _buildNutrientControl('Potassium', 'potassium', themeData),
          ],
        ),
      ),
    );
  }
}
