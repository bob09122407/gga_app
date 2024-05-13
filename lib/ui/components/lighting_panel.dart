// import 'package:fh_mini_app/ui/components/colors_and_effects.dart';
// import 'package:flutter/material.dart';
//
// import '../../utils/widget_functions.dart';
// import 'pod_view.dart';
// import 'header.dart';
// import 'spin_panel.dart';
//
// class LightingPanel extends StatefulWidget {
//   const LightingPanel({super.key});
//
//   @override
//   State<LightingPanel> createState() => _LightingPanelState();
// }
//
// class _LightingPanelState extends State<LightingPanel> {
//   Color color = Color.fromARGB(255, 255, 0, 200);
//   @override
//   Widget build(BuildContext context) {
//     final ThemeData themeData = Theme.of(context);
//     final Size size = MediaQuery.of(context).size;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//
//         Padding(
//           padding: const EdgeInsets.only(left: 25, top: 10),
//           child: Text(
//             'Color & Effects',
//             style: themeData.textTheme.headline4,
//           ),
//         ),
//         ColorsAndEffects(
//             hueRingStrokeWidth: 30,
//             pickerAreaBorderRadius: BorderRadius.circular(20),
//             colorPickerHeight: size.height * 0.15,
//             displayThumbColor: false,
//             enableAlpha: true,
//             pickerColor: color,
//             onColorChanged: (color) {
//               this.color = color;
//             })
//       ],
//     );
//   }
// }








import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fh_mini_app/ui/components/colors_and_effects.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../config/esp32_url_provider.dart';
import '../../utils/widget_functions.dart';
import 'pod_view.dart';
import 'header.dart';
import 'spin_panel.dart';

class LightingPanel extends StatefulWidget {
  const LightingPanel({super.key});

  @override
  State<LightingPanel> createState() => _LightingPanelState();
}

class _LightingPanelState extends State<LightingPanel> {
  final _auth = FirebaseAuth.instance;
  final _dbRef = FirebaseDatabase.instance.ref();

  Color color = Color.fromARGB(255, 255, 0, 200);
  bool growLightState = false; // Variable to store the state of the Grow Light

  // Get the user's unique identifier (Firebase UID).
  String get userId => _auth.currentUser?.uid ?? ''; // Return an empty string if currentUser is null

  // Define the path under which the user's data will be stored.
  String get userPath => 'users/$userId';
  void getGrowLightStateFrmDB() async {
    final snapshot = await _dbRef.child('$userPath/growLightState/pin17').get();
    snapshot.exists
        ? growLightState = snapshot.value as bool
        : print("No grow light data on db");
    print("Grow Light State is : $growLightState");
    setState(() {
      print("I set state to update the widget");
    });
  }

  void updateGrowLightState(bool state) async {
    await _dbRef.child('$userPath/growLightState').update({
      "pin17": state,
    });
  }

  @override
  void initState() {
    super.initState();
    getGrowLightStateFrmDB(); // Add this line to get the initial state of the Grow Light.
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.only(left: 25, top: 10),
          child: Text(
            'Color & Effects',
            style: themeData.textTheme.headline4,
          ),
        ),
        ColorsAndEffects(
            hueRingStrokeWidth: 27,
            pickerAreaBorderRadius: BorderRadius.circular(20),
            colorPickerHeight: size.height * 0.12,
            displayThumbColor: false,
            enableAlpha: true,
            pickerColor: color,
            onColorChanged: (color) {

              this.color = color;
            }),

  // Grow Light Control Section
  Padding(
  padding: const EdgeInsets.only(left: 25, top: 3, bottom: 15),
  child: Text(
  'Grow Light',
  style: themeData.textTheme.headlineMedium,
  ),
  ),
  Padding(
  padding: const EdgeInsets.only(left: 25, top: 0, bottom:10),
  child: Row(
  children: [
  Text('Grow Light', style: themeData.textTheme.titleLarge),
  Spacer(),
  Switch(
  value: growLightState,
  onChanged: (value) {
  setState(() {
  growLightState ? growLightFetch(30) : growLightFetch(31);
  });
  setState(() {
  growLightState = value;
  updateGrowLightState(value); // Update the Grow Light state in the database.
  });
  },
  ),
  ],
  ),
  ),
  // ... Same as previous code ...
  ],
  );
}

// ... Same as previous code ...
void growLightFetch(int value) async {

  final ESP32UrlProvider esp32UrlProvider = Provider.of<ESP32UrlProvider>(context, listen: false);
  // Define the URL and the value to send to the ESP32 for Grow Light control.
  String url = 'http://${esp32UrlProvider.esp32Url}/growlight/${value}';
  debugPrint(url);
  try {
    Response growLightResponse = await get(Uri.parse(url)).timeout(Duration(seconds: 10));
    print('Response from ESP : ${growLightResponse.body}');
  } on TimeoutException catch (_) {
    print('Could not communicate');
  }
}
}
