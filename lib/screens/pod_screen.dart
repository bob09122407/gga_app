// pod_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rive/rive.dart' hide LinearGradient;

import '../config/esp32_url_provider.dart';
import '../services/auth.dart';
import '../ui/components/edit_esp32_url_dialog.dart';
import '../screens/help_guide.dart';
import '../screens/home_screen.dart';
import '../utils/widget_functions.dart';

class PodScreen extends StatefulWidget {
  const PodScreen({Key? key}) : super(key: key);

  @override
  State<PodScreen> createState() => _PodScreenState();
}

class _PodScreenState extends State<PodScreen> {
  bool loading = false;
  bool isConnectionSuccessful = false;

  late Image image1;
  late Image image2;
  late Image image3;
  late Image image4;
  late Image image5;
  late Image image6;
  late Image image7;



  // Modified fetchData method to get esp32Url from ESP32UrlProvider
  void fetchData(BuildContext context) async {
    final ESP32UrlProvider esp32UrlProvider = Provider.of<ESP32UrlProvider>(context);
    String esp32Url = esp32UrlProvider.esp32Url;
    setState(() {
      loading = true;
    });

    try {
      // print('ESP32 URL--: $esp32Url');
      // Simulate fetching the URL (replace this with your logic)
      await Future.delayed(Duration(seconds: 10));

       // Get the URL from the provider

      final response = await get(Uri.parse('http://${esp32UrlProvider.esp32Url}/hello')).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {

        setState(() {
          isConnectionSuccessful = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint("Connection timeout");
      // print('ESP32 URL: $esp32Url');
      setState(() {
        connectionTimeout(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print('assets are being cached');
    image1 = Image.asset('assets/images/1.png');
    image2 = Image.asset('assets/images/1.png');
    image3 = Image.asset('assets/images/2.gif');
    image4 = Image.asset('assets/images/rainyOn.png');
    image5 = Image.asset('assets/images/0_dark.gif');
    image6 = Image.asset('assets/images/1_dark.png');
    image7 = Image.asset('assets/images/2_dark.gif');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchData(context);
    precacheImage(image1.image, context);
    precacheImage(image2.image, context);
    precacheImage(image3.image, context);
    precacheImage(image4.image, context);
    precacheImage(image5.image, context);
    precacheImage(image6.image, context);
    precacheImage(image7.image, context);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.fromARGB(255, 216, 61, 230), Color.fromARGB(255, 28, 63, 231)],
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: size.height,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      children: [
                        addVerticalSpace(50),
                        Text(
                          'EliteEco',
                          style: themeData.textTheme.headline2,
                        ),
                        Text(
                          'Welcome to the future of food',
                          style: themeData.textTheme.headline5,
                        ),
                        addVerticalSpace(30),
                        PodStatus(
                          themeData: themeData,
                          hasLoaded: loading,
                        ),
                        addVerticalSpace(10),
                      ],
                    ),
                  ),
                  loading
                      ? Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      child: RiveAnimation.asset(
                        'assets/images/zack_animation.riv',
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                      : SizedBox.shrink()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> connectionTimeout(BuildContext context) {
    final TapGestureRecognizer gestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).push(_createRoute(HelpGuide()));
      };
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: RichText(
              text: TextSpan(children: [
                const TextSpan(
                    style: TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    text:
                    'Connection could not be established to Pod. For further information on troubleshooting practices refer to our '),
                TextSpan(
                    text: 'help guide',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600),
                    recognizer: gestureRecognizer),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).push(_createRoute(HomePage()));
                },
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 202, 208),
                ),
                child: const Text(
                  'Enter anyway',
                ),
              ),
            ],
          );
        });
  }
}

class PodStatus extends StatelessWidget {
  const PodStatus({Key? key, required this.themeData, required this.hasLoaded}) : super(key: key);

  final ThemeData themeData;
  final bool hasLoaded;

  @override
  Widget build(BuildContext context) {
    return hasLoaded
        ? Text(
      'Connecting to your pod...',
      style: themeData.textTheme.bodySmall,
    )
        : const Text(
      "Could not find Pod",
      style: TextStyle(fontSize: 12, color: Colors.red),
    );
  }
}

Route _createRoute(var screenName) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screenName,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      });
}
