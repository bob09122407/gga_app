
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:fh_mini_app/ui/components/NotiClass.dart';
  class SpinPanel extends StatefulWidget {
    const SpinPanel({Key? key});

    @override
    State<SpinPanel> createState() => _SpinPanelState();
  }

  class _SpinPanelState extends State<SpinPanel> {
    NotificationServices notificationServices = NotificationServices();
    int tdsValue = 0;

    @override
    void initState() {
      super.initState();
      fetchTDSValueFromESP32();
    }

    Future<void> fetchTDSValueFromESP32() async {
      try {
        final response = await http.get(Uri.parse('http://192.168.4.1/tds')).timeout(Duration(seconds: 3));
            if (response.statusCode == 200) {
          // Parse the TDS value from the response
          tdsValue = int.tryParse(response.body) ?? 0;

          // Check if the TDS value is greater than 500 and send a notification if true
          if (tdsValue > 500) {
            notificationServices.sendNotification(
              title: 'Warning TDS',
              body: 'Please change your water. TDS is too high.',
            );
          }
        } else {
      if (15000 > 500) {
      notificationServices.sendNotification(
      title: 'Warning TDS',
      body: 'Please change your water. TDS is too high.',
      );
      }
      debugPrint('Failed to fetch TDS value. Status code: ${response.statusCode}');
      }
      } catch (e) {
      if (15000 > 500) {
      notificationServices.sendNotification(
      title: 'Warning TDS',
      body: 'Please change your water. TDS is too high.',
      );
      }
      debugPrint('Error while fetching TDS value: $e');
      }
    }

    @override

    Widget build(BuildContext context) {
      return Scaffold(

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  fetchTDSValueFromESP32();
                  // You can use the fetched TDS value here if needed
                  debugPrint('TDS Value: $tdsValue');
                },
                child: Text("Check TDS Value"),
              ),
              SizedBox(height: 20), // Add some spacing
              Text(
                'TDS Value: $tdsValue',
                style: TextStyle(fontSize: 20), // Adjust the font size as needed
              ),
            ],
          ),
        ),
      );
    }

  }
