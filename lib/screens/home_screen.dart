import 'dart:async';
import 'dart:convert';
import 'package:fh_mini_app/models/ui_mode.dart';
import 'package:fh_mini_app/screens/landing_page.dart';
import 'package:fh_mini_app/screens/machine.dart';
import 'package:fh_mini_app/screens/product_screen.dart';
import 'package:fh_mini_app/services/auth.dart';
import 'package:fh_mini_app/ui/components/colors_and_effects.dart';
import 'package:fh_mini_app/ui/components/fog_panel.dart';
import 'package:fh_mini_app/ui/components/produce_panel.dart';
import 'package:fh_mini_app/ui/components/spin_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../config/esp32_url_provider.dart';
import '../models/spin_change.dart';
import '../ui/components/lighting_panel.dart';
import '../ui/components/pod_view.dart';
import '../utils/widget_functions.dart';

class HomePage extends StatefulWidget {
  // const HomePage({super.key});
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _controlMode = false;

  //set data for fogPanel in firebase rtdb
  Future<void> setData() async {

    final ESP32UrlProvider esp32UrlProvider =
    Provider.of<ESP32UrlProvider>(context, listen: false);

    final serverIP = 'http://${esp32UrlProvider.esp32Url}/mode';

    // Fetch control mode from the server
    // String url = 'http://192.168.4.1/mode'; // Endpoint for fetching control mode
    try {
      Response response = await get(Uri.parse(serverIP)).timeout(Duration(seconds: 3));

      if (response.statusCode == 200) {
        final String responseBody = response.body.toLowerCase();

        if (responseBody == 'true') {
          // Mini is in auto mode
          setState(() {
            _controlMode = true;
          });
        } else if (responseBody == 'false') {
          // Mini is in manual mode
          setState(() {
            _controlMode = false;
          });
        } else {
          print('Invalid response from server');
        }
      } else {
        print('Failed to fetch control mode from server');
      }
    } on TimeoutException catch (_) {
      print('Could not communicate with the server');
    } catch (e) {
      print('Error: $e');
    }
  }

  void controlMode(bool mode) async {

    final ESP32UrlProvider esp32UrlProvider =
    Provider.of<ESP32UrlProvider>(context, listen: false);

    final serverIP = 'http://${esp32UrlProvider.esp32Url}/mode/$mode';
    // Endpoint for setting control mode on the server
    // String url = 'http://192.168.4.1/mode/$mode';
    debugPrint(serverIP);
    try {
      Response fogResponse =
      await get(Uri.parse(serverIP)).timeout(Duration(seconds: 3));
      print('Response from ESP : ${fogResponse.body}');
      if (fogResponse.statusCode == 200) {
        // Update the _controlMode variable based on the server response
        setState(() {
          _controlMode = mode;
        });
      } else {
        print('Failed to update control mode');
      }
    } on TimeoutException catch (_) {
      print('Could not communicate');
    }
  }
  //get and set bottom app bar index.

  Future<void> setBAB(int tappedIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('BNB', tappedIndex);
  }

  Future<void> getBAB() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentIndex = prefs.getInt('BNB') ?? 0;
    //load control mode with _currentIndex picked from SharedPreferences
    loadScreen();
    //set toggle button based on _currentIndex
    //setstate not required as this _currentIndex is to be known only once
    //in the app life
    for (int i = 0; i < buttonsSelected.length; i++) {
      buttonsSelected[i] = i == _currentIndex;
    }
  }

  @override
  void initState() {
    super.initState();
    getBAB();
    setData();
    //triggerManualMode();
  }

  String _pageTitle = "home";
  Widget _currentWidget = FogPanel();

  void loadScreen() {
    switch (_currentIndex) {
      case 0:
        return setState(() {
          _pageTitle = 'FogPanel';
          _currentWidget = FogPanel();
        });
      case 1:
        return setState(() {
          _pageTitle = 'LightingDash';
          _currentWidget = LightingPanel();
        });
      case 2:
        return setState(() {
          _pageTitle = 'SpinPanel';
          _currentWidget =SpinPanel();
        });
      case 3:
        return setState(() {
          _pageTitle = 'ProducePanel';
          _currentWidget = Nutrients();
        });
    }
  }

  var buttonsSelected = [false, true, false, false];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final uiTheme = Provider.of<UIModeModel>(context, listen: false);
    final AuthService _auth = AuthService();
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            //actions: [Icon(Icons.settings)],
            elevation: 0.0,
          ),
          drawer: Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 216, 61, 230),
                            Color.fromARGB(255, 28, 63, 231)
                          ]),
                    ),
                    // currentAccountPicture: CircleAvatar(
                    //   foregroundImage: NetworkImage(user.photoURL!),
                    // ),
                    accountName: Text( "Dummy"
                    ),
          accountEmail :Text( user?.email ?? 'Unknown User')),
                // ListTile(
                //   title: const Text('Profile'),
                //   leading: Icon(Icons.account_circle),
                //   onTap: null,
                // ),
                // ListTile(
                //   title: const Text('Insights'),
                //   leading: Icon(Icons.insights),
                //   onTap: null,
                // ),

                ListTile(
                    title: const Text('Dark Mode'),
                    leading: Icon(Icons.nightlight_outlined),
                    trailing: Switch(
                      value: uiTheme.getModeValue,
                      onChanged: (value) {
                        uiTheme.setMode(value);
                      },
                      activeColor: Theme.of(context).colorScheme.secondary,
                    )),

                //Accent tile only available in dark mode.
                uiTheme.getModeValue
                    ? ListTile(
                        title: const Text('Accent'),
                        leading: Icon(
                          Icons.palette,
                        ),
                        onTap: () {
                          //switch to lighting panel
                          setState(() {
                            _currentIndex = 1;
                            debugPrint('Index 1 activated');
                            setBAB(1);
                            loadScreen();
                            for (int i = 0; i < buttonsSelected.length; i++) {
                              buttonsSelected[i] = i == 1;
                            }
                          });
                          Navigator.pop(context);
                          accentInstruction(context);
                        },
                      )
                    : SizedBox.shrink(),
                ListTile(
                  title: const Text('Research & Dev'),
                  leading: Icon(Icons.biotech),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Machine()));
                    print("R&D");
                  },
                ),

                ListTile(
                  title: const Text('Recipe'),
                  leading: Icon(Icons.restaurant_menu),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ProductScreen()));
                    // Add code to handle Recipe option here
                  },
                ),
                ListTile(
                  title: const Text('View on Map'),
                  leading: Icon(Icons.location_on_outlined),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Log out'),
                  leading: Icon(Icons.logout),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => LandingPage()));
                    _auth.signOut();
                  },
                ),
                Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                          onTap: (() => Navigator.pop(context)),
                          child: SizedBox(
                            height: 60,
                            child: ListTile(
                                title: Icon(
                              Icons.arrow_back,
                              color: Theme.of(context).colorScheme.secondary,
                            )),
                          ))),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            //color: Color.fromARGB(255, 31, 31, 31),
            shape: const CircularNotchedRectangle(),
            elevation: 20,
            //notchMargin: 6.0,
            child: Container(
              height: 60.0,
              child: ToggleButtons(
                  renderBorder: false,
                  constraints: BoxConstraints.expand(width: size.width / 4),
                  children: [
                    Icon(
                      Icons.water_drop,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(Icons.lightbulb),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Icon(Icons.change_circle),
                    ),
                    Icon(Icons.account_tree_rounded),
                  ],
                  isSelected: buttonsSelected,
                  onPressed: (int index) {
                    setState(() {
                      _currentIndex = index;
                      debugPrint('Index $index activated');
                      setBAB(index);
                      loadScreen();
                      for (int i = 0; i < buttonsSelected.length; i++) {
                        buttonsSelected[i] = i == index;
                      }
                    });
                  }),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(

              //mini: true,
              child: Icon(
                _controlMode ?  Icons.bolt : Icons.sports_esports  , //bolt
              ),
              onPressed: () {
                setState(() {
                  _controlMode = !_controlMode;
                  controlMode(_controlMode);
                  debugPrint('Control mode toggled');
                });
              }),
          body: ChangeNotifierProvider(
            create: (context) => SpinChangeModel(),
            child: Column(
              children: [
                addVerticalSpace(25),
                Center(child: PodView(size: size)),
                Expanded(child: _currentWidget),
              ],
            ),
          )),
    );
  }
}

Future<dynamic> accentInstruction(BuildContext context) {
  final uiTheme = Provider.of<UIModeModel>(context, listen: false);
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              'The current color on the color wheel will be set as accent.'),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: currentHsvColor.toColor(),
                ),
                onPressed: () {
                  uiTheme.setAccent(currentHsvColor.toColor());
                  Navigator.pop(context);
                },
                child: Text('Okay'))
          ],
        );
      });
}
