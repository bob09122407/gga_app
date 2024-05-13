// _authenticate.dart
import 'package:flutter/material.dart';
import 'package:fh_mini_app/screens/authenticate/register.dart';
import 'package:fh_mini_app/screens/authenticate/sign_in.dart';
import 'package:fh_mini_app/screens/pod_screen.dart'; // Import the PodScreen widget
import 'package:fh_mini_app/services/auth.dart'; // Import your auth.dart file

import '../../ui/components/edit_esp32_url_dialog.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final AuthService _auth = AuthService();
  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    if (_auth.isUserLoggedIn) {
      // If the user is logged in, show the edit ESP32 URL dialog on a button press
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Show the Edit ESP32 URL dialog and navigate to PodScreen on URL save
              await showEditESP32URLDialog(context, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PodScreen(),
                  ),
                );
              });
            },
            child: Text('Edit ESP32 URL'),
          ),
        ),
      );
    } else {
      // If the user is not logged in, display the sign-in or registration screen
      if (showSignIn) {
        return SignIn(toggleView: toggleView);
      } else {
        return Register(toggleView: toggleView);
      }
    }
  }
}
