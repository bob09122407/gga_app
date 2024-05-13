
import 'package:fh_mini_app/config/custom_theme.dart';
import 'package:fh_mini_app/models/ui_mode.dart';
import 'package:fh_mini_app/screens/landing_page.dart';
import 'package:fh_mini_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/esp32_url_provider.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lock the orientation to portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UIModeModel()..initialize()),
        ChangeNotifierProvider(create: (_) => ESP32UrlProvider(initialUrl: 'http://123.4.4.4')),
      ],
      child: Builder(
        builder: (context) {
          final uiTheme = Provider.of<UIModeModel>(context);
          // final appConfig = Provider.of<AppConfigProvider>(context);

          debugPrint("Your mode value is : ${uiTheme.getModeValue}");

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Green Global Aggrovation',
            theme: uiTheme.getModeValue
                ? CustomTheme(uiTheme.accent).darkTheme
                : CustomTheme.lightTheme,
            home: FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Error occurred with Firebase app');
                  return Text('Error with Firebase');
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return StreamProvider<User?>.value(
                    value: AuthService().userStream,
                    initialData: null,
                    catchError: null,
                    child: LandingPage(),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
