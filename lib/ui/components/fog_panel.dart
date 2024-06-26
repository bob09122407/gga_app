import 'dart:async';
import 'package:fh_mini_app/utils/widget_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../config/esp32_url_provider.dart';
DatabaseReference DBref = FirebaseDatabase.instance.ref();

class FogPanel extends StatefulWidget {
  const FogPanel({super.key});
  @override
  State<FogPanel> createState() => _FogPanelState();
}

class _FogPanelState extends State<FogPanel> {
  num _value = 0.0;
  bool fogState = false;

  void getFogSwitchStateFrmDB() async {

    final snapshot = await DBref.child('mini1/fogState/pin12').get();
    snapshot.exists
        ? fogState = snapshot.value as bool
        : print("No fog data on db");
    print("FogState is : $fogState");
    setState(() {
      print("I set state to update the widget");
    });
  }

  void getFogCycleStateFrmDB() async {
    final snapshot = await DBref.child('mini1/fogCycle/cycle').get();
    snapshot.exists
        ? _value = snapshot.value as num
        : print("No fog cycle data on db");
  }

  void updateFogSwitch(bool state) async {
    await DBref.child("mini1/fogState").update({
      "pin12": state,
    });
  }

  void updateFogCycle(int value) async {
    await DBref.child("mini1/fogCycle").update({
      "cycle": value,
    });
  }

  @override
  void initState() {
    super.initState();
    getFogSwitchStateFrmDB();
    getFogCycleStateFrmDB();
  }

  void fogFetch(int index) async {
    final ESP32UrlProvider esp32UrlProvider = Provider.of<ESP32UrlProvider>(context, listen: false);

    // Check if the URL is not null or empty before using it
    if (esp32UrlProvider.esp32Url != null && esp32UrlProvider.esp32Url.isNotEmpty) {
      String url = 'http://${esp32UrlProvider.esp32Url}/fog/${index}';
      debugPrint(url);
      try {
        Response fogResponse = await get(Uri.parse(url)).timeout(Duration(seconds: 10));
        print('Response from ESP : ${fogResponse.body}');
      } on TimeoutException catch (_) {
        print('Could not communicate');
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('Invalid ESP32 URL');
    }
  }



  List<bool> isSelected = [true, false, false, false, false, false, false];
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 25, top: 10, right: 25),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fog Cycles',
                    style: themeData.textTheme.headlineMedium,
                  ),
                  addVerticalSpace(30),
                  Text('Current fog rate : ${_value.toInt() * 5} %'),
                  Container(
                      child: Slider(
                        divisions: 10,
                        label: '${_value.toInt()} min',
                        activeColor: Theme.of(context).primaryColor,
                        thumbColor: Theme.of(context).colorScheme.secondary,
                        min: 0,
                        max: 10,
                        value: _value.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _value = value;
                            print(_value);
                          });
                        },
                        onChangeEnd: (value) {
                          setState(() {

                            fogFetch(value.toInt());
                          });
                        },
                      )),
                  SwitchListTile(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      title: Text(
                        'Make it rain',
                        style: themeData.textTheme.bodyMedium,
                      ),
                      value: fogState,
                      onChanged: (bool value) {
                        setState(() {

                          fogState ? fogFetch(96) : fogFetch(69);
                        });
                        setState(() {

                          fogState = value;
                        });
                      },
                      secondary: fogState
                          ? Image.asset(
                        'assets/images/rainyOn.png',
                        width: 30,
                      )
                          : Image.asset(
                        'assets/images/rainy.png',
                        width: 30,
                      )),
                  addVerticalSpace(20)
                ]),
          ),
        )
      ],
    );
  }
}














