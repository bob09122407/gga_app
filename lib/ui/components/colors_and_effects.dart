import 'dart:async';
import 'package:fh_mini_app/utils/widget_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../config/esp32_url_provider.dart';

HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);

//minimal color picker
class ColorsAndEffects extends StatefulWidget {
  const ColorsAndEffects({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.portraitOnly = false,
    this.colorPickerHeight = 200.0,
    this.hueRingStrokeWidth = 15.0,
    this.enableAlpha = false,
    this.displayThumbColor = true,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
  }) : super(key: key);

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final bool portraitOnly;
  final double colorPickerHeight;
  final double hueRingStrokeWidth;
  final bool enableAlpha;
  final bool displayThumbColor;
  final BorderRadius pickerAreaBorderRadius;

  @override
  _ColorsAndEffectsState createState() => _ColorsAndEffectsState();
}

class _ColorsAndEffectsState extends State<ColorsAndEffects> {
  @override
  void initState() {
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    super.initState();
  }

  @override
  void didUpdateWidget(ColorsAndEffects oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  void onColorChanging(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor());
  }

  void sendHex(String hexString) async {

    try {
      final ESP32UrlProvider esp32UrlProvider = Provider.of<ESP32UrlProvider>(context, listen: false);
      await get(Uri.parse('http://${esp32UrlProvider.esp32Url}/hex?hexCode=${hexString}'))
          .timeout(Duration(seconds: 3));
    } on TimeoutException catch (_) {
      debugPrint('Connection Timeout');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Set color and effect button

            Expanded(
              child: SizedBox(
                child: Container(
                  child: EffectsScroll(),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Color ring
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: widget.pickerAreaBorderRadius,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: SizedBox(
                            width: widget.colorPickerHeight,
                            height: widget.colorPickerHeight,
                            child: ColorPickerHueRing(
                              currentHsvColor,
                              onColorChanging,
                              displayThumbColor: widget.displayThumbColor,
                              strokeWidth: widget.hueRingStrokeWidth,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: FloatingActionButton(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  currentHsvColor.toColor().withAlpha(180),
                              child: Icon(
                                Icons.check,
                              ),
                              onPressed: () => setState(() {
                                    String hexString =
                                        currentHsvColor.toColor().toString();
                                    sendHex(hexString);
                                    debugPrint(hexString);
                                  })),
                        ),
                      ),
                    ],
                  ),

                  addVerticalSpace(10),

                  //Brightness Track
                  SizedBox(
                    height: 40.0,
                    width: widget.colorPickerHeight,
                    child: ColorPickerSlider(
                      TrackType.alpha,
                      currentHsvColor,
                      onColorChanging,
                      displayThumbColor: widget.displayThumbColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Neopixel Effects
class EffectsScroll extends StatefulWidget {
  const EffectsScroll({
    Key? key,
  }) : super(key: key);

  @override
  State<EffectsScroll> createState() => _EffectsScrollState();
}

class _EffectsScrollState extends State<EffectsScroll> {
  void effectPush(int index) async {
    final ESP32UrlProvider esp32UrlProvider = Provider.of<ESP32UrlProvider>(context, listen: false);
    String url = 'http://${esp32UrlProvider.esp32Url}/effect/$index';
    debugPrint(url);

    try {
      Response fogResponse =
          await get(Uri.parse(url)).timeout(Duration(seconds: 3));
      print('Response from ESP : ${fogResponse.body}');
    } on TimeoutException catch (_) {
      print('Could not communicate');
    }
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex;
    return ListWheelScrollView(
        onSelectedItemChanged: (int index) {
          setState(() {
            _selectedIndex = index;
            effectPush(_selectedIndex);
            print("Selected Effect Index : $_selectedIndex");
          });
        },
        useMagnifier: true,
        magnification: 1.2,
        physics: FixedExtentScrollPhysics(),
        perspective: 0.009,
        itemExtent: 50,
        children: [
          'Breathe',
          'Comet',
          'Rainbow',
          'Static',
        ].map((e) => CardMaker(text: e)).toList());
  }
}

class CardMaker extends StatelessWidget {
  const CardMaker({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Card(
        color: Theme.of(context).primaryColor,
        child: Center(
            child: Text(
          text,
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}






